# Community 신고 관리자 웹 기능 FRD (초안)

## 1. 목적
운영자가 커뮤니티 신고를 빠르게 분류/검토/처리할 수 있는 관리자 웹 콘솔을 제공한다.

## 2. 문제 정의
- 모바일 앱만으로는 대량 신고 큐 처리, 필터링, 감사 이력 확인이 비효율적이다.
- 신고 처리 상태와 결과를 일관되게 관리할 운영 전용 화면이 필요하다.

## 3. 범위 (MVP)
### In Scope
- 관리자 인증/권한 기반 신고 콘솔 접근
- 신고 목록 조회 및 상태/유형/기간 필터
- 신고 상세 조회(대상 정보, 사유, 신고 시각)
- 신고 상태 전환: `received -> reviewing -> resolved | rejected`
- 처리 메모/처리자/처리 시각 기록
- 중복 신고 묶음 표시(동일 대상 기준)

### Out of Scope
- 자동 제재 엔진(자동 정지/자동 삭제)
- AI 기반 자동 분류/우선순위 추천
- 법적 요청 대응 전용 백오피스
- CS 응대 티켓 시스템 통합

## 4. 핵심 운영 플로우
1. 관리자가 웹 콘솔 로그인
2. `received` 큐를 오래된 순으로 확인
3. 신고 상세 열람 후 `reviewing` 전환
4. 정책 기준으로 `resolved` 또는 `rejected` 처리
5. 처리 메모 기록 후 다음 신고로 이동

## 5. 기능 요구사항 (FR)
- FR-ADMIN-01: 관리자 권한이 있는 사용자만 신고 콘솔에 접근할 수 있어야 한다.
- FR-ADMIN-02: 신고 목록은 기본적으로 `received` 상태를 우선 노출해야 한다.
- FR-ADMIN-03: 상태(`received/reviewing/resolved/rejected`), 대상 유형, 사유 유형, 기간 필터를 제공해야 한다.
- FR-ADMIN-04: 신고 상세에서 신고자/대상/사유/생성시각/중복 여부를 확인할 수 있어야 한다.
- FR-ADMIN-05: 운영자는 신고 상태를 `reviewing`, `resolved`, `rejected`로 변경할 수 있어야 한다.
- FR-ADMIN-06: 상태 변경 시 `reviewedBy`, `reviewedAt`, `reviewNote`를 저장해야 한다.
- FR-ADMIN-07: 동일 대상에 대한 다중 신고를 묶어 확인할 수 있어야 한다.
- FR-ADMIN-08: 처리 완료된 항목도 감사 목적으로 조회 가능해야 한다.
- FR-ADMIN-09: 운영 액션(상태 변경)은 감사 로그를 남겨야 한다.

## 6. 데이터 계약(관리 콘솔 관점)
### Report (읽기/처리)
- reportId: string
- reporterUserId: string
- targetType: enum(`post`, `comment`, `profile`)
- targetId: string
- targetOwnerUserId: string
- reasonType: enum(`spam`, `harassment`, `sexual_or_violent`, `impersonation`, `other`)
- reasonDetail: string?
- createdAt: timestamp
- status: enum(`received`, `reviewing`, `resolved`, `rejected`)
- reviewedBy: string?
- reviewedAt: timestamp?
- reviewNote: string?

### AdminActionLog (권장)
- logId: string
- actorUserId: string
- reportId: string
- actionType: enum(`status_change`, `note_update`)
- fromStatus: string?
- toStatus: string?
- createdAt: timestamp

## 7. 예외/에러 규칙
- 권한 없는 사용자는 콘솔 접근 시 `403`을 반환해야 한다.
- 이미 `resolved/rejected` 상태인 신고를 중복 처리하려 하면 멱등 응답 또는 경고를 반환해야 한다.
- 동시 처리 충돌 시 최신 상태를 기준으로 재검토를 유도해야 한다.
- 네트워크 실패 시 마지막 필터/스크롤 컨텍스트를 유지한 재시도 기능을 제공해야 한다.

## 8. 비기능 요구사항 (NFR)
- NFR-ADMIN-01: 기본 목록 조회는 운영자가 체감상 즉시 사용할 수 있는 응답 속도를 제공해야 한다.
- NFR-ADMIN-02: 신고 상세의 개인정보/민감정보는 관리자 권한 범위에서만 마스킹 해제 가능해야 한다.
- NFR-ADMIN-03: 모든 상태 변경은 감사 가능한 로그를 남겨야 한다.
- NFR-ADMIN-04: 운영 콘솔 세션은 일정 시간 비활성 시 자동 만료되어야 한다.

## 9. 수용 기준 (AC)
- AC-ADMIN-01: 관리자 권한 계정으로만 신고 콘솔 접근이 가능하다.
- AC-ADMIN-02: `received` 신고 목록을 필터링해 조회할 수 있다.
- AC-ADMIN-03: 신고 상세에서 상태를 `reviewing -> resolved/rejected`로 변경할 수 있다.
- AC-ADMIN-04: 상태 변경 시 처리자/처리시각/메모가 저장된다.
- AC-ADMIN-05: 동일 대상 다중 신고를 묶어서 확인할 수 있다.

## 10. 오픈 이슈
- 관리자 권한 부여 방식(커스텀 클레임/역할 테이블) 확정 필요
- 처리 메모 최대 길이 및 필수 여부 확정 필요
- SLA 지표(예: 평균 1차 검토 시간) 대시보드 포함 여부 확정 필요
- 제재 기능(콘텐츠 블라인드/계정 제한) 연계 시점 확정 필요

## 11. 변경 이력
- 2026-06-01: 초안 작성 (신고 관리자 웹 MVP 요구사항)
