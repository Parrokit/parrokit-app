---
description: 네이밍 규칙, 주석 템플릿, 코드 스타일
---

# 네이밍 및 스타일 가이드

## 네이밍 규칙

| 타입 | 패턴 | 예시 |
|------|------|------|
| Screen | `{Feature}Screen` | `AuthScreen` |
| Section | `{Name}Section` | `AuthFormSection` |
| Widget | `{Name}Card/Tab/...` | `CoinPackageCard` |
| Provider | `{Feature}Provider` | `UserProvider` |
| ViewModel | `{Feature}ViewModel` | `ClipEditorViewModel` |
| UseCase | `{Action}{Target}UseCase` | `SaveClipUseCase` |
| Service | `{Name}Service` | `ClipSaveService` |
| enum | `{Name}Mode/Type/State` | `AuthMode`, `EditorSaveState` |
| Model | `{Name}` 또는 `{Name}Entity` | `CoinPackage` |

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
// {Domain/Data/Presentation} Layer > {하위 분류}
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
  // Actions
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
  final myProvider = context.read<MyProvider>();
  
  await myProvider.doSomething();
  
  // ✅ async 후 mounted 체크
  if (!mounted) return;
  showToast('완료');
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

## import 순서

```dart
// 1. dart 내장
import 'dart:async';

// 2. package (Flutter, 외부 패키지)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 3. relative (프로젝트 내부)
import '../domain/editor_state.dart';
import '../data/services/clip_save_service.dart';
```
