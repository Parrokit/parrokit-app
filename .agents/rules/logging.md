---
trigger: model_decision
description: 로그 추가, 에러 처리, catch 블록 검토, API와 Repository 호출 로그를 수정할 때 적용
---

# Logging Rules

## 목적

- 문제 원인 추적 시간을 줄이고 로그 형식을 일관되게 유지한다.

## 로그 레벨

- `debug`: 개발 중 흐름 확인용 로그
- `info`: 정상 동작과 주요 처리 완료 로그
- `warn`: 동작은 가능하지만 확인이 필요한 로그
- `error`: 실패, 예외, 복구 불가 또는 사용자 영향 가능성이 있는 로그

## 필수 규칙

- API와 Repository 호출은 시작, 성공, 실패 로그를 남긴다.
- 상태 전환은 로딩, 성공, 실패 기준으로 최소 1회 로그를 남긴다.
- 모든 `catch`에는 원인 파악 가능한 로그를 남긴다.
- 토큰, 비밀번호, 식별자 원문 등 민감정보는 로그에 남기지 않는다.
- 임시 확인용 로그는 커밋 전에 제거한다.

## 로그 포맷

```text
[Feature][Action] message key=value