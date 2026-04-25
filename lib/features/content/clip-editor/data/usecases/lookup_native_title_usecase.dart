// ============================================================================
// lib/features/_content/clip_editor/data/usecases/lookup_native_title_usecase.dart
// ============================================================================
//
// [역할]
// 원어 작품명 조회 UseCase.
// NativeTitleService를 통해 작품명의 원어 제목을 조회.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import 'package:parrokit/features/content/clip-editor/domain/native_title_result.dart';
import '../services/native_title_service.dart';

/// 원어 작품명 조회 UseCase.
class LookupNativeTitleUseCase {
  final NativeTitleService service;

  LookupNativeTitleUseCase(this.service);

  /// [workName]에 해당하는 원어 작품명을 조회합니다.
  Future<NativeTitleResult> call({required String workName}) {
    return service.lookup(workName);
  }
}
