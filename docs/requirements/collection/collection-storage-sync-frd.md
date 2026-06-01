# Collection 저장/동기화 기능 FRD (초안)

## 1. 목적
컬렉션 데이터를 현재 로컬 저장 중심 구조에서 클라우드(Firebase)까지 확장해, 백업/복구/멀티디바이스 연속성을 제공한다.

## 2. 문제 정의
- 현재 컬렉션이 로컬에만 저장되어 앱 삭제/기기 변경 시 데이터 유실 위험이 있다.
- 향후 스토리지 비용/운영 전략에 따라 Firebase 또는 S3를 선택할 수 있는 구조적 유연성이 부족하다.

## 3. 범위 (MVP)
### In Scope
- 로컬 저장을 기본으로 유지
- Firebase(Firestore + Storage) 원격 저장 추가
- 로컬/원격 동기화 상태 표시
- 업로드 실패 재시도 큐
- 스토리지 제공자 추상화(`StorageProvider`) 도입
- 컬렉션 메타데이터와 미디어 파일 저장 책임 분리

### Out of Scope
- S3 즉시 도입
- 자동 장기 보관 티어링(예: 30일 후 자동 이전)
- 다중 클라우드 동시 저장
- 실시간 협업 편집 충돌 해결

## 4. 핵심 사용자 플로우
1. 사용자가 컬렉션 생성/편집 완료
2. 앱은 로컬 저장을 즉시 완료
3. 네트워크 가능 시 백그라운드로 Firebase 업로드 시도
4. 업로드 성공 시 `synced` 상태 갱신
5. 실패 시 재시도 큐에 적재하고 사용자에게 상태 표시

## 5. 기능 요구사항 (FR)
- FR-COLSYNC-01: 컬렉션 생성 시 로컬 저장은 항상 우선 성공해야 한다.
- FR-COLSYNC-02: 원격 저장 활성화 계정은 저장 후 Firebase 동기화를 자동 시도해야 한다.
- FR-COLSYNC-03: 동기화 상태를 최소 `local_only`, `syncing`, `synced`, `failed`로 관리해야 한다.
- FR-COLSYNC-04: 동기화 실패 항목은 재시도 큐에 보관하고 수동/자동 재시도할 수 있어야 한다.
- FR-COLSYNC-05: 컬렉션 메타데이터는 Firestore, 미디어 파일은 Storage에 분리 저장해야 한다.
- FR-COLSYNC-06: 앱 재설치/기기 변경 시 Firebase 데이터로 복원할 수 있어야 한다.
- FR-COLSYNC-07: 동일 컬렉션 재업로드는 멱등 처리(중복 생성 방지)해야 한다.
- FR-COLSYNC-08: 스토리지 구현은 `StorageProvider` 인터페이스로 분리해 Firebase/S3 교체 가능해야 한다.
- FR-COLSYNC-09: 사용자는 설정에서 `클라우드 동기화 on/off`를 제어할 수 있어야 한다.
- FR-COLSYNC-10: 동기화 비활성 시에도 로컬 기능은 완전 동작해야 한다.

## 6. 데이터 계약(초안)
### CollectionMeta (Firestore)
- collectionId: string
- ownerUserId: string
- title: string
- description: string?
- mediaCount: number
- createdAt: timestamp
- updatedAt: timestamp
- syncVersion: number
- syncStatus: enum(`local_only`, `syncing`, `synced`, `failed`)

### CollectionAsset (Storage + 메타)
- assetId: string
- collectionId: string
- localUri: string
- remotePath: string?
- remoteUrl: string?
- durationSec: number?
- mimeType: string
- sizeBytes: number
- checksum: string?
- uploadedAt: timestamp?

## 7. 아키텍처 요구사항
- Domain 계층에 `CollectionRepository`, `StorageProvider`, `SyncUsecase`를 정의한다.
- Data 계층에서 `FirebaseStorageProvider`를 기본 구현으로 제공한다.
- 향후 `S3StorageProvider` 추가 시 Domain/API 변경 없이 주입 교체만으로 동작해야 한다.
- UI 계층은 동기화 상태만 표시하고 저장/업로드 비즈니스 로직을 직접 포함하지 않는다.

## 8. 예외/에러 규칙
- 네트워크 실패 시 로컬 저장 성공 상태를 유지하고 원격만 `failed` 처리한다.
- 인증 만료 시 재인증 유도 후 재시도한다.
- 파일 업로드 성공/메타 저장 실패, 메타 성공/파일 실패 등 부분 실패를 감지해 보정 작업을 수행한다.
- 삭제 요청 시 로컬/원격 정합성을 보장하는 순차 삭제 정책을 적용한다.

## 9. 비기능 요구사항 (NFR)
- NFR-COLSYNC-01: 저장 직후 사용자 체감 지연은 로컬 저장 기준으로 최소화해야 한다.
- NFR-COLSYNC-02: 동기화 작업은 앱 재시작 후에도 복구 가능한 큐를 사용해야 한다.
- NFR-COLSYNC-03: 업로드/다운로드 비용 모니터링 지표(파일 수, 총 바이트, 실패율)를 수집해야 한다.
- NFR-COLSYNC-04: 스토리지 접근 권한은 사용자 소유 데이터 최소 권한 원칙을 따라야 한다.

## 10. 수용 기준 (AC)
- AC-COLSYNC-01: 네트워크가 없어도 컬렉션 생성/조회/재생이 정상 동작한다.
- AC-COLSYNC-02: 네트워크 복구 후 실패 큐 항목이 자동 재시도되어 `synced`로 전환된다.
- AC-COLSYNC-03: 새 기기 로그인 시 기존 컬렉션 메타/미디어를 복원할 수 있다.
- AC-COLSYNC-04: 동일 컬렉션의 중복 업로드가 발생하지 않는다.
- AC-COLSYNC-05: 동기화 OFF 상태에서 모든 로컬 기능이 유지된다.

## 11. 비용/운영 의사결정 가이드
- 초기 단계는 Firebase 단일 스택을 기본으로 적용한다.
- 비용 최적화 판단은 월별 실제 사용량(저장량, 다운로드, 요청 수) 기반으로 수행한다.
- S3 도입은 임계치 초과 시 `StorageProvider` 구현 추가로 전환한다.

## 12. 오픈 이슈
- 동기화 충돌 정책(최신 수정 우선 vs 서버 우선) 확정 필요
- 오프라인 기간 중 삭제/수정 혼합 시 우선순위 정책 확정 필요
- S3 전환 임계치(월 비용/트래픽) 수치 확정 필요
- 미디어 암호화(전송/저장) 강제 수준 확정 필요

## 13. 변경 이력
- 2026-06-01: 초안 작성 (컬렉션 로컬+클라우드 동기화 요구사항)
