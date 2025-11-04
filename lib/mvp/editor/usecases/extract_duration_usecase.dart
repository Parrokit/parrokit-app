import 'package:parrokit/mvp/editor/clip_editor_presenter.dart';
import 'package:parrokit/mvp/editor/services/video_meta_service.dart';

class ExtractDurationUseCase {
  final VideoMetaService meta;
  ExtractDurationUseCase(this.meta);
  Future<int?> call(String path) => meta.durationMs(path);
}
