import 'dart:typed_data';
import 'package:parrokit/features/editor/services/video_meta_service.dart';

class ExtractThumbnailUseCase {
  final VideoMetaService meta;
  ExtractThumbnailUseCase(this.meta);
  Future<Uint8List?> call(String path) => meta.thumbnail(path);
}
