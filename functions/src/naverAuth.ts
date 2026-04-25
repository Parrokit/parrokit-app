import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

// HTTP 콜러블 함수: Flutter에서 넘겨준 Access Token을 검증하고 Custom Token을 반환합니다.
export const createNaverCustomToken = functions.https.onCall(
  async (request) => {
    const {accessToken} = request.data;

    if (!accessToken) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The function must be called with one argument 'accessToken'."
      );
    }

    try {
      // 1. 네이버 서버에 Access Token을 보내서 유저 정보 가져오기
      const response = await fetch("https://openapi.naver.com/v1/nid/me", {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      if (!response.ok) {
        throw new Error(
          `Naver API request failed with status: ${response.status}`
        );
      }

      const data = await response.json();

      if (data.resultcode !== "00") {
        throw new functions.https.HttpsError(
          "unauthenticated",
          `Failed to authenticate with Naver: ${data.message}`
        );
      }

      // 2. 네이버 유저 정보 파싱
      const naverUser = data.response;
      const uid = `naver:${naverUser.id}`;

      // 3. Firebase Auth에 유저가 있는지 확인하고, 없으면 새로 생성 (이메일, 이름 등 저장)
      try {
        await admin.auth().getUser(uid);
      // 이미 가입된 유저라면 정보 업데이트 (선택 사항)
      } catch (error: unknown) {
        if ((error as any).code === "auth/user-not-found") {
        // 첫 가입 유저 생성
          await admin.auth().createUser({
            uid: uid,
            email: naverUser.email,
            displayName: naverUser.name || naverUser.nickname,
            photoURL: naverUser.profile_image,
          });
        } else {
          throw error;
        }
      }

      // 4. 앱(Flutter)으로 돌려줄 커스텀 토큰 생성
      const customToken = await admin.auth().createCustomToken(uid);

      return {customToken};
    } catch (error) {
      console.error("Error creating Naver custom token:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to create custom token."
      );
    }
  });
