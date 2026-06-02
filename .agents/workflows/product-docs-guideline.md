---
description: 제품 문서 세트(FRD/API/Schema/ADR/Runbook/Test/Changelog) 작성 및 동기화 규칙
---

# 제품 문서 가이드

## 문서 위치

1. FRD/요구사항: `docs/requirements/`
2. API 명세: `docs/api/`
3. 데이터 스키마: `docs/schema/`
4. 의사결정 기록: `docs/adr/`
5. 운영 절차: `docs/runbook/`
6. 테스트 시나리오: `docs/test-cases/`
7. 변경 이력: `docs/changelog/` 또는 루트 `CHANGELOG.md`

## 파일 권장 형식

1. FRD: `docs/requirements/{feature}-frd.md`
2. API: `docs/api/{domain}-api-spec.md`
3. Schema: `docs/schema/{storage}-schema.md`
4. ADR: `docs/adr/ADR-{yyyyMMdd}-{topic}.md`
5. Runbook: `docs/runbook/{feature}-runbook.md`
6. Test Cases: `docs/test-cases/{feature}-test-cases.md`
7. Changelog: `docs/changelog/{yyyy-MM}.md`

## 최소 템플릿

1. 목적
2. 범위(In/Out)
3. 데이터 계약(요청/응답/필드)
4. 예외/에러 규칙
5. 수용 기준(테스트 가능한 문장)
6. 변경 이력(날짜, 요약)

## 코드 변경 동기화 규칙

1. API/모델/DB 구조가 바뀌면 같은 커밋에서 관련 문서를 함께 수정한다.
2. 설계 방향/트레이드오프가 바뀌면 `docs/adr`를 추가 또는 갱신한다.
3. 배포/운영 방법이 바뀌면 `docs/runbook`을 갱신한다.
4. QA 기준이 바뀌면 `docs/test-cases`를 갱신한다.
5. 사용자 영향 기능 변경은 changelog를 갱신한다.
6. 코드만 바꾸고 문서가 비어 있으면 PR/커밋 전 `문서 반영 여부`를 체크한다.
7. 문서 변경이 불필요한 경우 커밋 메시지 또는 PR 본문에 이유를 한 줄로 남긴다.

## 빠른 체크리스트

1. 엔드포인트 추가/수정/삭제 -> `docs/api` 반영했는가?
2. 기능 요구사항 변경 -> `docs/requirements` 반영했는가?
3. 필드/컬렉션/테이블 변경 -> `docs/schema` 반영했는가?
4. 아키텍처 결정 변경 -> `docs/adr` 반영했는가?
5. 운영/배포/복구 절차 변경 -> `docs/runbook` 반영했는가?
6. 검증 시나리오 변경 -> `docs/test-cases` 반영했는가?
7. 사용자 영향 변경 -> `docs/changelog` 또는 `CHANGELOG.md` 반영했는가?
