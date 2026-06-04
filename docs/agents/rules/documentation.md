---
trigger: manual
---

# Documentation Rules

## 문서 위치

| 문서 | 위치 |
|---|---|
| 요구사항 | `docs/requirements/` |
| API 명세 | `docs/api/` |
| 데이터 스키마 | `docs/schema/` |
| 의사결정 기록 | `docs/adr/` |
| 운영 절차 | `docs/runbook/` |
| 테스트 시나리오 | `docs/test-cases/` |
| 변경 이력 | `docs/changelog/` |

## 파일명 규칙

- 요구사항: `docs/requirements/{feature}-frd.md`
- API: `docs/api/{domain}-api-spec.md`
- Schema: `docs/schema/{storage}-schema.md`
- ADR: `docs/adr/ADR-{yyyyMMdd}-{topic}.md`
- Runbook: `docs/runbook/{feature}-runbook.md`
- Test Cases: `docs/test-cases/{feature}-test-cases.md`
- Changelog: `docs/changelog/{yyyy-MM}.md`

## 최소 템플릿

- 목적
- 범위
- 데이터 계약
- 예외와 에러 규칙
- 수용 기준
- 변경 이력

## 동기화 규칙

- API, 모델, DB 구조가 바뀌면 관련 문서를 같은 커밋에서 수정한다.
- 설계 방향이나 트레이드오프가 바뀌면 `docs/adr`를 갱신한다.
- 운영, 배포, 복구 절차가 바뀌면 `docs/runbook`을 갱신한다.
- QA 기준이 바뀌면 `docs/test-cases`를 갱신한다.
- 사용자 영향 기능이 바뀌면 changelog를 갱신한다.
- 문서 변경이 불필요하면 커밋 메시지 또는 PR 본문에 이유를 1줄로 남긴다.

## 체크리스트

- 엔드포인트 변경: `docs/api`
- 요구사항 변경: `docs/requirements`
- 필드, 컬렉션, 테이블 변경: `docs/schema`
- 아키텍처 결정 변경: `docs/adr`
- 운영 절차 변경: `docs/runbook`
- 검증 시나리오 변경: `docs/test-cases`
- 사용자 영향 변경: `docs/changelog` 또는 `CHANGELOG.md`