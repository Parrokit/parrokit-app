# Parrokit

외국어 회화 쉐도잉을 위한 동영상 자동 반복 학습 서비스입니다.

## 핵심 기능
- 인증/온보딩 (`features/auth`)  
  - 이메일/소셜 로그인(Google, Apple, Kakao, Naver)  
  - 회원가입/로그인/비밀번호 찾기/인트로 흐름 분리
- 쇼츠 학습 피드 (`features/content/shorts`)  
  - 세로 스와이프 기반 반복 학습  
  - 자막 on/off, 자동 넘김, 광고 노출 제어
- 클립 에디터 (`features/content/clip-editor`)  
  - 영상 구간 편집 후 학습용 클립 저장  
  - 원문/발음/번역 자막 세그먼트 구성 및 메타데이터 관리
- 플레이어 (`features/content/player`)  
  - 구간 루프 반복(쉐도잉 핵심)  
  - 배속 조절, 자막 오버레이, 백그라운드 오디오
- 라이브러리 (`features/content/library`)  
  - 작품/시즌/에피소드/클립 단위 탐색  
  - 태그 필터 기반 재학습
- 최근 시청 (`features/discovery/recent`)  
  - 최근 본 클립 빠른 재진입 및 반복 학습
- 커뮤니티 (`features/community`)  
  - 게시판/질문/투표 탭 구조  
  - 댓글, 좋아요, 조회수, 채택형 질문 상태 관리
- 결제/광고/프리미엄 (`features/settings`, `core/bootstrap/steps`)  
  - Google Mobile Ads + 인앱 결제 + RevenueCat 연동  
  - 프리미엄 상태와 광고 노출 동기화

## 기술 스택
- Flutter, Dart
- Provider
- GoRouter
- Drift(SQLite)
- Firebase(Auth/Firestore/Functions/Storage)
- Google Mobile Ads, In-App Purchase

## 빠른 실행
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

필요 시 코드 생성:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 구조
```text
lib/
├── core/        # App, DI, Router, Theme, Bootstrap, 공통 서비스
├── data/        # Drift DB, 공통 모델/로컬 데이터
└── features/    # auth, content, discovery, community, settings
```

세부 작업 규칙은 아래 문서를 참고하세요.
- `AGENTS.md`
- `.agents/workflows/flutter-guide-index.md`

## License
Copyright © 2025 Chun-Bae. All Rights Reserved.
