// ============================================================================
// lib/features/_content/clip_editor/data/prompts/prompt_loader.dart
// ============================================================================
//
// [역할]
// assets/prompts/ 폴더의 텍스트 프롬프트 파일을 로드하는 유틸리티.
//
// [레이어]
// Data Layer > Prompts
// ============================================================================

import 'package:flutter/services.dart' show rootBundle;

/// 프롬프트 로더.
/// assets/prompts/ 폴더의 txt 파일을 로드합니다.
class PromptLoader {
  PromptLoader._();

  // ─────────────────────────────────────────────────────────────────
  // STT 초안 생성 프롬프트
  // ─────────────────────────────────────────────────────────────────
  static String? _sttDraftSystem;
  static String? _sttDraftUser;

  /// STT 초안 생성용 시스템 프롬프트를 로드합니다.
  static Future<String> loadSttDraftSystem() async {
    _sttDraftSystem ??=
        await rootBundle.loadString('assets/prompts/stt_draft_system.txt');
    return _sttDraftSystem!;
  }

  /// STT 초안 생성용 유저 프롬프트 prefix를 로드합니다.
  static Future<String> loadSttDraftUser() async {
    _sttDraftUser ??=
        await rootBundle.loadString('assets/prompts/stt_draft_user.txt');
    return _sttDraftUser!;
  }

  // ─────────────────────────────────────────────────────────────────
  // 번역 프롬프트
  // ─────────────────────────────────────────────────────────────────
  static String? _translateSystem;
  static String? _translateUser;

  /// 번역용 시스템 프롬프트를 로드합니다.
  static Future<String> loadTranslateSystem() async {
    _translateSystem ??=
        await rootBundle.loadString('assets/prompts/translate_system.txt');
    return _translateSystem!;
  }

  /// 번역용 유저 프롬프트 prefix를 로드합니다.
  static Future<String> loadTranslateUser() async {
    _translateUser ??=
        await rootBundle.loadString('assets/prompts/translate_user.txt');
    return _translateUser!;
  }

  // ─────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────

  /// 캐시를 클리어합니다 (테스트용).
  static void clearCache() {
    _sttDraftSystem = null;
    _sttDraftUser = null;
    _translateSystem = null;
    _translateUser = null;
  }
}
