---
description: core로 모듈화 및 코드 위치 결정 가이드
---

# 모듈화 가이드

## 🔄 언제 core/로 이동하는가?

**규칙: 2개 이상의 feature에서 사용될 것 같으면 core/로 모듈화**

---

## 판단 기준

| 상황 | 위치 | 예시 |
|------|------|------|
| 1개 feature에서만 사용 | `features/{feature}/` | AuthFormSection |
| 2개+ feature에서 사용 | `core/` 또는 `shared/` | showToast, BaseCard |
| 앱 전체 상태 관리 | `core/provider/` | ThemeProvider, UserProvider |
| 외부 API 호출 | `core/services/` | FirebaseAuthService |
| 데이터 저장소 패턴 | `core/repositories/` | UserRepository |
| 공통 UI 컴포넌트 | `shared/widgets/` | PaButton, PaCard |
| 유틸리티 함수 | `core/utils/` | formatDate, showToast |

---

## 📦 모듈화 체크리스트

새 코드 작성 시 자문:

1. **"이 코드가 다른 feature에서도 쓰일까?"**
   - Yes → core/ 또는 shared/로
   - No → features/{feature}/ 안에

2. **"이미 비슷한 코드가 core/에 있나?"**
   - Yes → 기존 코드 재사용 또는 확장
   - No → 새로 작성

3. **"이 Provider가 앱 전역 상태인가?"**
   - Yes → core/provider/
   - No → features/{feature}/ 안에 ViewModel로

---

## 예시: 코드 위치 결정

```
Q: 토스트 메시지 표시 함수
→ 여러 화면에서 사용 → core/utils/show_toast.dart ✅

Q: 로그인 폼 섹션
→ AuthScreen에서만 사용 → features/auth/presentation/sections/ ✅

Q: "좋아요" 버튼 위젯
→ 여러 화면에서 사용 예상 → shared/widgets/like_button.dart ✅

Q: 사용자 정보 Provider
→ 앱 전역 상태 → core/provider/user_provider.dart ✅

Q: 클립 편집 상태
→ ClipEditorScreen에서만 사용 → features/clip_editor/presentation/ ✅
```

---

## 리팩토링 시 이동 가이드

### From features/ → To core/

코드가 2개+ feature에서 중복되면:

1. 중복 코드 확인
2. core/ 적절한 폴더로 이동
3. import 경로 업데이트
4. 테스트 확인

```dart
// Before: features/auth/에만 있던 showToast
// After: core/utils/show_toast.dart로 이동

// 사용하는 모든 파일에서 import 변경:
import 'package:parrokit/core/utils/show_toast.dart';
```
