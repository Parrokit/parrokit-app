# Sentence 모음집/리마인더 기능 FRD (초안)

## 1. 목적
사용자가 학습하고 싶은 문장을 별도 모음집으로 저장하고, 설정한 주기/패턴에 따라 알림을 받아 반복 학습(쉐도잉/암기)을 지속할 수 있도록 한다.

## 2. 문제 정의
- 현재 컬렉션 영상 기반 학습에서 문장만 따로 축적/재활용하는 흐름이 약하다.
- 사용자가 복습 주기를 직접 통제할 알림 시스템이 없다.

## 3. 범위 (MVP)
### In Scope
- 사용자 개인 `문장 모음집` 생성/조회/수정/삭제
- 문장 직접 입력 추가
- 컬렉션 영상의 `Segments` 문장 단위에서 모음집으로 추가
- 문장별 메타데이터(출처, 난이도, 태그 등 최소 필드) 저장
- FCM 기반 리마인더 알림 발송
- 알림 주기/패턴 설정(고정 주기, 랜덤)
- 알림 on/off 및 시간대 설정

### Out of Scope
- 고급 spaced repetition 알고리즘
- AI 자동 난이도 분류
- 다자간 공유 모음집
- 외부 캘린더 양방향 동기화

## 4. 핵심 사용자 플로우
1. 사용자가 문장 모음집 화면 진입
2. `직접 입력` 또는 `Segments에서 추가`로 문장 저장
3. 리마인더 설정에서 주기/패턴/시간대 선택
4. FCM 토큰 등록 및 알림 수신 동의 확인
5. 설정 주기에 따라 알림 수신 후 문장 복습 진입

## 5. 기능 요구사항 (FR)
- FR-SENT-01: 사용자는 문장 모음집을 생성/수정/삭제할 수 있어야 한다.
- FR-SENT-02: 사용자는 문장을 직접 입력해 모음집에 추가할 수 있어야 한다.
- FR-SENT-03: 사용자는 컬렉션 영상의 `Segments` 단위 문장을 모음집에 추가할 수 있어야 한다.
- FR-SENT-04: 동일 문장 중복 추가 시 중복 허용/병합 정책을 적용할 수 있어야 한다(초기값: 병합 권장).
- FR-SENT-05: 문장 항목은 최소 `text`, `sourceType(manual|segment)`, `sourceRefId`, `createdAt`를 저장해야 한다.
- FR-SENT-06: 사용자는 리마인더 알림을 켜고 끌 수 있어야 한다.
- FR-SENT-07: 사용자는 알림 패턴을 최소 `interval`(예: n시간/일), `random`으로 설정할 수 있어야 한다.
- FR-SENT-08: 사용자는 알림 허용 시간대(예: 09:00~22:00)를 설정할 수 있어야 한다.
- FR-SENT-09: 알림 발송은 FCM을 사용하며 사용자 디바이스 토큰 상태를 관리해야 한다.
- FR-SENT-10: 알림 탭 시 모음집 또는 해당 문장 복습 화면으로 딥링크 이동해야 한다.

## 6. 데이터 계약(초안)
### SentenceCollection
- sentenceCollectionId: string
- ownerUserId: string
- title: string
- description: string?
- createdAt: timestamp
- updatedAt: timestamp

### SentenceItem
- sentenceItemId: string
- sentenceCollectionId: string
- text: string
- sourceType: enum(`manual`, `segment`)
- sourceRefId: string?
- sourceCollectionId: string?
- sourceSegmentId: string?
- tags: string[]?
- difficulty: string?
- createdAt: timestamp
- updatedAt: timestamp

### ReminderSetting
- ownerUserId: string
- enabled: bool
- patternType: enum(`interval`, `random`)
- intervalMinutes: number?
- randomCountPerDay: number?
- timeWindowStart: string(`HH:mm`)
- timeWindowEnd: string(`HH:mm`)
- timezone: string
- updatedAt: timestamp

### DeviceToken
- ownerUserId: string
- fcmToken: string
- platform: enum(`ios`, `android`, `web`)
- isActive: bool
- updatedAt: timestamp

## 7. 알림/스케줄링 요구사항
- 서버는 사용자 `ReminderSetting`을 기준으로 알림 대상 큐를 생성해야 한다.
- `interval` 패턴은 설정 간격 기준으로 발송 시점을 계산한다.
- `random` 패턴은 사용자의 허용 시간대 내 무작위 시점으로 일일 n회를 발송한다.
- 동일 시점 중복 발송 방지를 위한 dedupe 키를 사용한다.
- FCM 실패 토큰(`NotRegistered` 등)은 비활성 처리한다.

## 8. 예외/에러 규칙
- 알림 권한 거부 시 설정 저장은 가능하되, 수신 불가 안내를 표시한다.
- 비어 있는 문장/최대 길이 초과 입력은 검증 에러를 반환한다.
- 참조 Segment가 삭제된 경우 기존 저장 문장은 유지하되 출처 링크는 비활성화한다.
- FCM 전송 실패 시 재시도 정책(최대 횟수/백오프)을 적용한다.

## 9. 비기능 요구사항 (NFR)
- NFR-SENT-01: 직접 입력 저장은 네트워크 불안정 환경에서도 로컬 우선으로 빠르게 완료되어야 한다.
- NFR-SENT-02: 알림 스케줄 계산은 사용자 시간대(Timezone)를 정확히 반영해야 한다.
- NFR-SENT-03: 알림 로그(발송 시각, 결과 코드)를 최소 기간 보관해 운영 추적이 가능해야 한다.
- NFR-SENT-04: 개인정보 최소 수집 원칙에 따라 문장/토큰 접근 권한을 제한해야 한다.

## 10. 수용 기준 (AC)
- AC-SENT-01: 사용자는 문장을 직접 입력해 모음집에 저장할 수 있다.
- AC-SENT-02: 사용자는 `Segments` 문장을 모음집에 추가할 수 있다.
- AC-SENT-03: 알림 패턴을 `interval` 또는 `random`으로 선택/저장할 수 있다.
- AC-SENT-04: 설정된 시간대 내에서 FCM 알림이 발송된다.
- AC-SENT-05: 알림 탭 시 해당 복습 진입 화면으로 이동한다.

## 11. 오픈 이슈
- 문장 최대 길이/최소 길이 정책 확정 필요
- 중복 문장 병합 기준(완전일치/정규화일치) 확정 필요
- 랜덤 패턴의 일일 최대 발송 횟수 상한 확정 필요
- 알림 콘텐츠 로컬라이징 전략 확정 필요

## 12. 변경 이력
- 2026-06-01: 초안 작성 (문장 모음집 + FCM 리마인더 요구사항)
