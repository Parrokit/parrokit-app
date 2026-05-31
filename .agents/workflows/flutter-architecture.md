---
description: MVVM + Clean Architecture 원칙 및 레이어 구조
---

# 아키텍처 가이드

## 원칙

이 프로젝트는 MVVM + Clean Architecture를 기준으로 한다.

1. UI 로직은 `presentation`, 비즈니스 로직은 `data/services` 또는 `domain`에 둔다.
2. `domain`은 순수 Dart만 사용한다.
3. `usecase`는 얇게 유지하고 실제 로직은 service로 위임한다.
4. 화면은 `screen -> view model -> section/widget` 흐름을 유지한다.

## 권장 구조

```
features/{feature_name}/
├── domain/       # 순수 Dart: 상태/규칙/validator
├── data/         # usecases, services, adapters, ports
└── presentation/ # screen, view_model, sections, widgets
```

## 레이어 책임

| 레이어 | 역할 | 의존성 |
|--------|------|--------|
| Domain | 비즈니스 규칙, 모델, 검증 | Flutter 의존 금지 |
| Data | 저장/조회/처리, UseCase/Service | Domain 의존 |
| Presentation | 화면/상태/상호작용 | Domain + Data 의존 |

## 구현 체크리스트

1. `domain`에 `package:flutter/*`, `dart:io` import가 없는지 확인.
2. `usecase`가 orchestration만 하고 service로 위임하는지 확인.
3. ViewModel이 비대하면 mixin 또는 파일 분리.
4. Widget에 비즈니스 조건문이 늘어나면 ViewModel/service로 이동.
