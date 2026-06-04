---
trigger: manual
---

# Naming and Style Rules

## 네이밍

| 타입 | 패턴 | 예시 |
|---|---|---|
| Screen | `{Feature}Screen` | `AuthScreen` |
| Section | `{Name}Section` | `AuthFormSection` |
| Widget | `{Name}{Suffix}` | `ProfileCard` |
| Provider | `{Feature}Provider` | `UserProvider` |
| UseCase | `{Action}{Target}UseCase` | `SaveClipUseCase` |
| Service | `{Name}Service` | `ClipSaveService` |
| Enum | `{Name}Mode/Type/State` | `AuthMode` |
| Model | `{Name}Model` | `UserModel` |
| Entity | `{Name}` | `User` |

## 금지

- 축약어를 사용하지 않는다.
- 의미 없는 단독 이름을 사용하지 않는다.
- 파일명 오타와 혼합 표기를 사용하지 않는다.

## 스타일

- `async` 이후 UI 접근 전 `mounted`를 확인한다.
- import 순서는 `dart:*`, `package:*`, 상대 경로 순서로 유지한다.
- 클래스가 커지면 섹션 주석 또는 파일로 분리한다.