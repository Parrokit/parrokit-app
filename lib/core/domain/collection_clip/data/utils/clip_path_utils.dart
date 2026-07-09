// ============================================================================
// lib/core/collection_media/data/utils/clip_path_utils.dart
// ============================================================================
//
// [역할]
// Clip 파일/썸네일 경로 계산을 위한 순수 정적 유틸리티. db, 네트워크 등
// 어떤 서비스에도 의존하지 않습니다.
//
// [레이어]
// Core > Collection Media > Data > Utils
// ============================================================================

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ClipPathUtils {
  ClipPathUtils._();

  /// clip.filePath가 상대경로라면 App Documents와 합쳐 절대경로로 변환.
  static Future<String> absolutePathFor(String pathFromClip) async {
    if (pathFromClip.startsWith('/')) return pathFromClip;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$pathFromClip';
  }

  static Future<int> fileSizeFor(String pathFromClip) async {
    try {
      final abs = await absolutePathFor(pathFromClip);
      final f = File(abs);
      if (await f.exists()) {
        return await f.length();
      }
    } catch (_) {}
    return 0;
  }

  static String normalizedVideoExtension(String? extensionHint) {
    final raw = (extensionHint ?? '').trim();
    if (raw.isEmpty) return '.mp4';
    return raw.startsWith('.') ? raw : '.$raw';
  }

  static Future<String> defaultCachePathForClip({
    required int clipId,
    required String remoteDocId,
    String? extensionHint,
  }) async {
    final ext = normalizedVideoExtension(extensionHint);
    return 'media/cache/$remoteDocId/clip_$clipId$ext';
  }

  static Future<String> defaultSourcePathForClip({
    required int clipId,
    required String title,
    required String remoteDocId,
    String? extensionHint,
  }) async {
    final ext = normalizedVideoExtension(extensionHint);
    final safeTitle = title.trim().isEmpty
        ? 'clip_$clipId'
        : title.replaceAll(RegExp(r'[^A-Za-z0-9가-힣._-]+'), '_');
    return 'media/local/${safeTitle}_$remoteDocId$ext';
  }

  static String buildDriveFileName(String absPath) {
    final extension = p.extension(absPath);
    return 'video${extension.isEmpty ? '.mp4' : extension}';
  }

  static String extensionOf(String path) => p.extension(path);
}
