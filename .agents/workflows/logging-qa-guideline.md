---
description: 테스트/QA 시 로그 작성 및 점검 최소 규칙
---

# Logging QA 가이드

## 목적

테스트 중 문제 원인 추적 시간을 줄이고 QA 판정을 일관화한다.

## 필수 규칙

1. 로그 레벨은 `debug/info/warn/error`로 구분한다.
2. API/Repository 호출은 시작/성공/실패를 남긴다.
3. 상태 전환(로딩/성공/실패)은 최소 1회 로그를 남긴다.
4. 모든 `catch`에는 원인 파악 가능한 로그를 남긴다.
5. 민감정보(토큰/비밀번호/식별자 원문)는 로그에 남기지 않는다.

## 포맷

- 고정: `[Feature][Action] message key=value`
- 예시: `[Community][VoteSubmit] success postId=abc123`

## QA 종료 기준

1. `error` 로그 0건
2. `warn` 로그는 의도 여부 기록
3. 실패 케이스는 재현 조건을 `test/qa/qa_checklist.md`에 기록
