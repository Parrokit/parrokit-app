# AGENTS.md

이 파일은 저장소 최상위 강제 규칙이다.  
세부 규칙은 `.agents/workflows/*`, `.agents/rules/*`를 따른다.

## 우선순위

1. 사용자 요청
2. `AGENTS.md`
3. `.agents/rules/*`
4. `.agents/workflows/*`
5. 기존 코드 패턴

## 작업 범위

- 요청 범위 밖 수정은 하지 않는다.
- 무관한 리팩터링, 포맷 변경은 하지 않는다.
- 생성 파일은 필요할 때만 갱신한다.
- 사용자가 `리팩터링`을 요청하면 클린 아키텍처 경계 재설계로 해석한다.
- 리팩터링 전에는 경계, 의존성, 폴더 이동 계획을 먼저 제시한다.

## 기본 개발 규칙

- 기본 구조는 MVVM + Clean Architecture를 따른다.
- `domain`은 순수 Dart만 사용한다.
- 비즈니스 로직은 Widget이 아니라 provider, usecase, service에 둔다.
- import 순서는 `dart:*` -> `package:*` -> 로컬 순서로 유지한다.
- `async` 이후 UI 접근 전 `mounted`를 확인한다.
- 스타일 값은 `AppTheme`을 우선 사용한다.

## 검증

- 수정 후 가능한 범위에서 `flutter analyze`를 실행한다.
- Drift 또는 Dart 모델 변경 시 build_runner 재생성 필요 여부를 확인한다.
- 검증하지 못한 항목은 완료 보고에 남긴다.

## 보안

- 키, 토큰, 비밀값을 코드와 로그에 남기지 않는다.
- `.env`는 커밋하지 않는다.
- Rules 수정 시 최소 권한 원칙을 적용한다.

## 참조 규칙

- 아키텍처 변경은 `.agents/rules/architecture.md`를 따른다.
- 커밋 메시지는 `.agents/rules/commit-message.md`를 따른다.
- 문서 작업은 `.agents/rules/documentation.md`를 따른다.
- 로그 작업은 `.agents/rules/logging.md`를 따른다.
- 네이밍과 스타일은 `.agents/rules/naming-style.md`를 따른다.
- UI 테마 작업은 `.agents/rules/theme.md`를 따른다.

## 워크플로

- 일반 개발은 `.agents/workflows/development.md`를 따른다.
- dev 병합은 `.agents/workflows/git-merge.md`를 따른다.
- 하네스 수정은 `.agents/workflows/harness-update.md`를 따른다.
- 필요한 워크플로만 최소로 참조한다.

## 완료 보고

완료 보고에는 다음 항목을 포함한다.

- 변경 파일 목록
- 동작 변화 요약
- 실행한 검증 명령과 결과
- 남은 리스크 또는 후속 작업
- 마지막 줄 단독: `[하네스 사용]`