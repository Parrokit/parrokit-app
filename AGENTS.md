# AGENTS.md

이 문서는 이 저장소에서 작업하는 코딩 에이전트(Codex/Claude 등)를 위한 프로젝트 규칙서다.
목표는 "빠르게, 안전하게, 현재 코드 스타일을 유지"하는 것이다.

## 1) 작업 범위와 우선순위

- 우선순위: 사용자 요청 > 이 파일 > 기존 코드 패턴 > 일반 관례
- 변경은 요청 범위 안에서 최소화한다.
- 관련 없는 파일 포맷 변경/리팩터링은 하지 않는다.
- 생성 파일(`*.g.dart`, 플랫폼 generated 파일)은 필요할 때만 갱신한다.

## 2) 기술 스택 요약

- Flutter + Dart (SDK `^3.6.1`)
- 상태관리: `provider`
- 라우팅: `go_router`
- 로컬 DB: `drift` (코드 생성 사용)
- 백엔드: Firebase(Auth/Firestore/Functions/Storage)
- Cloud Functions: TypeScript (`functions/`)

## 3) 실행/검증 명령

루트(`parrokit/`)에서 실행:

```bash
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

Functions(`functions/`)에서 실행:

```bash
npm ci
npm run build
```

주의:
- Dart/Drift 관련 변경 후 `build_runner` 재생성 여부를 확인한다.
- 가능하면 수정한 범위에 대해 최소 1회 정적 분석(`flutter analyze`)을 수행한다.

## 4) 아키텍처 규칙 (프로젝트 준수)

- 기본 구조: MVVM + Clean Architecture
- `features/{feature}/domain`: 순수 Dart (Flutter 의존 금지)
- `features/{feature}/data`: usecase/service/adapter/port
- `features/{feature}/presentation`: screen/view model/sections/widgets
- 비즈니스 로직은 UI(`Widget`)보다 service/usecase에 둔다.

## 5) 네이밍/코드 스타일

- Screen: `{Feature}Screen`
- Section: `{Name}Section`
- Provider: `{Feature}Provider`
- ViewModel: `{Feature}ViewModel`
- UseCase: `{Action}{Target}UseCase`
- 축약어 이름(`Btn`, `QA`)은 피한다.

import 순서:
1. `dart:*`
2. `package:*`
3. 프로젝트 상대/로컬 import

코드 작성 원칙:
- 기존 파일의 주석/섹션 스타일을 존중한다.
- async 작업 뒤 UI 접근 전 `mounted` 확인 패턴을 유지한다.
- 하드코딩 문자열/상수는 기존 패턴에 맞춰 분리한다.

## 6) 파일 배치 규칙

- 새 화면: 해당 feature의 `presentation/` 하위에 추가
- 재사용 UI: `presentation/widgets/`
- 화면 전용 조립 블록: `presentation/sections/`
- 전역 공통 로직은 신중히 `core/`로 이동

## 7) Firebase / 보안 주의

- 실제 키/토큰/비밀값을 코드나 로그에 남기지 않는다.
- `.env` 값은 커밋하지 않는다.
- Rules(`firestore.rules`, `storage.rules`) 수정 시 최소 권한 원칙 준수.

## 8) 에이전트 작업 방식

- 먼저 관련 파일을 읽고, 기존 패턴을 최소 2곳 이상 확인한 뒤 수정한다.
- 큰 변경 전에 "무엇을 왜 바꾸는지" 짧은 계획을 공유한다.
- 완료 시 아래를 반드시 보고한다:
  - 변경 파일 목록
  - 동작 변화 요약
  - 실행한 검증 명령과 결과
  - 남은 리스크/후속 작업
  - 채팅 마지막 줄에 `[하네스 사용]`를 단독으로 출력

## 9) 참고 문서

- OpenAI Codex AGENTS.md 가이드:
  - https://developers.openai.com/codex/guides/agents-md
- OpenAI Codex 소개(AGENTS.md 역할 설명 포함):
  - https://openai.com/index/introducing-codex/
- Anthropic CLAUDE.md 메모리/지침 로딩 참고:
  - https://docs.anthropic.com/en/docs/claude-code/memory
  - https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts
