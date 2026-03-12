// ============================================================================
// lib/core/utils/show_toast.dart
// ============================================================================
//
// [역할]
// 앱 전역 토스트 메시지 유틸리티.
// Context 없이 어디서든 호출 가능.
//
// [레이어]
// Core Layer > Utils
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/app.dart';
import 'app_logger.dart';

/// 토스트 메시지 표시.
///
/// Context 없이 전역 scaffoldMessengerKey를 사용합니다.
/// ViewModel, Service 등 어디서든 호출 가능.
void showToast(String msg) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) {
    AppLogger.w('🍞 Toast (no messenger): $msg');
    return;
  }
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 2500),
        margin: const EdgeInsets.fromLTRB(32, 0, 32, 80),
      ),
    );

  AppLogger.d('🍞 Toast: $msg');
}
