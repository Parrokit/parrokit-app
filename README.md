# 🦜 Parrokit

**애니메이션 클립으로 일본어/언어 학습하는 Flutter 앱**

Parrokit은 애니메이션 영상 클립과 자막 세그먼트를 활용한 언어 학습 앱입니다.
좋아하는 애니메이션 장면을 저장하고, 자막과 함께 반복 학습할 수 있습니다.

---

## ✨ 주요 기능

### 📱 쇼츠 (Shorts)
- TikTok/Reels 스타일의 세로 스와이프 학습
- 자막 on/off, 자동 넘김 지원
- 스와이프 횟수 기반 광고 노출

### 🎬 클립 에디터 (Editor)
- 영상 파일에서 원하는 장면을 클립으로 저장
- 여러 자막 세그먼트 추가 (원문/발음/번역)
- 작품명, 시즌, 에피소드 메타데이터 관리
- AI 기반 자동 자막 생성 (Speech-to-Text) 및 드래프트 작성

### 📺 플레이어 (Player)
- 세그먼트 타임라인 네비게이션
- 구간 반복 재생 (세그먼트 루프)
- 배속 조절 (0.5x ~ 2.0x)
- 자막 오버레이, 라이트/다크 테마 지원
- 백그라운드 오디오 모드

### 📚 라이브러리 (Library)
- 폴더 뷰: 작품 → 시즌 → 에피소드 → 클립 계층 탐색
- 태그 뷰: 태그 기반 필터링 및 검색
- 브레드크럼 네비게이션

### 🕐 최근 시청 (Recent)
- 최근 시청한 클립 목록
- 썸네일 및 메타데이터 표시

### 💰 코인 & 프리미엄
- 코인 충전 시스템 (인앱 결제, PortOne 연동)
- 프리미엄 구독으로 광고 제거

---

## 🏗️ 아키텍처

**MVVM + Clean Architecture** 기반 구조

```
lib/
├── main.dart              # 앱 진입점
├── core/                  # 전역 공통 코드 (DI, Router, Theme, Provider, Services)
├── data/                  # 공통 데이터 레이어 (Drift DB, DAO, Models)
└── features/              # 기능별 모듈 (Domain-driven)
    ├── _entry/            # 진입점 (Auth, Dashboard, Intro)
    ├── _content/          # 핵심 콘텐츠 기능
    │   ├── shorts/        # 쇼츠 학습
    │   ├── clip_editor/   # 클립 에디터 (영상 편집 + AI 자막)
    │   ├── player/        # 클립 플레이어
    │   └── library/       # 라이브러리 (폴더/태그 뷰)
    ├── _discovery/        # 최근 시청
    └── _settings/         # 설정 및 결제
```

### 기술 스택

| 영역 | 기술 |
|------|------|
| **UI** | Flutter, Material 3 |
| **상태 관리** | Provider (ChangeNotifier) |
| **라우팅** | GoRouter |
| **로컬 DB** | Drift (SQLite) |
| **인증** | Firebase Auth |
| **클라우드** | Firebase Firestore |
| **AI** | OpenAI API (STT, LLM 드래프트) |
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

자세한 가이드는 [Flutter Guide Index](.agent/workflows/flutter-guide-index.md)를 참고하세요.

---

## 🛡️ 라이선스 및 지적재산권 (License & IP)

**Copyright © 2025 Chun-Bae. All Rights Reserved.**

본 프로젝트의 모든 소스 코드, 디자인, 및 알고리즘에 대한 권리는 원작자인 **Chun-Bae**에게 있습니다.
본 소프트웨어에 포함된 핵심 기능 및 기술적 메커니즘은 특허 출원된 상태이며, 지적재산권 법에 의해 보호받습니다.