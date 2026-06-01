# AGENTS.md

이 파일은 저장소 최상위 강제 규칙이다.
세부 작업 규칙은 `.agents/roles/*/AGENTS.md`, `.agents/workflows/*`를 따른다.

## 1) 우선순위
1. 사용자 요청
2. 이 파일
3. 역할 문서(`.agents/roles/*/AGENTS.md`)
4. 워크플로(`.agents/workflows/*`)
5. 기존 코드 패턴

## 2) 작업 범위
1. 요청 범위 밖 수정 금지
2. 무관한 리팩터링/포맷 변경 금지
3. 생성 파일(`*.g.dart`, 플랫폼 generated)은 필요 시에만 갱신

## 3) 아키텍처/코드 규칙
1. 기본: MVVM + Clean Architecture
2. `domain`: 순수 Dart(Flutter 의존 금지)
3. 비즈니스 로직은 Widget이 아니라 service/usecase/provider에 배치
4. import 순서: `dart:*` -> `package:*` -> 로컬
5. async 이후 UI 접근 전 `mounted` 확인
6. 스타일 값은 `AppTheme` 우선 사용

## 4) 검증 최소 규칙
1. 수정 범위 기준 `flutter analyze` 최소 1회 실행
2. Drift/Dart 모델 변경 시 build_runner 재생성 필요 여부 확인

## 5) 보안
1. 키/토큰/비밀값 코드/로그 노출 금지
2. `.env` 커밋 금지
3. Rules 수정 시 최소 권한 원칙 적용

## 6) 로그/QA 규칙
1. 테스트 영향 코드 변경 시 `test/qa/logging_guideline.md` 준수
2. 로그 포맷은 `[Feature][Action] message key=value` 사용
3. `catch` 블록에는 원인 파악 가능한 로그를 남긴다
4. QA 종료 전 `error` 로그 0건 확인

## 7) 보고 형식(필수)
완료 보고에는 반드시 포함:
1. 변경 파일 목록
2. 동작 변화 요약
3. 실행한 검증 명령과 결과
4. 남은 리스크/후속 작업
5. 마지막 줄 단독: `[하네스 사용]`

## 8) 역할/워크플로 사용 규칙
1. 작업 시작 전 관련 역할 문서 1개 이상 선택
2. 필요 워크플로만 최소 로드(과다 로드 금지)
3. 커밋/병합은 `commit-keeper` 및 관련 워크플로 준수
4. `docs/` 경로 문서 작업은 반드시 `doc-sync-writer` 역할을 먼저 적용
5. `docs/` 경로 문서 작업은 반드시 `/product-docs-guideline`을 먼저 참조
