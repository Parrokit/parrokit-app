import { GoogleGenAI } from '@google/genai';

async function test() {
  const ai = new GoogleGenAI({ vertexai: true, project: 'parrokit-45126', location: 'us-central1' });
  const response = await ai.models.generateContent({
    model: 'gemini-2.5-flash',
    contents: 'say hello',
  });
  
  // print types for response.candidates[0].content.parts[0]
  const part = response.candidates?.[0]?.content?.parts?.[0];
  if (part?.inlineData) {
     const data = part.inlineData.data;
     const mimeType = part.inlineData.mimeType;
  }
}
