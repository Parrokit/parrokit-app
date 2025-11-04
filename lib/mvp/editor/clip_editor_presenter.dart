import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:parrokit/mvp/editor/adapters/video_picker_files.dart';
import 'package:parrokit/mvp/editor/adapters/video_picker_gallery.dart';
import 'package:parrokit/mvp/editor/ports/video_picker_port.dart';
import 'package:parrokit/mvp/editor/services/video_meta_service.dart';
import 'package:parrokit/mvp/editor/usecases/extract_duration_usecase.dart';
import 'package:parrokit/mvp/editor/usecases/extract_thumbnail_usecase.dart';
import 'package:parrokit/mvp/editor/usecases/pick_video_usecase.dart';
import 'package:parrokit/mvp/editor/usecases/save_clip_usecase.dart';

import 'package:parrokit/mvp/editor/clip_editor_view.dart';
import 'package:parrokit/mvp/editor/services/file_staging_service.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:parrokit/data/local/pa_database.dart' as db;

class ClipEditorPresenter {
  final ClipEditorView view;
  final MediaProvider mediaProvider;
  final FileStagingService staging;

  final ExtractThumbnailUseCase _extractThumb;
  final ExtractDurationUseCase _extractDuration;
  final PickVideoUseCase _pickVideo;
  final SaveClipUseCase _saveClip;

  ClipEditorPresenter({
    required this.view,
    required this.mediaProvider,
    FileStagingService? staging,
    ExtractThumbnailUseCase? extractThumb,
    ExtractDurationUseCase? extractDuration,
    PickVideoUseCase? pickVideo,
    SaveClipUseCase? saveClip,
  })  : staging = staging ?? FileStagingService(),
        _extractThumb = extractThumb ?? ExtractThumbnailUseCase(VideoMetaServiceImpl()),
        _extractDuration = extractDuration ?? ExtractDurationUseCase(VideoMetaServiceImpl()),
        _pickVideo = pickVideo ?? PickVideoUseCase(files: VideoPickerFiles(), gallery: VideoPickerGallery()),
        _saveClip = saveClip ?? SaveClipUseCase(repo: mediaProvider, staging: staging ?? FileStagingService());

  // ------- 파일 픽 -------
  Future<void> pickFromSandbox() async {
    final picked = await _pickVideo(PickSource.files);
    if (picked == null) return;
    final (rawPath, pf) = picked;
    final stagedPath = await staging.stageFromPath(rawPath, suggestedName: pf.name);
    final size = pf.size;
    await afterPick(path: stagedPath, name: pf.name, size: size);
  }

  Future<void> pickFromPhotos() async {
    final picked = await _pickVideo(PickSource.gallery);
    if (picked == null) return;
    final (rawPath, pf) = picked;
    final stagedPath = await staging.stageFromPath(rawPath, suggestedName: pf.name);
    final size = pf.size;
    await afterPick(path: stagedPath, name: pf.name, size: size);
  }

  Future<void> afterPick({required String path, required String name, required int size}) async {
    view.setPicked(PlatformFile(name: name, size: size, path: path));
    view.setThumb(null);
    await _setThumb(path);
    final ms = await _probeDurationMs(path);
    if (ms != null) view.setDurationMs(ms);
    view.refresh();
  }

  // ------- 내부 헬퍼 -------
  Future<void> _setThumb(String path) async {
    final bytes = await _extractThumb(path);
    view.setThumb(bytes);
  }

  Future<int?> _probeDurationMs(String path) async {
    return await _extractDuration(path);
  }

  final RegExp mmssmmm = RegExp(r'^\d{2}:\d{2}\.\d{3}$');

  ({String type, String name, String nameNative, String clipTitle, String epiTitle, int? seasonNum, int? epiNumber}) _validateMeta() {
    final name = view.workName.trim();
    final nameNative = view.workNameNative.trim();
    final clipTitle = view.clipTitle.trim();
    final epiTitle = view.epiTitle.trim();
    final type = view.type;

    if (clipTitle.isEmpty) {
      view.showToastMsg('클립 제목은 필수입니다.');
      return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
    }
    if (name.isEmpty) {
      view.showToastMsg('작품명은 필수입니다.');
      return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
    }
    if (nameNative.isEmpty) {
      view.showToastMsg('원어 작품명은 필수입니다.');
      return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
    }
    if (epiTitle.isEmpty) {
      view.showToastMsg(type == 'movie' ? '영화 제목은 필수입니다.' : '회차 제목은 필수입니다.');
      return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
    }

    int? seasonNum, epiNumber;
    if (type == 'season') {
      seasonNum = int.tryParse(view.seasonText.trim());
      epiNumber = int.tryParse(view.episodeText.trim());
      if (seasonNum == null) {
        view.showToastMsg('시즌 번호는 숫자로 필수입니다.');
        return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
      }
      if (epiNumber == null) {
        view.showToastMsg('화 번호는 숫자로 필수입니다.');
        return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
      }
      if (seasonNum <= 0) {
        view.showToastMsg('시즌 번호는 1 이상이어야 합니다.');
        return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
      }
      if (epiNumber <= 0) {
        view.showToastMsg('화 번호는 1 이상이어야 합니다.');
        return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: null, epiNumber: null);
      }
    }

    return (type: type, name: name, nameNative: nameNative, clipTitle: clipTitle, epiTitle: epiTitle, seasonNum: seasonNum, epiNumber: epiNumber);
  }

  List<db.Segment>? _collectAndValidateSegments({required int durationMs}) {
    final seg = <db.Segment>[];
    final inputs = view.segments;
    for (int i = 0; i < inputs.length; i++) {
      final f = inputs[i];
      final sText = f.startCtl.text.trim();
      final eText = f.endCtl.text.trim();
      final ja = f.originalCtl.text.trim();
      final pr = f.pronCtl.text.trim();
      final ko = f.koCtl.text.trim();

      if (sText.isEmpty || eText.isEmpty || ja.isEmpty || pr.isEmpty || ko.isEmpty) {
        view.showToastMsg('세그먼트 ${i + 1}: 시작/끝/원문/발음/번역은 모두 필수입니다.');
        return null;
      }
      if (!mmssmmm.hasMatch(sText)) {
        view.showToastMsg('세그먼트 ${i + 1}: 시작 시각 형식이 올바르지 않습니다. 예) 00:04.230');
        return null;
      }
      if (!mmssmmm.hasMatch(eText)) {
        view.showToastMsg('세그먼트 ${i + 1}: 종료 시각 형식이 올바르지 않습니다. 예) 00:05.000');
        return null;
      }
      final start = _parseNormalizedToMs(sText);
      final end = _parseNormalizedToMs(eText);
      if (end <= start) {
        view.showToastMsg('세그먼트 ${i + 1}: 종료 시각이 시작보다 커야 합니다.');
        return null;
      }
      if (start < 0 || end > durationMs) {
        view.showToastMsg('세그먼트 ${i + 1}: 구간이 영상 길이를 벗어납니다.');
        return null;
      }
      seg.add(db.Segment(
        id: 0,
        clipId: 0,
        startMs: start,
        endMs: end,
        original: ja,
        pron: pr,
        trans: ko,
      ));
    }
    if (seg.isEmpty) {
      view.showToastMsg('세그먼트는 최소 1개 이상 필요합니다.');
      return null;
    }
    seg.sort((a, b) => a.startMs.compareTo(b.startMs));
    for (int i = 1; i < seg.length; i++) {
      final prev = seg[i - 1];
      final cur = seg[i];
      if (cur.startMs < prev.endMs) {
        view.showToastMsg('세그먼트 ${i}와 ${i + 1}이 겹칩니다. 시간을 조정하세요.');
        return null;
      }
    }
    return seg;
  }

  // ------- 저장 -------
  Future<void> save({
    required bool isEdit,
    required int? clipId,
    required PlatformFile? picked,
    String? existingRelPath,
  }) async {
    // 0) 파일 필수
    final stagedPath = picked?.path;
    if (stagedPath == null || stagedPath.isEmpty) {
      view.showToastMsg('영상 파일을 먼저 선택해 주세요.');
      return;
    }

    // 1) 메타 검증/파싱
    final meta = _validateMeta();
    final type = meta.type;
    final name = meta.name;
    final nameNative = meta.nameNative;
    final clipTitle = meta.clipTitle;
    final epiTitle = meta.epiTitle;
    final seasonNum = meta.seasonNum;
    final epiNumber = meta.epiNumber;

    if (clipTitle.isEmpty || name.isEmpty || nameNative.isEmpty || epiTitle.isEmpty) {
      return; // 메시지는 _validateMeta 안에서 처리됨
    }
    if (type == 'season' && (seasonNum == null || epiNumber == null)) {
      return; // 위에서 메시지 처리됨
    }

    // 2) duration
    final durationMs = view.durationMsInput;
    if (durationMs == null || durationMs <= 0) {
      view.showToastMsg('영상 길이(duration)는 필수입니다. 재생 후 자동입력 또는 수동 입력하세요.');
      return;
    }

    // 3) 세그먼트 수집/검증
    final segments = _collectAndValidateSegments(durationMs: durationMs);
    if (segments == null) return; // 메시지는 내부에서 처리됨

    // 4) 파일 상대경로 계산 + 저장 (유스케이스로 위임)
    view.setSaving(true);
    try {
      await _saveClip(
        isEdit: isEdit,
        clipId: clipId,
        type: type,
        name: name,
        nameNative: nameNative,
        clipTitle: clipTitle,
        epiTitle: epiTitle,
        seasonNum: seasonNum,
        epiNumber: epiNumber,
        durationMs: durationMs,
        segments: segments,
        tags: view.tags,
        picked: picked!,
        existingRelPath: existingRelPath,
      );
      view.showToastMsg(isEdit ? '업데이트 완료!' : '저장 완료!');
      await view.closeAfterSaved();
    } catch (e) {
      view.showToastMsg('저장 실패: $e');
    } finally {
      view.setSaving(false);
    }
  }

  // ------- 유틸 -------
  int _parseNormalizedToMs(String normalized) {
    final m = RegExp(r'^(\d{2}):(\d{2})\.(\d{3})$').firstMatch(normalized)!;
    final mm = int.parse(m.group(1)!);
    final ss = int.parse(m.group(2)!);
    final ms = int.parse(m.group(3)!);
    return mm * 60000 + ss * 1000 + ms;
  }
}
