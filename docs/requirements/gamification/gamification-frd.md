# Gamification 기능 FRD (초안)

## 1. 목적
학습 지속률을 높이기 위해 RPG 스타일의 일일 퀘스트, 경험치, 티어, 랭킹 시스템을 도입한다.

## 2. 문제 정의
- 학습 기능은 존재하지만 장기 유지 동기를 만드는 보상/경쟁 구조가 약하다.
- 사용자별 학습 루틴(문장 모음집, 쉐도잉, 암기) 실행을 유도할 정량 목표가 필요하다.

## 3. 범위 (MVP)
### In Scope
- 일일 퀘스트 시스템(사용자 개인 목표)
- 퀘스트 완료 보상(경험치)
- 레벨/티어 시스템
- 기본 랭킹 시스템(주간/월간)
- 모음집 기반 퀘스트(예: 하루 n개 복습)
- 쉐도잉/암기 수행 기반 퀘스트 트리거

### Out of Scope
- 실시간 PvP
- 길드/파티 시스템
- 아이템 경제/거래소
- 시즌 패스 유료화

## 4. 핵심 사용자 플로우
1. 사용자가 앱 진입 후 오늘의 퀘스트 확인
2. 모음집 복습/쉐도잉/암기 수행
3. 조건 충족 시 퀘스트 완료 처리 및 XP 획득
4. XP 누적으로 레벨/티어 갱신
5. 랭킹 화면에서 내 순위 확인

## 5. 기능 요구사항 (FR)
- FR-GAME-01: 시스템은 사용자별 일일 퀘스트 목록을 생성해야 한다.
- FR-GAME-02: 퀘스트는 최소 `모음집 복습`, `쉐도잉 수행`, `암기 완료` 타입을 지원해야 한다.
- FR-GAME-03: 퀘스트별 목표 수량(예: n개 완료)을 설정할 수 있어야 한다.
- FR-GAME-04: 목표 달성 시 퀘스트를 완료 처리하고 XP를 지급해야 한다.
- FR-GAME-05: XP 누적치에 따라 사용자 레벨을 계산해야 한다.
- FR-GAME-06: 레벨 구간 또는 점수 구간 기반 티어(예: Bronze/Silver/Gold...)를 부여해야 한다.
- FR-GAME-07: 랭킹은 최소 주간/월간 단위로 제공해야 한다.
- FR-GAME-08: 랭킹 점수 산식은 XP 기반을 기본값으로 하되 확장 가능해야 한다.
- FR-GAME-09: 부정 행위 방지를 위해 동일 이벤트 중복 적립 제한(멱등 처리)을 적용해야 한다.
- FR-GAME-10: 사용자는 퀘스트 진행도와 보상 내역을 확인할 수 있어야 한다.

## 6. 데이터 계약(초안)
### UserProgress
- userId: string
- totalXp: number
- level: number
- tier: string
- updatedAt: timestamp

### DailyQuest
- questId: string
- userId: string
- questType: enum(`collection_review`, `shadowing`, `memorization`)
- targetCount: number
- progressCount: number
- rewardXp: number
- status: enum(`active`, `completed`, `expired`)
- dateKey: string(`YYYY-MM-DD`)
- createdAt: timestamp
- updatedAt: timestamp

### XpLedger
- ledgerId: string
- userId: string
- sourceType: enum(`quest_complete`, `bonus`, `admin_adjust`)
- sourceRefId: string
- xpDelta: number
- createdAt: timestamp

### RankingSnapshot
- snapshotId: string
- periodType: enum(`weekly`, `monthly`)
- periodKey: string
- userId: string
- score: number
- rank: number
- createdAt: timestamp

## 7. 규칙 엔진 요구사항
- 일일 퀘스트는 사용자 시간대 기준으로 일자 경계를 계산해야 한다.
- 만료된 퀘스트는 보상 지급 없이 `expired` 처리한다.
- 퀘스트 완료 이벤트와 XP 적립 이벤트는 트랜잭션 단위로 정합성을 보장해야 한다.
- 동일 수행 로그 재처리 시 중복 XP 지급이 발생하지 않아야 한다.

## 8. 예외/에러 규칙
- 수행 이벤트 원본이 유효하지 않으면 퀘스트 진행도를 증가시키지 않는다.
- 네트워크 지연으로 중복 요청이 들어와도 XP는 1회만 반영해야 한다.
- 랭킹 집계 실패 시 이전 스냅샷을 읽기 전용으로 제공한다.

## 9. 비기능 요구사항 (NFR)
- NFR-GAME-01: 퀘스트 진행도 갱신은 사용자 체감상 즉시 반영되어야 한다.
- NFR-GAME-02: 랭킹 집계 작업은 스케줄 배치로 안정적으로 실행되어야 한다.
- NFR-GAME-03: XP/티어 계산식 변경 시 과거 데이터 재계산 전략을 제공해야 한다.
- NFR-GAME-04: 게임화 데이터는 감사 가능한 적립 이력을 유지해야 한다.

## 10. 수용 기준 (AC)
- AC-GAME-01: 사용자는 매일 새로운 퀘스트 목록을 확인할 수 있다.
- AC-GAME-02: 모음집 복습/쉐도잉/암기 수행 시 퀘스트 진행도가 증가한다.
- AC-GAME-03: 퀘스트 완료 시 XP가 지급되고 레벨/티어가 갱신된다.
- AC-GAME-04: 주간/월간 랭킹에서 사용자 순위를 확인할 수 있다.
- AC-GAME-05: 중복 요청에도 XP 중복 지급이 발생하지 않는다.

## 11. 오픈 이슈
- XP 공식(행동별 가중치) 확정 필요
- 티어 단계 수/강등 정책 확정 필요
- 랭킹 공개 범위(전체/친구/지역) 확정 필요
- 일일 퀘스트 난이도 개인화 적용 시점 확정 필요

## 12. 변경 이력
- 2026-06-01: 초안 작성 (RPG형 퀘스트/XP/티어/랭킹 요구사항)
