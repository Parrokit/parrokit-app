import {onCall} from "firebase-functions/v2/https";
import {genkit} from "genkit";
import {vertexAI} from "@genkit-ai/google-genai";
import {enableFirebaseTelemetry} from "@genkit-ai/firebase";

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
  }) => {
    // 비용 폭탄 방지: 프론트엔드가 100개를 보내더라도, 최근 10개(대화 5번 왕복)만 잘라서 사용
    const MAX_HISTORY = 10;
    const recentHistory = (input.history || []).slice(-MAX_HISTORY);

    // 잘라낸 배열을 Genkit 규격으로 변환
    const messages = recentHistory.map((msg) => ({
      role: msg.role,
      content: [{text: msg.text}],
    }));

    const p = await ai.prompt("chatbot");
    const {text} = await p({
      input: {message: input.message},
      messages: messages, // 과거 대화 내역을 AI 문맥에 자동 주입
    });
    return text;
  }
);

export const ttsFlow = ai.defineFlow(
  "ttsFlow",
  async (input: { text: string }) => {
    const p = await ai.prompt("tts");
    const {text} = await p(input);
    return text; // JSON 형태의 응답
  }
);

export const videoFlow = ai.defineFlow(
  "videoFlow",
  async (input: { dialogue: string; scene: string }) => {
    const p = await ai.prompt("video");
    const {text} = await p(input);
    return text; // JSON 형태의 응답
  }
);

// 4. 앱(Flutter)에서 호출할 수 있도록 Firebase Functions로 내보내기
export const generateChatbotResponse = onCall(async (request) => {
  return await chatbotFlow(request.data);
});

export const generateTtsPrompt = onCall(async (request) => {
  return await ttsFlow(request.data);
});

export const generateVideoPrompt = onCall(async (request) => {
  return await videoFlow(request.data);
});
