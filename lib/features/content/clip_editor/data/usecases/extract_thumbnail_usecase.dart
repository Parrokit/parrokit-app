// ============================================================================
// lib/features/_content/editor/data/usecases/extract_thumbnail_usecase.dart
// ============================================================================
//
// [역할]
// 비디오 썸네일 추출 UseCase.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import 'dart:typed_data';
import 'package:parrokit/features/content/clip_editor/data/services/video_meta_service.dart';

class ExtractThumbnailUseCase {
  final VideoMetaService meta;
  ExtractThumbnailUseCase(this.meta);
  Future<Uint8List?> call(String path) => meta.thumbnail(path);
}
