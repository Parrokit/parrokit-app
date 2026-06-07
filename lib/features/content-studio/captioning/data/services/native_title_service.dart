// ============================================================================
// lib/features/_content/clip_editor/data/services/native_title_service.dart
// ============================================================================
//
// [역할]
// 원어 작품명 조회 서비스.
// LLM을 통해 작품명의 원어 제목을 조회.
//
// [레이어]
// Data Layer > Services
// ============================================================================

import 'dart:convert';

import '../../domain/native_title_result.dart';
import '../ports/llm_port.dart';
import '../prompts/prompt_loader.dart';

/// 원어 작품명 조회 서비스.
class NativeTitleService {
  final LLMPort llm;

  NativeTitleService(this.llm);

  /// [workName]에 해당하는 원어 작품명을 조회합니다.
  Future<NativeTitleResult> lookup(String workName) async {
    final sys = await PromptLoader.loadNativeTitleSystem();
    final userPrefix = await PromptLoader.loadNativeTitleUser();

    final response = await llm.complete(
      systemPrompt: sys,
      userPrompt: '$userPrefix$workName',
    );

    // JSON 파싱
    try {
      final json = jsonDecode(response) as Map<String, dynamic>;
      return NativeTitleResult.fromJson(json);
    } catch (e) {
      // 파싱 실패 시 원본 응답을 nativeTitle로 사용
      return NativeTitleResult(nativeTitle: response.trim());
    }
  }
}
