# 🦜 Parokit

**애니메이션 클립으로 일본어/언어 학습하는 Flutter 앱**

Parokit은 애니메이션 영상 클립과 자막 세그먼트를 활용한 언어 학습 앱입니다.  
좋아하는 애니메이션 장면을 저장하고, 자막과 함께 반복 학습할 수 있습니다.

---

## ✨ 주요 기능

### 📱 쇼츠 (Shorts)
- TikTok/Reels 스타일의 세로 스와이프 학습
- 자막 on/off, 자동 넘김 지원
- 랜덤 클립으로 다양한 표현 학습

### 🎬 클립 에디터 (Editor)
- 영상 파일에서 원하는 장면 저장
- 여러 자막 세그먼트 추가 (원문/발음/번역)
- 작품명, 시즌, 에피소드 메타데이터 관리

### 📺 플레이어 (Player)
- 구간 반복 재생 (세그먼트 루프)
- 배속 조절 (0.5x ~ 2.0x)
- 라이트/다크 테마, 전체화면 지원
- 백그라운드 오디오 모드

### 📚 라이브러리 (Library)
- 작품별/태그별 클립 정리
- 브레드크럼 네비게이션 (작품 → 시즌 → 에피소드 → 클립)
- 클립 검색 및 필터링

### 🎯 추천 (Recommendation)
- 사용자 시청 패턴 기반 추천
- 좋아하는 작품 선택으로 맞춤 추천

### 💰 코인 & 프리미엄
- 코인 충전 시스템 (인앱 결제)
- 프리미엄 구독으로 광고 제거

---

## 🏗️ 아키텍처

**MVVM + Clean Architecture** 기반 구조

```
lib/
├── main.dart              # 앱 진입점
├── core/                  # 전역 공통 코드
│   ├── app.dart           # App 위젯
│   ├── bootstrap.dart     # 앱 초기화
│   ├── di/                # 의존성 주입
│   ├── config/            # 설정 (Firebase, 앱 설정)
│   ├── provider/          # 전역 상태 관리
│   ├── router/            # 라우팅 (GoRouter)
│   ├── theme/             # 디자인 시스템
│   └── services/          # 외부 서비스 연동
├── data/                  # 데이터 레이어
│   └── local/             # Drift 로컬 DB
└── features/              # 기능별 모듈
    ├── auth/              # 인증
    ├── dashboard/         # 대시보드 (홈)
    ├── shorts/            # 쇼츠 학습
    ├── editor/            # 클립 에디터
    ├── player/            # 클립 플레이어
    ├── library/           # 라이브러리
    ├── recom/             # 추천
    └── payment/           # 결제
```

### 기술 스택

| 영역 | 기술 |
|------|------|
| **UI** | Flutter, Material 3 |
| **상태 관리** | Provider |
| **라우팅** | GoRouter |
| **로컬 DB** | Drift (SQLite) |
| **인증** | Firebase Auth |
| **클라우드** | Firebase Firestore |
| **광고** | Google Mobile Ads |
| **결제** | In-App Purchase, PortOne (iamport) |
| **비디오** | video_player, FFmpeg Kit |
| **오디오** | just_audio, audio_service |

---

## 🚀 시작하기

### 요구 사항

- Flutter SDK ^3.6.1
- Dart SDK ^3.6.1
- Android Studio / Xcode

### 설치

```bash
# 의존성 설치
flutter pub get

# 환경 변수 설정
cp .env.example .env
# .env 파일에 Firebase 및 API 키 입력

# 코드 생성 (Drift)
dart run build_runner build

# 앱 실행
flutter run
```

### Firebase 설정

```bash
# FlutterFire CLI로 Firebase 설정
flutterfire configure
```

---

## 📁 프로젝트 구조 상세

각 feature는 Clean Architecture 레이어를 따릅니다:

```
features/{feature}/
├── domain/          # 비즈니스 로직, 엔티티
├── data/            # 데이터 소스, 리포지토리
└── presentation/    # UI (Screen, Sections, Widgets)
```

자세한 가이드는 [Flutter Style Guide](.agent/workflows/flutter-style-guide.md)를 참고하세요.

---

## 📝 라이선스

Private project - All rights reserved.

---

## 👨‍💻 개발자

Made with 💜 by Chun-Bae
