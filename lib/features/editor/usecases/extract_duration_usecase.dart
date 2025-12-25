import 'package:parrokit/features/editor/services/video_meta_service.dart';

class ExtractDurationUseCase {
  final VideoMetaService meta;
  ExtractDurationUseCase(this.meta);
  Future<int?> call(String path) => meta.durationMs(path);
}
