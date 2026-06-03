import {onCall} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {genkit} from "genkit";
import {vertexAI} from "@genkit-ai/google-genai";
import {enableFirebaseTelemetry} from "@genkit-ai/firebase";
import {ElevenLabsClient} from "@elevenlabs/elevenlabs-js";
import textToSpeech from "@google-cloud/text-to-speech";
import * as Buffer from "buffer";

// 파이어베이스 시크릿 매니저에서 API 키를 안전하게 불러옵니다.
const elevenLabsApiKey = defineSecret("ELEVENLABS_API_KEY");

// 1. 파이어베이스 콘솔(Genkit 탭)로 로그 전송 활성화
enableFirebaseTelemetry();

// 2. 통합 AI 플러그인 초기화 (Vertex AI 백엔드 사용)
const ai = genkit({
  plugins: [vertexAI({location: "us-central1"})],
});

// 3. 각각의 Dotprompt 파일을 불러와서 Flow 정의
export const chatbotFlow = ai.defineFlow(
  "chatbotFlow",
  async (input: {
    history: { role: "user" | "model"; text: string }[];
    message: string;
    model?: string;
  }) => {
    // 비용 폭탄 방지: 프론트엔드가 100개를 보내더라도, 무조건 최근 10개(대화 5번 왕복)만 잘라서 사용
    const MAX_HISTORY = 10;
    const recentHistory = (input.history || []).slice(-MAX_HISTORY);

    // 잘라낸 배열을 Genkit 규격으로 변환
    const messages = recentHistory.map((msg) => ({
      role: msg.role,
      content: [{text: msg.text}],
    }));

    const p = await ai.prompt("chatbot");
    const {text} = await p(
      {
        input: {message: input.message},
        messages: messages, // 과거 대화 내역을 AI 문맥에 자동 주입
      },
      {
        // 프론트엔드에서 모델 이름을 보냈다면 해당 모델로 덮어쓰기 (없으면 .prompt의 기본값 사용)
        model: input.model ? `vertexai/${input.model}` : undefined,
      }
    );
    return text;
  }
);


export const generateAudioFlow = ai.defineFlow(
  "generateAudioFlow",
  async (input: { text: string; voiceId?: string; language?: string }) => {
    try {
      if (!input.text) {
        throw new Error("Text is required for TTS generation.");
      }

      // ElevenLabs 클라이언트 초기화 (시크릿 키 사용)
      const client = new ElevenLabsClient({
        apiKey: elevenLabsApiKey.value(),
      });

      // TTS 생성 요청
      // 기본 목소리 예시(Rachel 등), 플러터에서 voiceId를 보냈다면 덮어씁니다.
      const targetVoice = input.voiceId || "21m00Tcm4TlvDq8ikWAM";

      const audioStream = await client.textToSpeech.convert(targetVoice, {
        text: input.text,
        modelId: "eleven_multilingual_v2", // 다국어 지원 모델
        outputFormat: "mp3_44100_128",
      });

      // ReadableStream (Web API) 데이터를 Buffer로 변환
      const reader = audioStream.getReader();
      const chunks: Uint8Array[] = [];
      // eslint-disable-next-line no-constant-condition
      while (true) {
        const {done, value} = await reader.read();
        if (done) break;
        if (value) chunks.push(value);
      }
      const buffer = Buffer.Buffer.concat(chunks);

      // Base64 문자열로 변환하여 반환
      return {
        audioBase64: buffer.toString("base64"),
      };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      console.error("ElevenLabs TTS Error:", error);
      throw new Error(error.message || "Failed to generate TTS");
    }
  }
);


// 4. 앱(Flutter)에서 호출할 수 있도록 Firebase Functions로 내보내기
export const generateChatbotResponse = onCall(async (request) => {
  return await chatbotFlow(request.data);
});


export const generateElevenLabsTts = onCall(
  {secrets: [elevenLabsApiKey]},
  async (request) => {
    return await generateAudioFlow(request.data);
  }
);


export const generateGoogleTtsFlow = ai.defineFlow(
  "generateGoogleTtsFlow",
  async (input: { text: string; language?: string; voiceName?: string }) => {
    try {
      if (!input.text) {
        throw new Error("Text is required for TTS generation.");
      }

      // Google Cloud TTS 클라이언트 초기화
      const client = new textToSpeech.TextToSpeechClient();

      const languageCode = input.language || "ko-KR";
      // 한국어 고품질 Neural2 모델을 기본값으로 사용 (Journey 모델은 한국어 미지원)
      const name = input.voiceName || "ko-KR-Neural2-A";

      const request = {
        input: {text: input.text},
        voice: {languageCode, name},
        audioConfig: {audioEncoding: "MP3" as const},
      };

      const [response] = await client.synthesizeSpeech(request);

      if (!response.audioContent) {
        throw new Error("No audio content returned from Google Cloud TTS.");
      }

      const buffer = Buffer.Buffer.from(response.audioContent);

      return {
        audioBase64: buffer.toString("base64"),
      };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      console.error("Google Cloud TTS Error:", error);
      throw new Error(error.message || "Failed to generate Google TTS");
    }
  }
);

export const generateGoogleTts = onCall(async (request) => {
  return await generateGoogleTtsFlow(request.data);
});
