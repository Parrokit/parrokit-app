---
description: core로 모듈화 및 코드 위치 결정 가이드
---

# 모듈화 가이드

## 기준

2개 이상 feature에서 재사용되면 `core/` 또는 `shared/`로 이동한다.

## 위치 판단표

| 상황 | 위치 | 예시 |
|------|------|------|
| 1개 feature에서만 사용 | `features/{feature}/` | AuthFormSection |
| 2개+ feature에서 사용 | `core/` 또는 `shared/` | showToast, BaseCard |
| 앱 전체 상태 관리 | `core/provider/` | ThemeProvider, UserProvider |
| 외부 API 호출 | `core/services/` | FirebaseAuthService |
| 데이터 저장소 패턴 | `core/repositories/` | UserRepository |
| 공통 UI 컴포넌트 | `shared/widgets/` | PaButton, PaCard |
| 유틸리티 함수 | `core/utils/` | formatDate, showToast |

## 체크리스트

1. 다른 feature에서 재사용 가능성이 있는가?
2. 기존 `core`/`shared`에 유사 구현이 있는가?
3. 앱 전역 상태인가, 화면 로컬 상태인가?
4. 이동 후 import와 테스트를 모두 갱신했는가?
