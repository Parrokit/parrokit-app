---
description: MVVM + Clean Architecture 원칙 및 레이어 구조
---

# 아키텍처 가이드

## MVVM + Clean Architecture

이 프로젝트는 **MVVM + Clean Architecture** 를 기반으로 구성됨.

### 왜 이 구조인가?
- **관심사 분리**: UI, 비즈니스 로직, 데이터 처리를 명확히 분리
- **테스트 용이성**: 각 레이어를 독립적으로 테스트 가능
- **유지보수성**: 한 곳의 변경이 다른 곳에 영향 최소화
- **확장성**: 새 기능 추가 시 일관된 패턴 적용

---

## Features 내부 구조 (editor 예시)

```
features/{feature_name}/
├── domain/                      # 📐 도메인 레이어 (순수 Dart, Flutter 의존 X)
│   ├── {name}_mode.dart         # sealed class 모드 정의 (CreateMode, EditMode)
│   ├── {name}_state.dart        # enum 상태 정의 (SaveState, ContentType 등)
│   ├── {name}_form_data.dart    # 순수 데이터 클래스 (UI에서 분리)
│   └── {name}_validator.dart    # 비즈니스 검증 로직
│
├── data/                        # 💽 데이터 레이어
│   ├── usecases/                # UseCase (call만 호출, 로직은 Service에)
│   │   ├── save_{name}_usecase.dart
│   │   ├── load_{name}_usecase.dart
│   │   └── ...
│   ├── services/                # 실제 비즈니스 로직 구현
│   │   ├── {name}_save_service.dart
│   │   ├── {name}_load_service.dart
│   │   ├── file_staging_service.dart
│   │   └── ...
│   ├── adapters/                # 외부 API 구현체 (OpenAI, Whisper 등)
│   ├── ports/                   # 인터페이스 정의 (abstract class)
│   └── prompts/                 # LLM 프롬프트 로더
│
└── presentation/                # 🎨 프레젠테이션 레이어
    ├── {feature}_screen.dart    # 메인 화면 (Provider 생성)
    ├── {feature}_view_model.dart # ViewModel (UI 상태 관리)
    ├── view_model/              # ViewModel Mixin 분리
    │   ├── {feature}_file_mixin.dart
    │   ├── {feature}_segment_mixin.dart
    │   └── ...
    ├── sections/                # 화면 전용 빌드 위젯
    │   ├── sections.dart        # export 배럴 파일
    │   └── ...
    └── widgets/                 # 순수 재사용 위젯
```

---

## 레이어별 역할

| 레이어 | 역할 | 의존성 |
|--------|------|--------|
| **Domain** | 비즈니스 규칙, 순수 모델, Validator | **없음** (Flutter 의존 X) |
| **Data** | 데이터 저장/조회, UseCase, Service | Domain에만 의존 |
| **Presentation** | UI, ViewModel, 사용자 인터랙션 | Domain, Data에 의존 |

---

## UseCase 패턴

UseCase는 **thin wrapper**로, `call` 메서드만 갖고 실제 로직은 Service에 위임:

```dart
// ✅ 좋은 예: call만 호출
class SaveClipUseCase {
  final ClipSaveService _service;
  
  SaveClipUseCase({required ClipSaveService service}) : _service = service;
  
  Future<void> call({...}) => _service.save(...);
}
```

---

## ViewModel Mixin 패턴

ViewModel이 커지면 **Mixin으로 분리**:

```dart
// clip_editor_view_model.dart
class ClipEditorViewModel extends ChangeNotifier
    with
        EditorFileMixin,      // 파일 선택/제거
        EditorSegmentMixin,   // 세그먼트 관리
        EditorTagMixin,       // 태그 관리
        EditorAutocompleteMixin { // 자동완성
  // ...
}
```

각 Mixin은 `ChangeNotifier`를 `on`으로 요구:
```dart
mixin EditorFileMixin on ChangeNotifier {
  // 의존성은 abstract getter로 정의
  FileStagingService get staging;
  
  // 상태와 로직 구현
  PlatformFile? _picked;
  // ...
}
```

---

## Domain Layer 규칙

- **Flutter 의존성 없음** (순수 Dart만)
- `dart:io`, `package:flutter/*` import 금지
- 테스트 시 Flutter 없이 단위 테스트 가능

```dart
// ✅ 좋은 예 - 순수 Dart
class ClipValidator {
  ValidationResult validateForm(ClipFormData data) {
    if (data.titleName.isEmpty) {
      return ValidationResult.invalid('작품명을 입력해주세요.');
    }
    return ValidationResult.valid();
  }
}
```

---

## Screen → ViewModel 연결

```dart
class ClipEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClipEditorViewModel(
        mediaProvider: context.read<MediaProvider>(),
        userProvider: context.read<UserProvider>(),
        titlesDao: context.read<db.AppDatabase>().titlesDao,
        clipId: clipId,
      ),
      child: const _ClipEditorBody(),
    );
  }
}
```
