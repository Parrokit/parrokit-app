---
trigger: manual
---

# Architecture Rules

## 기본 원칙

- 이 프로젝트는 MVVM + Clean Architecture를 기준으로 한다.
- ViewModel 역할은 Provider가 수행한다.
- 기능 단위 구조는 `data`, `domain`, `presentation`으로 나눈다.
- 비즈니스 로직은 `domain` 또는 `data/services`에 둔다.
- UI 로직은 `presentation`에 둔다.

## 프로젝트 기본 구조

```text
lib/
├── main.dart
├── core/
├── data/
└── features/
```

- `main.dart`는 bootstrap 호출만 담당한다.
- `core`는 앱 전역 공통 코드만 담당한다.
- `data`는 전역 데이터, 공통 모델, 상수 등을 담당한다.
- `features`는 기능별 모듈을 담당한다.

## core 구조

```text
core/
├── config/
├── providers/
├── repositories/
├── services/
├── router/
├── theme/
└── utils/
```

- `config`: 앱 설정
- `providers`: 전역 상태
- `repositories`: 공통 repository 추상화
- `services`: 외부 서비스 wrapper
- `router`: 라우팅
- `theme`: 디자인 시스템
- `utils`: 공통 유틸 함수

## Feature 권장 구조

```text
features/{feature_name}/
├── data/
│   ├── data_sources/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   ├── services/
│   └── validators/
└── presentation/
    ├── screens/
    ├── providers/
    ├── sections/
    └── widgets/
```

## 배치 규칙

- 화면 또는 기능 전용 코드는 `features/{feature_name}`에 둔다.
- 2개 이상 feature에서 공유되는 코드만 `core`로 이동한다.
- 공통 코드라도 feature 전용이면 `core`로 올리지 않는다.
- `main.dart`에는 초기화 세부 로직을 넣지 않고 진입점만 유지한다.

## 레이어 책임

- `domain`은 순수 Dart 규칙, entity, repository interface, usecase, domain service, validator를 담당한다.
- `data`는 data source, model, repository 구현체, 외부 연동 service를 담당한다.
- `presentation`은 screen, provider, section, widget을 담당한다.
- Provider는 ViewModel 역할을 수행하며 상태와 화면 이벤트를 관리한다.

## 의존성 규칙

- `domain`은 Flutter, Firebase, API, 로컬 저장소에 직접 의존하지 않는다.
- `data`는 `domain`에 의존할 수 있다.
- `presentation`은 provider를 통해 usecase를 호출한다.
- 의존 흐름은 `presentation -> provider -> usecase -> service/repository`를 기준으로 유지한다.

## UseCase 규칙

- `usecase`는 하나의 사용자 행동 또는 기능 단위를 담당한다.
- `usecase`는 흐름 제어만 담당하고 복잡한 로직은 service로 위임한다.
- `usecase`에 Firebase, API, UI 코드를 직접 넣지 않는다.

## Service 규칙

- `domain/services`는 순수 비즈니스 로직을 담당한다.
- `data/services`는 외부 연동, 저장소 처리, API 처리, Firebase 처리 등을 담당한다.
- 여러 usecase에서 공유되는 로직은 service로 분리한다.
- provider나 widget에 있는 복잡한 조건문은 service 또는 usecase로 이동한다.

## Validator 규칙

- 검증 로직이 여러 곳에서 반복되면 `domain/validators`로 분리한다.
- UI 입력 표시용 간단한 검증은 provider에서 처리할 수 있다.
- 핵심 비즈니스 규칙 검증은 domain에 둔다.

## Presentation 규칙

- screen은 화면 배치와 provider 연결만 담당한다.
- provider는 상태, 화면 이벤트, notify를 담당한다.
- sections는 화면의 큰 UI 블록을 담당한다.
- widgets는 재사용 가능한 작은 UI 요소를 담당한다.
- widget에는 비즈니스 조건문을 최소화한다.

## 분리 기준

- ViewModel 역할은 `presentation/providers`에 둔다.
- 파일 길이 400줄 초과 또는 public 메서드 15개 초과 시 분리를 검토한다.
- 기능 추가, 수정, 리팩터링은 가능한 한 분리한다.
- 임시 코드, 테스트용 코드, 불필요한 로그는 남기지 않는다.