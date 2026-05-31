---
description: 네이밍 규칙, 주석 템플릿, 코드 스타일
---

# 네이밍 및 스타일 가이드

## 핵심 네이밍

| 타입 | 패턴 | 예시 |
|------|------|------|
| Screen | `{Feature}Screen` | `AuthScreen` |
| Section | `{Name}Section` | `AuthFormSection` |
| Widget | `{Name}{Suffix}` | `ProfileCard`, `ActionButton` |
| Provider | `{Feature}Provider` | `UserProvider` |
| ViewModel | `{Feature}ViewModel` | `ClipEditorViewModel` |
| UseCase | `{Action}{Target}UseCase` | `SaveClipUseCase` |
| Service | `{Name}Service` | `ClipSaveService` |
| enum | `{Name}Mode/Type/State` | `AuthMode`, `EditorSaveState` |
| Model | `{Name}` 또는 `{Name}Entity` | `CoinPackage` |

## 금지 규칙

1. 축약어 금지: `Btn`, `QA` 사용 금지.
2. 의미 없는 단독 이름 금지: `Badge` 대신 `StatusBadge`.
3. 파일명 오타/혼합 규칙 금지: `thumb_nail` 대신 `thumbnail`.

## 코드 스타일 체크

1. `async` 이후 UI 접근 전 `mounted` 확인.
2. import 순서 유지: `dart:*` -> `package:*` -> 상대 경로.
3. 클래스가 커지면 섹션 주석 또는 파일 분리로 가독성 유지.
