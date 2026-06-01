# Logging Guideline

테스트/QA 시 로그는 "문제 위치를 빠르게 찾기 위한 최소 표준"으로 사용한다.

## 1) 로그 레벨
- `debug`: 개발 중 상세 추적
- `info`: 주요 흐름(요청 시작/성공)
- `warn`: 비정상 상태(복구 가능)
- `error`: 실패/예외

## 2) 필수 로그 지점
- API/Repository 호출: 시작, 성공, 실패
- 상태 전환: 로딩 시작/종료, 주요 액션 결과
- 예외 처리: 모든 `catch`에서 원인 로그

## 3) 포맷
- 고정 형식: `[Feature][Action] message key=value`
- 예시: `[Community][VoteSubmit] success postId=abc123`

## 4) 보안 금지
- 토큰/비밀번호/이메일 원문/개인식별정보 출력 금지
- 필요 시 마스킹 처리

## 5) QA 체크 기준
- QA 종료 전 `error` 로그 0건 확인
- `warn` 로그는 의도 여부를 체크리스트에 기록
