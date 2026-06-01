# Collection 도메인 개편 및 Feature 이동 FRD (초안)

## 1. 목적
기존 `clip-editor`와 `library` 중심 기능 조합을 `content-studio` 기반 정보구조로 개편하고, `collection` 도메인 책임을 명확히 분리한다.

## 2. 개편 배경
- 현재 자동자막(clip-editor)와 컬렉션 생성 책임이 혼재되어 기능 경계가 불명확하다.
- `library`가 화면 명칭과 도메인 책임을 동시에 갖고 있어 확장 시 구조적 혼선이 발생한다.
- 생성 스튜디오 도입에 맞춰 도메인 기준 네이밍과 경로를 재정렬할 필요가 있다.

## 3. 개편 범위 (MVP)
### In Scope
- 기존 `feature/clip-editor` 기능 중 자동자막 관련 책임을 `content-studio/captioning`으로 이관
- 기존 컬렉션 생성 책임을 `feature/collection/compose`로 이관
- 기존 컬렉션 조회/목록 화면을 `feature/collection/library`로 정렬
- 자동자막 완료 결과가 `collection/compose` 유스케이스로 연결되도록 흐름 재구성
- 라우트 체계 정렬:
  - `/content-studio/hub`
  - `/content-studio/tts`
  - `/content-studio/video`
  - `/content-studio/captioning`
  - `/collection/compose`
  - `/collection/library`

### Out of Scope
- 생성 모델(TTS/Video) 품질 개선
- 컬렉션 추천 알고리즘 고도화
- 대규모 UI 리디자인

## 4. 목표 도메인 구조
- `feature/content-studio/hub`: 제작 진입 허브
- `feature/content-studio/tts`: TTS 생성
- `feature/content-studio/video`: Video 생성
- `feature/content-studio/captioning`: 자동자막 생성/수정/검수
- `feature/collection/compose`: 컬렉션 생성/구성 유스케이스
- `feature/collection/library`: 컬렉션 조회/목록/재생 진입

## 5. 기능 요구사항 (FR)
- FR-COL-01: 자동자막(captioning)은 컬렉션 엔티티를 직접 생성하지 않고 `collection/compose` 유스케이스를 호출해야 한다.
- FR-COL-02: `collection/compose`는 자막 완료 결과(로컬 미디어 URI, 자막 데이터, 메타데이터)를 입력으로 컬렉션 생성을 수행해야 한다.
- FR-COL-03: `collection/library`는 생성된 컬렉션을 조회하고 기존 자동재생 흐름으로 진입할 수 있어야 한다.
- FR-COL-04: 기존 `clip-editor` 경로에서 제공하던 자동자막 진입은 `/content-studio/captioning`으로 리다이렉트되어야 한다.
- FR-COL-05: 기존 `library` feature 진입은 `/collection/library`로 정규화되어야 한다.
- FR-COL-06: 사용자 노출 명칭은 필요 시 `Library`를 유지하되, 코드 경계는 `collection` 도메인 기준으로 통일해야 한다.
- FR-COL-07: 본 작업은 기존 feature(`clip-editor`, `library`)를 신규 도메인 구조로 옮기는 마이그레이션 작업임을 명시해야 한다.

## 6. 비기능 요구사항 (NFR)
- NFR-COL-01: 마이그레이션 이후 기존 사용자 저장 데이터 호환성이 유지되어야 한다.
- NFR-COL-02: 기존 deep link 또는 내부 라우트 참조는 단계적으로 신규 경로로 이행되어야 한다.
- NFR-COL-03: 도메인 경계 분리 후에도 컬렉션 진입/재생 성능 저하가 없어야 한다.
- NFR-COL-04: 기존 경로 사용 시 로그에 마이그레이션 추적 정보(legacy_route -> new_route)를 남겨야 한다.

## 7. 수용 기준 (AC)
- AC-COL-01: 자동자막 완료 후 `collection/compose`를 통해 컬렉션이 정상 생성된다.
- AC-COL-02: 생성된 컬렉션이 `/collection/library`에 노출되고 재생 진입이 가능하다.
- AC-COL-03: 기존 `clip-editor` 진입 경로는 `/content-studio/captioning`으로 정상 리다이렉트된다.
- AC-COL-04: 기존 `library` 진입 경로는 `/collection/library`로 정상 리다이렉트된다.
- AC-COL-05: 코드 구조에서 컬렉션 생성 책임이 `captioning`이 아닌 `collection/compose`에 위치함이 확인된다.

## 8. 마이그레이션 메모
- 1단계: 신규 경로/도메인 추가 및 병행 운영
- 2단계: 기존 `clip-editor`, `library` 직접 로직 제거
- 3단계: 레거시 라우트 정리 및 문서/테스트 케이스 갱신

## 9. 오픈 이슈
- 레거시 경로 폐기 시점(버전) 확정 필요
- `collection/compose` 입력 스키마(필수 필드) 확정 필요
- 리다이렉트 UX(자동 이동 vs 안내 모달) 확정 필요
