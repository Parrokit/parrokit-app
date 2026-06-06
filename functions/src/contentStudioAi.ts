import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {genkit} from "genkit";
import {vertexAI} from "@genkit-ai/google-genai";
import {enableFirebaseTelemetry} from "@genkit-ai/firebase";
import {ElevenLabsClient} from "@elevenlabs/elevenlabs-js";
import textToSpeech from "@google-cloud/text-to-speech";
import {GoogleGenAI} from "@google/genai";
import {WaveFile} from "wavefile";
import * as Buffer from "buffer";

// 파이어베이스 시크릿 매니저에서 API 키를 안전하게 불러옵니다.
const elevenLabsApiKey = defineSecret("ELEVENLABS_API_KEY");
const geminiApiKey = defineSecret("GEMINI_API_KEY");

// 1. 파이어베이스 콘솔(Genkit 탭)로 로그 전송 활성화 (콜드스타트 타임아웃 방지)
enableFirebaseTelemetry({
  metricExportTimeoutMillis: 180000,
  metricExportIntervalMillis: 180000,
});

// 2. 통합 AI 플러그인 초기화 (Vertex AI 백엔드 사용)
const ai = genkit({
  plugins: [vertexAI({location: "us-central1"})],
});

import {z} from "zod";

export const ChatbotOutputSchema = z.object({
  reply: z.string(),
  actionType: z.enum([
    "none",
    "ask_routing",
    "change_mode",
    "tts_trigger",
    "video_trigger",
    "script_recommendation",
  ]),
  actionData: z.object({
    text: z.string().optional(),
    language: z.string().optional(),
    provider: z.string().optional(),
    voiceId: z.string().optional(),
    prompt: z.string().optional(),
    ratio: z.string().optional(),
    duration: z.number().optional(),
    routingOptions: z.array(z.string()).optional(),
    targetMode: z.string().optional(),
    scripts: z.array(z.string()).optional(),
  }).nullable().optional(),
});

// 3. 각각의 Dotprompt 파일을 불러와서 Flow 정의
export const chatbotFlow = ai.defineFlow(
  {
    name: "chatbotFlow",
    inputSchema: z.object({
      history: z.array(
        z.object({role: z.enum(["user", "model"]), text: z.string()})
      ),
      message: z.string(),
      model: z.string().optional(),
      chatbotMode: z.enum(["general", "tts", "video"]).optional(),
    }),
    outputSchema: ChatbotOutputSchema,
  },
  async (input) => {
    // 비용 폭탄 방지: 프론트엔드가 100개를 보내더라도, 무조건 최근 10개(대화 5번 왕복)만 잘라서 사용
    const MAX_HISTORY = 10;
    const recentHistory = (input.history || []).slice(-MAX_HISTORY);

    const targetModel = input.model ? `vertexai/${input.model}` : undefined;
    console.log(
      `[Chatbot][Flow] Mode parameter inputMode=${input.model} ` +
        `targetModel=${targetModel} chatbotMode=${input.chatbotMode}`
    );

    // chatbotMode에 따라 프롬프트 파일 분기
    let promptName = "chatbots/general-agent";
    if (input.chatbotMode === "tts") {
      promptName = "chatbots/tts-specialist-agent";
    } else if (input.chatbotMode === "video") {
      promptName = "chatbots/video-specialist-agent";
    }

    const p = await ai.prompt(promptName);
    const response = await p(
      {
        message: input.message,
        history: recentHistory,
      },
      {
        // 프론트엔드에서 모델 이름을 보냈다면 해당 모델로 덮어쓰기 (없으면 .prompt의 기본값 사용)
        model: targetModel,
      }
    );

    // 만약 response.output이 존재하지 않는 경우를 대비한 대체값 제공
    return response.output || {
      reply: response.text || "",
      actionType: "none",
      actionData: null,
    };
  }
);

export interface ElevenLabsSettings {
  stability?: number;
  similarity_boost?: number;
  style?: number;
  use_speaker_boost?: boolean;
}

export const generateTtsFlow = ai.defineFlow(
  "generateTtsFlow",
  async (input: {
    text: string;
    language: string;
    provider?: "google" | "elevenlabs" | "gemini";
    voiceId?: string;
    modelId?: string;
    speakingRate?: number;
    pitch?: number;
    elevenLabsSettings?: ElevenLabsSettings;
  }) => {
    if (!input.text) {
      throw new Error("Text is required for TTS generation.");
    }
    if (!input.language) {
      throw new Error("Language is required for TTS generation.");
    }

    const provider = input.provider || "google";

    if (provider === "elevenlabs") {
      try {
        const client = new ElevenLabsClient({
          apiKey: elevenLabsApiKey.value(),
        });

        const targetVoice = input.voiceId || "21m00Tcm4TlvDq8ikWAM";
        const targetModel = input.modelId || "eleven_multilingual_v2";

        const audioStream = await client.textToSpeech.convert(targetVoice, {
          text: input.text,
          modelId: targetModel,
          outputFormat: "mp3_44100_128",
          voiceSettings: input.elevenLabsSettings ? {
            stability: input.elevenLabsSettings.stability,
            similarityBoost: input.elevenLabsSettings.similarity_boost,
            style: input.elevenLabsSettings.style,
            useSpeakerBoost: input.elevenLabsSettings.use_speaker_boost,
          } : undefined,
        });

        const reader = audioStream.getReader();
        const chunks: Uint8Array[] = [];
        // eslint-disable-next-line no-constant-condition
        while (true) {
          const {done, value} = await reader.read();
          if (done) break;
          if (value) chunks.push(value);
        }
        const buffer = Buffer.Buffer.concat(chunks);

        return {
          audioBase64: buffer.toString("base64"),
        };
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        console.error("ElevenLabs TTS Error:", error);
        throw new Error(error.message || "Failed to generate ElevenLabs TTS");
      }
    } else if (provider === "gemini") {
      try {
        const client = new GoogleGenAI({
          apiKey: geminiApiKey.value(),
        });

        const targetModel = input.modelId || "gemini-2.5-flash-preview-tts";
        const targetVoice = input.voiceId || "Aoede";

        const response = await client.models.generateContent({
          model: targetModel,
          contents: input.text,
          config: {
            responseModalities: ["AUDIO"],
            speechConfig: {
              voiceConfig: {
                prebuiltVoiceConfig: {
                  voiceName: targetVoice,
                },
              },
            },
          },
        });

        const part = response.candidates?.[0]?.content?.parts?.[0];
        if (!part || !part.inlineData || !part.inlineData.data) {
          throw new Error("No audio data returned from Gemini TTS.");
        }

        // Gemini returns raw PCM data (audio/L16;codec=pcm;rate=24000).
        // We need a WAV header so the Flutter audio player can play it.
        const pcmBuffer = Buffer.Buffer.from(part.inlineData.data, "base64");

        const wav = new WaveFile();

        // Convert the raw byte buffer to an array of 16-bit LE samples
        const int16Array = new Int16Array(pcmBuffer.length / 2);
        for (let i = 0; i < int16Array.length; i++) {
          int16Array[i] = pcmBuffer.readInt16LE(i * 2);
        }

        wav.fromScratch(1, 24000, "16", int16Array);
        const wavBuffer = wav.toBuffer();

        return {
          audioBase64: Buffer.Buffer.from(wavBuffer).toString("base64"),
        };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        console.error("Gemini TTS Error:", error);
        throw new Error(error.message || "Failed to generate Gemini TTS");
      }
    } else {
      // Default to Google TTS
      try {
        const client = new textToSpeech.TextToSpeechClient();

        // language is guaranteed to exist
        const languageCode = input.language;

        // If voiceId is not provided, pick a default based on language
        let defaultVoice = "en-US-Journey-F"; // Default English
        if (languageCode.startsWith("ko")) {
          defaultVoice = "ko-KR-Neural2-A";
        } else if (languageCode.startsWith("ja")) {
          defaultVoice = "ja-JP-Neural2-B";
        }

        const name = input.voiceId || defaultVoice;

        const request = {
          input: {text: input.text},
          voice: {languageCode, name},
          audioConfig: {
            audioEncoding: "MP3" as const,
            speakingRate: input.speakingRate || 1.0,
            pitch: input.pitch || 0.0,
          },
        };

        // 사용자 확인용 로그 추가: 구글로 어떤 모델이 넘어가는지 파이어베이스 콘솔에 출력합니다.
        console.log(
          `[Google TTS Request] Language: ${languageCode}, Voice: ${name}, ` +
          `Speed: ${input.speakingRate}, Pitch: ${input.pitch}`
        );

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
  }
);


// 4. 앱(Flutter)에서 호출할 수 있도록 Firebase Functions로 내보내기
export const generateChatbotResponse = onCall(async (request) => {
  try {
    return await chatbotFlow(request.data);
  } catch (error: any) {
    console.error("Chatbot Wrapper Error:", error);
    throw new HttpsError(
      "aborted",
      error.message || "Failed to generate response"
    );
  }
});

export const generateTts = onCall(
  {secrets: [elevenLabsApiKey, geminiApiKey]},
  async (request) => {
    try {
      return await generateTtsFlow(request.data);
    } catch (error: any) {
      console.error("TTS Wrapper Error:", error);
      throw new HttpsError(
        "aborted",
        error.message || "Failed to generate TTS"
      );
    }
  }
);

// 5. 구글 Cloud TTS 보이스 목록 불러오기 (프론트엔드 동적 렌더링용)
export const listTtsVoices = onCall(async (request) => {
  try {
    const client = new textToSpeech.TextToSpeechClient();
    const languageCode = request.data?.languageCode; // 선택적 파라미터

    const [result] = await client.listVoices({languageCode});
    return {voices: result.voices};
  } catch (error: any) {
    console.error("Google Cloud TTS listVoices Error:", error);
    throw new Error(error.message || "Failed to list Google TTS voices");
  }
});
