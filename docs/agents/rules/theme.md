---
trigger: always_on
---

# Theme Rules

## 기본 원칙

- UI 색상과 텍스트 스타일은 `Theme.of(context)`를 우선 사용한다.
- 색상은 `Theme.of(context).colorScheme`에서 먼저 찾는다.
- 텍스트 스타일은 `Theme.of(context).textTheme`에서 먼저 찾는다.
- `Theme.of(context)`에 없는 커스텀 값만 `AppTheme`에서 사용한다.
- 필요한 값이 `Theme.of(context)`와 `AppTheme`에 모두 없으면 `AppTheme`에 토큰을 추가한 뒤 사용한다.
- `Color(...)`, `Colors.xxx`, 임의 hex 색상 하드코딩은 금지한다.

## 우선순위

1. `Theme.of(context).colorScheme`
2. `Theme.of(context).textTheme`
3. `AppTheme`
4. 하드코딩 금지

## 금지 예시

```dart
color: Colors.blue
color: Color(0xFF3B82F6)
style: TextStyle(fontSize: 18, color: Colors.black)
```

## 권장 예시

```dart
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final textTheme = theme.textTheme;

Text(
  'Title',
  style: textTheme.titleLarge,
)

Icon(
  Icons.check,
  color: colorScheme.primary,
)
```

## AppTheme 사용 예시

```dart
Container(
  color: AppTheme.communityNoticeBackgroundColor,
)
```

## 추가 규칙

- `AppTheme`은 `Theme.of(context)`에 없는 프로젝트 전용 토큰에만 사용한다.
- 같은 색상, 간격, 스타일이 2회 이상 반복되면 `AppTheme`에 분리한다.
- Widget 내부에 색상, 폰트, 간격 값을 직접 쓰지 않는다.
- 일회성 디버그 색상은 허용하되 커밋 전 제거한다.
- BottomSheet 구현 시 드래그 핸들을 위젯 내부 코드로 직접 하드코딩하여 그리지 않는다. BottomSheetThemeData에서 글로벌로 제공되고 있다.