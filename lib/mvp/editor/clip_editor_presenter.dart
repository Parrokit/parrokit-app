import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parrokit/mvp/editor/clip_editor_view.dart';
import 'package:parrokit/mvp/editor/file_staging_service.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:parrokit/data/local/pa_database.dart' as db;
class ClipEditorPresenter {
  final ClipEditorView view;
  final MediaProvider mediaProvider;
  final FileStagingService staging;
  final ImagePicker _picker = ImagePicker();

  ClipEditorPresenter({
    required this.view,
    required this.mediaProvider,
    FileStagingService? staging,
  }) : staging = staging ?? FileStagingService();

  final RegExp mmssmmm = RegExp(r'^\d{2}:\d{2}\.\d{3}$');

  // ------- 파일 픽 -------
  Future<void> pickFromSandbox() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'mkv'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.first;
    if (f.path == null) return;
    final stagedPath = await staging.stageFromPath(f.path!, suggestedName: f.name);
    final size = await File(stagedPath).length();

    await afterPick(path: stagedPath, name: f.name, size: size);
  }

  Future<void> pickFromPhotos() async {
    final x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return;
    final staged = await staging.stageFromPath(x.path, suggestedName: x.name);
    final size = await File(staged).length();

    await afterPick(path: staged, name: x.name, size: size);
  }

  Future<void> afterPick({required String path, required String name, required int size}) async {
    view.setPicked(PlatformFile(name: name, size: size, path: path));
    view.setThumb(null);

    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 256,
        quality: 75,
        timeMs: 0,
      );
      view.setThumb(bytes);
    } catch (e) {
      view.showToastMsg('썸네일 추출 실패: $e');
    }

    try {
      final temp = VideoPlayerController.file(File(path));
      await temp.initialize();
      view.setDurationMs(temp.value.duration.inMilliseconds);
      await temp.dispose();
    } catch (e) {
      view.showToastMsg('길이 추출 실패: $e');
    }
    view.refresh();
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

    // 1) 메타 필수
    final name = view.workName.trim();
    final nameNative = view.workNameNative.trim();
    final clipTitle = view.clipTitle.trim();
    final epiTitle = view.epiTitle.trim();
    final type = view.type;

    if (clipTitle.isEmpty) return view.showToastMsg('클립 제목은 필수입니다.');
    if (name.isEmpty) return view.showToastMsg('작품명은 필수입니다.');
    if (nameNative.isEmpty) return view.showToastMsg('원어 작품명은 필수입니다.');
    if (epiTitle.isEmpty) {
      return view.showToastMsg(type == 'movie' ? '영화 제목은 필수입니다.' : '회차 제목은 필수입니다.');
    }

    int? seasonNum, epiNumber;
    if (type == 'season') {
      seasonNum = int.tryParse(view.seasonText.trim());
      epiNumber = int.tryParse(view.episodeText.trim());
      if (seasonNum == null) return view.showToastMsg('시즌 번호는 숫자로 필수입니다.');
      if (epiNumber == null) return view.showToastMsg('화 번호는 숫자로 필수입니다.');
      if (seasonNum <= 0) return view.showToastMsg('시즌 번호는 1 이상이어야 합니다.');
      if (epiNumber <= 0) return view.showToastMsg('화 번호는 1 이상이어야 합니다.');
    }

    // 2) duration
    int? durationMs = view.durationMsInput;
    if (durationMs == null || durationMs <= 0) {
      return view.showToastMsg('영상 길이(duration)는 필수입니다. 재생 후 자동입력 또는 수동 입력하세요.');
    }

    // 3) 세그먼트 검증
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
        return view.showToastMsg('세그먼트 ${i + 1}: 시작/끝/원문/발음/번역은 모두 필수입니다.');
      }
      if (!mmssmmm.hasMatch(sText)) {
        return view.showToastMsg('세그먼트 ${i + 1}: 시작 시각 형식이 올바르지 않습니다. 예) 00:04.230');
      }
      if (!mmssmmm.hasMatch(eText)) {
        return view.showToastMsg('세그먼트 ${i + 1}: 종료 시각 형식이 올바르지 않습니다. 예) 00:05.000');
      }
      final start = _parseNormalizedToMs(sText);
      final end = _parseNormalizedToMs(eText);
      if (end <= start) {
        return view.showToastMsg('세그먼트 ${i + 1}: 종료 시각이 시작보다 커야 합니다.');
      }
      if (start < 0 || end > durationMs) {
        return view.showToastMsg('세그먼트 ${i + 1}: 구간이 영상 길이를 벗어납니다.');
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
    if (seg.isEmpty) return view.showToastMsg('세그먼트는 최소 1개 이상 필요합니다.');

    seg.sort((a, b) => a.startMs.compareTo(b.startMs));
    for (int i = 1; i < seg.length; i++) {
      final prev = seg[i - 1];
      final cur = seg[i];
      if (cur.startMs < prev.endMs) {
        return view.showToastMsg('세그먼트 ${i}와 ${i + 1}이 겹칩니다. 시간을 조정하세요.');
      }
    }

    // 4) 저장
    view.setSaving(true);
    try {
      // 상대경로
      String relPath;
      if (isEdit && existingRelPath != null && existingRelPath.isNotEmpty && !staging.isInStaging(stagedPath)) {
        // 기존 파일 유지 (편집만)
        relPath = existingRelPath;
      } else {
        relPath = await staging.finalize(stagedPath);
      }

      if (isEdit && clipId != null) {
        await mediaProvider.updateMedia(
          clipId: clipId,
          titleName: name,
          titleNameNative: nameNative,
          type: type,
          seasonNumber: type == 'season' ? seasonNum : null,
          episodeNumber: type == 'season' ? epiNumber : null,
          episodeTitle: epiTitle,
          clipTitle: clipTitle,
          filePath: relPath,
          durationMs: durationMs,
          segments: seg,
          tags: view.tags,
        );
        view.showToastMsg('업데이트 완료!');
      } else {
        await mediaProvider.addMedia(
          titleName: name,
          titleNameNative: nameNative,
          type: type,
          seasonNumber: type == 'season' ? seasonNum : null,
          episodeNumber: type == 'season' ? epiNumber : null,
          episodeTitle: epiTitle,
          clipTitle: clipTitle,
          filePath: relPath,
          durationMs: durationMs,
          segments: seg,
          tags: view.tags,
        );
        view.showToastMsg('저장 완료!');
      }
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
