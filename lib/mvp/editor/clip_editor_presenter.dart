import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:parrokit/mvp/editor/adapters/openai_whisper_adapter.dart';
import 'package:parrokit/mvp/editor/adapters/openai_adapter.dart';
import 'package:parrokit/mvp/editor/adapters/video_picker_files.dart';
import 'package:parrokit/mvp/editor/adapters/video_picker_gallery.dart';
import 'package:parrokit/mvp/editor/ports/asr_port.dart';
import 'package:parrokit/mvp/editor/ports/video_picker_port.dart';
import 'package:parrokit/mvp/editor/services/time_code_service.dart';
import 'package:parrokit/mvp/editor/services/video_meta_service.dart';
import 'package:parrokit/mvp/editor/usecases/extract_duration_usecase.dart';
import 'package:parrokit/mvp/editor/usecases/extract_thumbnail_usecase.dart';
import 'package:parrokit/mvp/editor/usecases/pick_video_usecase.dart';
import 'package:parrokit/mvp/editor/usecases/save_clip_usecase.dart';

import 'package:parrokit/mvp/editor/clip_editor_view.dart';
import 'package:parrokit/mvp/editor/services/file_staging_service.dart';
import 'package:parrokit/mvp/editor/usecases/transcribe_usecase.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parrokit/data/local/pa_database.dart' as db;

class ClipEditorPresenter {
  final ClipEditorView view;
  final MediaProvider mediaProvider;
  final FileStagingService staging;

  static const int _maxDurationMs = 2 * 60 * 1000; // 최대 2분(120초)

  final ExtractThumbnailUseCase _extractThumb;
  final ExtractDurationUseCase _extractDuration;
  final PickVideoUseCase _pickVideo;
  final SaveClipUseCase _saveClip;
  final TranscribeUseCase _transcribe;
  final TimecodeService _timecode;

  ClipEditorPresenter({
    required this.view,
    required this.mediaProvider,
    FileStagingService? staging,
    ExtractThumbnailUseCase? extractThumb,
    ExtractDurationUseCase? extractDuration,
    PickVideoUseCase? pickVideo,
    SaveClipUseCase? saveClip,
    TranscribeUseCase? transcribe,
    TimecodeService? timecode,
  })  : staging = staging ?? FileStagingService(),
        _extractThumb = extractThumb ?? ExtractThumbnailUseCase(VideoMetaServiceImpl()),
        _extractDuration = extractDuration ?? ExtractDurationUseCase(VideoMetaServiceImpl()),
        _pickVideo = pickVideo ?? PickVideoUseCase(files: VideoPickerFiles(), gallery: VideoPickerGallery()),
        _saveClip = saveClip ?? SaveClipUseCase(repo: mediaProvider, staging: staging ?? FileStagingService()),
        _transcribe = transcribe ??
            TranscribeUseCase(
              OpenAIWhisperAdapter(apiKey: dotenv.env['OPENAI_API_KEY']!,
                // 또는 dotenv.env['OPENAI_API_KEY']! 사용
              ),
            ),
        _timecode = timecode ?? TimecodeService();




  /// STT 결과(asr.segments) + LLM JSON(segments)을 UI에 채운다.
  /// - 시간: STT 세그먼트의 start/end를 mm:ss.mmm으로
  /// - 텍스트: LLM 세그먼트의 orig/ko/pron을 각 컨트롤러에 주입
  void _fillSegmentsFromAsrAndDraft({
    required List<dynamic> llmSegments,
    required List<ASRSegment> asrSegments,
  }) {
    final count = (llmSegments.length == asrSegments.length)
        ? llmSegments.length
        : // 길이가 다르면, 더 짧은 쪽에 맞춰 안전하게 채움
    (llmSegments.length < asrSegments.length
        ? llmSegments.length
        : asrSegments.length);

    view.ensureSegmentFormsLength(count);

    for (int i = 0; i < count; i++) {
      final draft = llmSegments[i] as Map;
      final asrSeg = asrSegments[i];

      final start = _timecode.msToMMSSmmm(asrSeg.startMs);
      final end   = _timecode.msToMMSSmmm(asrSeg.endMs);

      final orig = (draft['orig'] ?? '').toString();
      final ko   = (draft['ko']   ?? '').toString();
      final pron = (draft['pron'] ?? '').toString();

      view.setSegmentAt(
        i,
        start: start,
        end: end,
        original: orig,
        pron: pron,
        ko: ko,
      );
    }

    view.refresh();
  }
  /// STT → LLM(세그먼트 초안 JSON) 통합 & UI 채우기
  /// - 업로드된 동영상에서 음성 추출/전사
  /// - 전사 텍스트를 LLM에 전달하여 JSON(원어/번역/발음) 세그먼트 생성
  /// - 결과를 세그먼트 폼(컨트롤러)에 즉시 주입하고 화면 갱신
  void onSttAndDraft() async {
    // 업로드(스테이징)된 영상 경로 확인
    final picked = view.pickedFile;
    if (picked == null || (picked.path ?? '').isEmpty) {
      view.showToastMsg('먼저 영상 파일을 선택해 주세요.');
      return;
    }
    final path = picked.path!;
    view.setSaving(true);

    try {
      // 1) STT (segments 포함)
      final asr = await _transcribe(
        filePath: path,
        language: 'ja', // 일본어 가정
        withSegments: true,
      );
      view.showToastMsg('STT 완료: 세그먼트 ${asr.segments.length}개');

      // 2) LLM 호출 (JSON 강제, 세그먼트 초안 생성)
      final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      if (apiKey.trim().isEmpty) {
        throw Exception('OPENAI_API_KEY가 비어 있습니다.');
      }
      final llm = OpenAIAdapter(apiKey: apiKey);

      // ASR 세그먼트를 그대로 LLM에 넘겨 1:1 개수/순서를 강제
      final asrArray = asr.segments
          .map((s) => {
                'start_ms': s.startMs,
                'end_ms': s.endMs,
                'text': s.text,
              })
          .toList();

      const sys =
          '너는 일본어 대사 텍스트를 한국어 학습자를 위해 세그먼트별로 가공하는 JSON 생성기다. '
          '반드시 입력으로 주어진 asr_segments의 **길이와 순서**를 그대로 유지하며 동일 개수의 출력 세그먼트를 생성한다. '
          '각 출력 세그먼트는 {"orig":"","ko":"","pron":""} 만 포함한다. '
          '규칙: '
          '1) orig: 입력 text를 그대로 사용하되, 필요한 경우 경미한 기호나 띄어쓰기만 수정 가능(내용 변경 금지). '
          '2) ko: 자연스럽고 간결한 **존댓말 번역**. 직역이 어색할 경우 의미 중심으로 부드럽게 표현. '
          '3) pron: 일본어 문장을 **한국어 발음 표기**로 적되, '
          '   가능한 한 실제 발음에 가깝게 히라가나/가타카나를 한국어로 음차한다. '
          '   예: "お願いします!" → "오네가이시마스!", "だよ" → "다요", "なんだから" → "난다카라", "意味ないよ" → "이미 나이요". '
          '   한자어는 일본식 발음을 따르고, 억양이나 장음은 단순 표기로 한다(예: "お兄ちゃん" → "오니이짱"). '
          '금지: 세그먼트 추가/삭제/병합/분할/순서변경/설명/코드블록/주석. '
          '출력은 반드시 **하나의 JSON 객체**만 허용: {"segments":[{"orig":"","ko":"","pron":""}, ...]}';

      final userPrompt =
          '아래 asr_segments와 동일 개수·동일 순서의 segments 배열을 생성하세요. '
          '출력은 {"segments":[...]} 하나의 JSON만 허용됩니다.\n'
          'asr_segments = ${jsonEncode(asrArray)}';

      final jsonStr = await llm.complete(
        systemPrompt: sys,
        userPrompt: userPrompt,
        model: 'gpt-4o-mini',
        timeout: const Duration(seconds: 60),
      );

      // 3) 파싱 & UI 채움 + 콘솔 출력
      final map = jsonDecode(jsonStr);
      final segs = (map is Map && map['segments'] is List) ? (map['segments'] as List) : const [];
      // LLM이 실수로 길이를 다르게 주면(드물지만) 안전하게 보정
      if (segs.length != asr.segments.length) {
        view.showToastMsg('경고: LLM 세그먼트 개수가 STT와 달라 최소 개수로 보정합니다.');
      }
      // 3-1) UI에 세그먼트 주입 (ASR 시간 + LLM 원문/번역/발음)
      if (segs.isNotEmpty && asr.segments.isNotEmpty) {
        _fillSegmentsFromAsrAndDraft(
          llmSegments: segs,
          asrSegments: asr.segments,
        );
        view.showToastMsg('세그먼트 ${segs.length}개 자동 채움');
      }
      for (int i = 0; i < segs.length; i++) {
        final e = segs[i];
        if (e is Map) {
          final orig = (e['orig'] ?? '').toString();
          final ko   = (e['ko'] ?? '').toString();
          final pron = (e['pron'] ?? '').toString();
          // ignore: avoid_print
          print('GPT seg[$i] orig="$orig" | ko="$ko" | pron="$pron"');
        }
      }
      if (segs.isEmpty) {
        // ignore: avoid_print
        print('GPT segments: (empty or invalid JSON)\n$jsonStr');
      }
    } catch (e) {
      view.showToastMsg('통합 STT/번역 실패: $e');
    } finally {
      view.setSaving(false);
    }
  }


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
      if (!TimecodeService.mmssmmm.hasMatch(sText)) {
        view.showToastMsg('세그먼트 ${i + 1}: 시작 시각 형식이 올바르지 않습니다. 예) 00:04.230');
        return null;
      }
      if (!TimecodeService.mmssmmm.hasMatch(eText)) {
        view.showToastMsg('세그먼트 ${i + 1}: 종료 시각 형식이 올바르지 않습니다. 예) 00:05.000');
        return null;
      }
      final start = _timecode.parseToMs(sText);
      final end = _timecode.parseToMs(eText);
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
    if (durationMs > _maxDurationMs) {
      view.showToastMsg('영상 길이는 최대 2분(120초)까지만 허용됩니다.');
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

}
