---
description: Flutter Clean Architecture 코드 스타일 가이드
---

# Flutter 코드 스타일 가이드

## 아키텍처 개요

이 프로젝트는 **MVVM + Clean Architecture** 를 기반으로 구성됨.

### 왜 이 구조인가?
- **관심사 분리**: UI, 비즈니스 로직, 데이터 처리를 명확히 분리
- **테스트 용이성**: 각 레이어를 독립적으로 테스트 가능
- **유지보수성**: 한 곳의 변경이 다른 곳에 영향 최소화
- **확장성**: 새 기능 추가 시 일관된 패턴 적용

---

## 전체 디렉터리 구조

```
lib/
├── core/                    # 🔧 전역 공통 코드
│   ├── config/              # 앱 설정
│   ├── provider/            # 전역 Provider (theme, auth, iap 등)
│   ├── repositories/        # Repository 추상화/구현
│   ├── services/            # 외부 서비스 (Firebase 등)
│   ├── router/              # 라우팅 설정
│   ├── theme/               # 디자인 시스템
│   └── utils/               # 유틸리티 함수
│
├── data/                    # 💾 데이터 레이어 (전역)
│   ├── local/               # 로컬 DB (Drift)
│   ├── models/              # 공통 데이터 모델
│   └── constants/           # 상수 정의
│
└── features/                # 🎯 기능별 모듈 (MVVM + Clean Architecture)
    ├── auth/
    ├── dashboard/
    ├── library/
    └── ...
```

---

## Features 내부 구조 (기능별 Clean Architecture)

각 feature는 **domain → data → presentation** 3개 레이어로 구성:

```
features/{feature_name}/
├── domain/              # 📐 도메인 레이어
│   ├── {name}_mode.dart     # enum, 상태 정의
│   └── {name}_entity.dart   # 순수 비즈니스 모델
│
├── data/                # 💽 데이터 레이어 (선택)
│   ├── {name}_repository.dart     # Repository 구현
│   └── {name}_data_source.dart    # 로컬/원격 데이터 소스
│
└── presentation/        # 🎨 프레젠테이션 레이어
    ├── {feature}_screen.dart      # 메인 화면 (View)
    ├── sections/                  # 화면 전용 빌드 위젯
    └── widgets/                   # 순수 재사용 위젯
```

### 레이어별 역할

| 레이어 | 역할 | 의존성 |
|--------|------|--------|
| **Domain** | 비즈니스 규칙, 순수 모델 | 없음 (가장 안쪽) |
| **Data** | 데이터 저장/조회 구현 | Domain에만 의존 |
| **Presentation** | UI, 사용자 인터랙션 | Domain, Data에 의존 |

---

## Sections vs Widgets 구분

### 🤔 왜 나누는가?

Flutter에서 화면을 만들 때 `_buildXxx()` 메서드로 UI 조각을 분리하는 경우가 많음:

```dart
// ❌ 문제점: 화면 파일이 비대해지고, 재사용이 어려움
class _MyScreenState extends State<MyScreen> {
  Widget _buildHeader() { ... }
  Widget _buildUserCard() { ... }
  Widget _buildForm() { ... }
  Widget _buildFooter() { ... }
  // 수백 줄...
}
```

이를 해결하기 위해 **sections**와 **widgets**로 분리:

### 📁 sections/ - 화면 전용 빌드 위젯

**정의**: 특정 화면에서만 사용하는 UI 조각. `_buildXxx()` 메서드를 위젯으로 추출.

**특징**:
- 해당 화면에서만 사용 (다른 화면에서 재사용 X)
- 부모로부터 상태와 콜백을 주입받음
- StatelessWidget으로 구현 (자체 상태 없음)
- 화면의 "섹션"을 담당

**예시**:
```dart
// sections/auth_form_section.dart
// AuthScreen에서만 사용하는 로그인/회원가입 폼
class AuthFormSection extends StatelessWidget {
  final AuthMode mode;
  final VoidCallback onSubmit;
  // ...
}
```

**사용 시점**:
- `_buildXxx()` 메서드가 50줄 이상일 때
- 한 화면 내에서 논리적으로 구분되는 영역
- 화면 파일을 200줄 이내로 유지하고 싶을 때

### 📁 widgets/ - 순수 재사용 위젯

**정의**: 여러 화면에서 재사용 가능한 독립적인 UI 컴포넌트.

**특징**:
- 앱 전체에서 재사용 가능
- 특정 화면/기능에 의존하지 않음
- 범용적인 인터페이스 (콜백, 데이터만 받음)

**예시**:
```dart
// widgets/auth_tab.dart
// 어디서든 탭 UI가 필요하면 사용 가능
class AuthTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
}
```

**사용 시점**:
- 2개 이상의 화면에서 사용될 때
- 독립적으로 동작할 수 있을 때
- 디자인 시스템의 일부일 때

### 비교

| 구분 | sections/ | widgets/ |
|------|-----------|----------|
| 재사용 범위 | 해당 화면만 | 앱 전체 |
| 상태 관리 | 부모에게 위임 | 자체 또는 부모 위임 |
| 네이밍 | `{Name}Section` | `{Name}Card`, `{Name}Tab` 등 |
| 목적 | 화면 분할 | 컴포넌트 재사용 |

---

## 파일 상단 주석 템플릿

```dart
// ============================================================================
// lib/features/{feature}/presentation/{file_name}.dart
// ============================================================================
//
// [역할]
// {파일 목적 한 줄 설명}
//
// [레이어]
// {Domain/Data/Presentation} Layer > {하위 분류: Sections/Widgets}
// - {추가 설명}
//
// [구성 요소] (선택)
// - {하위 컴포넌트 나열}
// ============================================================================
```

---

## 클래스 내부 섹션 구분

```dart
class _MyScreenState extends State<MyScreen> {
  // ─────────────────────────────────────────────────────────────────
  // 상태 & 컨트롤러
  // ─────────────────────────────────────────────────────────────────
  
  // ─────────────────────────────────────────────────────────────────
  // Provider 접근
  // ─────────────────────────────────────────────────────────────────
  
  // ─────────────────────────────────────────────────────────────────
  // Actions (비즈니스 로직 호출)
  // ─────────────────────────────────────────────────────────────────
  
  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────
}
```

---

## async/Provider 패턴

```dart
Future<void> _onAction() async {
  // ✅ async gap 전에 Provider 캡처
  // context.read를 await 전에 호출하여 변수에 저장
  final myProvider = context.read<MyProvider>();
  
  await myProvider.doSomething();
  
  // ✅ async 후 mounted 체크
  // 위젯이 dispose된 경우 context 접근 방지
  if (!mounted) return;
  _showToast('완료');
}
```

---

## Docstring 스타일

```dart
/// 메서드 설명 (한 줄)
///
/// [패턴] 특수 패턴 사용 시 설명
/// - 상세 설명 1
/// - 상세 설명 2
///
/// [param] 파라미터 설명
```

---

## 네이밍 규칙

| 타입 | 패턴 | 예시 |
|------|------|------|
| Screen | `{Feature}Screen` | `AuthScreen` |
| Section | `{Name}Section` | `AuthFormSection` |
| Widget | `{Name}Card/Tab/...` | `CoinPackageCard` |
| Provider | `{Feature}Provider` | `UserProvider` |
| enum | `{Name}Mode/Type` | `AuthMode` |
| Model | `{Name}` 또는 `{Name}Entity` | `CoinPackage` |

---

## 일관성 유지 원칙

### 🎯 코드 일관성이 중요한 이유
- 새 개발자가 빠르게 온보딩 가능
- 코드 리뷰 시간 단축
- 예측 가능한 코드 → 버그 감소

### ✅ 일관성 체크리스트

1. **디렉터리 구조**: 새 feature 추가 시 기존 feature 구조 복사
2. **파일 주석**: 모든 파일에 상단 주석 템플릿 적용
3. **클래스 섹션 구분**: `// ─────` 구분선 일관되게 사용
4. **네이밍**: 위 네이밍 규칙 준수
5. **async 패턴**: Provider 캡처 + mounted 체크 패턴 적용
6. **import 순서**: dart → package → relative

### 📋 새 파일 생성 시 템플릿으로 시작

기존 유사 파일을 복사 후 수정하는 방식 권장:
```
새 Section 만들기 → auth_form_section.dart 복사 후 수정
새 Widget 만들기 → auth_tab.dart 복사 후 수정
새 Screen 만들기 → auth_screen.dart 복사 후 수정
```

---

## core/ 모듈화 가이드라인

### 🔄 언제 core/로 이동하는가?

**규칙: 2개 이상의 feature에서 사용될 것 같으면 core/로 모듈화**

### 판단 기준

| 상황 | 위치 | 예시 |
|------|------|------|
| 1개 feature에서만 사용 | `features/{feature}/` | AuthFormSection |
| 2개+ feature에서 사용 | `core/` 또는 `shared/` | showToast, BaseCard |
| 앱 전체 상태 관리 | `core/provider/` | ThemeProvider, UserProvider |
| 외부 API 호출 | `core/services/` | FirebaseAuthService |
| 데이터 저장소 패턴 | `core/repositories/` | UserRepository |
| 공통 UI 컴포넌트 | `shared/widgets/` | PaButton, PaCard |
| 유틸리티 함수 | `core/utils/` | formatDate, showToast |

### core/ 하위 폴더별 역할

```
core/
├── config/          # 앱 설정 (환경변수, 상수)
│   └── app_config.dart
│
├── provider/        # 전역 상태 관리 (앱 전체에서 사용)
│   ├── theme_provider.dart
│   ├── user_provider.dart
│   └── iap_provider.dart
│
├── repositories/    # Repository 패턴 (데이터 접근 추상화)
│   └── user_repository.dart
│
├── services/        # 외부 서비스 래퍼 (Firebase, API 등)
│   └── firebase_auth_service.dart
│
├── router/          # 라우팅 설정
│   └── pa_router.dart
│
├── theme/           # 디자인 시스템
│   ├── pa_theme.dart
│   └── components/
│
└── utils/           # 유틸리티 함수 (순수 함수, 헬퍼)
    ├── show_toast.dart
    └── format_utils.dart
```

### 📦 모듈화 체크리스트

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

### 예시: 코드 위치 결정

```
Q: 토스트 메시지 표시 함수
→ 여러 화면에서 사용 → core/utils/show_toast.dart ✅

Q: 로그인 폼 섹션
→ AuthScreen에서만 사용 → features/auth/presentation/sections/ ✅

Q: "좋아요" 버튼 위젯
→ 여러 화면에서 사용 예상 → shared/widgets/like_button.dart ✅

Q: 사용자 정보 Provider
→ 앱 전역 상태 → core/provider/user_provider.dart ✅

Q: 클립 편집 상태 Provider
→ ClipEditorScreen에서만 사용 → features/editor/clip_editor_provider.dart ✅
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

