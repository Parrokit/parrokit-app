---
description: Sections vs Widgets 구분 및 사용 가이드
---

# Sections vs Widgets 가이드

## 🤔 왜 나누는가?

`_buildXxx()` 메서드로 UI 조각을 분리하면 화면 파일이 비대해짐:

```dart
// ❌ 문제점: 화면 파일이 비대해지고, 재사용이 어려움
class _MyScreenState extends State<MyScreen> {
  Widget _buildHeader() { ... }
  Widget _buildUserCard() { ... }
  Widget _buildForm() { ... }
  // 수백 줄...
}
```

이를 해결하기 위해 **sections**와 **widgets**로 분리.

---

## 📁 sections/ - 화면 전용 빌드 위젯

**정의**: 특정 화면에서만 사용하는 UI 조각. `_buildXxx()` 메서드를 위젯으로 추출.

**특징**:
- 해당 화면에서만 사용 (다른 화면에서 재사용 X)
- 부모로부터 상태와 콜백을 주입받음
- StatelessWidget으로 구현 (자체 상태 없음)
- 화면의 "섹션"을 담당

**예시**:
```dart
// sections/auth_form_section.dart
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

---

## 📁 widgets/ - 순수 재사용 위젯

**정의**: 여러 화면에서 재사용 가능한 독립적인 UI 컴포넌트.

**특징**:
- 앱 전체에서 재사용 가능
- 특정 화면/기능에 의존하지 않음
- 범용적인 인터페이스 (콜백, 데이터만 받음)

**예시**:
```dart
// widgets/auth_tab.dart
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

---

## 비교표

| 구분 | sections/ | widgets/ |
|------|-----------|----------|
| 재사용 범위 | 해당 화면만 | 앱 전체 |
| 상태 관리 | 부모에게 위임 | 자체 또는 부모 위임 |
| 네이밍 | `{Name}Section` | `{Name}Card`, `{Name}Tab` 등 |
| 목적 | 화면 분할 | 컴포넌트 재사용 |
