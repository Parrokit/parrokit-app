// ============================================================================
// lib/features/editor/presentation/clip_editor_view_model.dart
// ============================================================================
//
// [역할]
// 클립 에디터 ViewModel. Presenter 로직을 ChangeNotifier 패턴으로 통합.
//
// [레이어]
// Presentation Layer - ViewModel
// ============================================================================

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/data/local/app_database.dart' as db;
import 'package:parrokit/data/local/dao/titles_dao.dart';

import '../data/adapters/openai_adapter.dart';
import '../data/adapters/openai_whisper_adapter.dart';
import '../data/adapters/video_picker_files.dart';
import '../data/adapters/video_picker_gallery.dart';
import '../domain/editor_state.dart';
import '../data/ports/asr_port.dart';
import '../data/prompts/prompt_loader.dart';
import '../data/services/audio_to_video.dart';
import '../data/services/file_staging_service.dart';
import '../data/services/time_code_service.dart';
import '../data/services/video_meta_service.dart';
import '../data/usecases/extract_duration_usecase.dart';
import '../data/usecases/extract_thumbnail_usecase.dart';
import '../data/usecases/pick_video_usecase.dart';
import '../data/usecases/save_clip_usecase.dart';

import '../data/usecases/transcribe_usecase.dart';

import 'view_model/editor_file_mixin.dart';
import 'view_model/editor_segment_mixin.dart';
import 'view_model/editor_tag_mixin.dart';
import 'view_model/editor_autocomplete_mixin.dart';

/// 클립 에디터 ViewModel.
/// 클립 에디터 ViewModel.
class ClipEditorViewModel extends ChangeNotifier
    with
        EditorFileMixin,
        EditorSegmentMixin,
        EditorTagMixin,
        EditorAutocompleteMixin {
  ClipEditorViewModel({
    required this.mediaProvider,
    required this.userProvider,
    required this.titlesDao,
    this.clipId,
  }) {
    _init();
  }

  // ─────────────────────────────────────────────────────────────────
  // 의존성
  // ─────────────────────────────────────────────────────────────────
  final MediaProvider mediaProvider;
  final UserProvider userProvider;
  final TitlesDao titlesDao;
  final int? clipId;

  late final FileStagingService staging;
  late final AudioToVideoService audioToVideo;
  late final ExtractThumbnailUseCase extractThumb;
  late final ExtractDurationUseCase extractDuration;
  late final PickVideoUseCase pickVideo;
  late final SaveClipUseCase _saveClip;
  late final TranscribeUseCase _transcribe;
  late final TimecodeService _timecode;

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────

  // Stepper 상태
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // 저장 상태
  EditorSaveState _saveState = EditorSaveState.idle;
  EditorSaveState get saveState => _saveState;
  bool get isSaving => _saveState == EditorSaveState.saving;

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  String? _existingRelPath;
  String? get existingRelPath => _existingRelPath;

  // 메타데이터
  ContentType _contentType = ContentType.season;
  ContentType get contentType => _contentType;

  // TextEditingControllers (View에서 직접 사용)
  final titleCtl = TextEditingController();
  final nameCtl = TextEditingController();
  final nameNativeCtl = TextEditingController(text: '-');
  final seasonCtl = TextEditingController();
  final episodeCtl = TextEditingController();
  final epiTitleCtl = TextEditingController();
  final durationCtl = TextEditingController();
  final tagsCtl = TextEditingController();

  // 토스트 메시지 (View에서 listen)
  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  // 저장 후 닫기 플래그
  bool _shouldClose = false;
  bool get shouldClose => _shouldClose;

  // ─────────────────────────────────────────────────────────────────
  // 초기화
  // ─────────────────────────────────────────────────────────────────
  void _init() {
    staging = FileStagingService();
    audioToVideo = FfmpegAudioToVideoService();
    extractThumb = ExtractThumbnailUseCase(VideoMetaServiceImpl());
    extractDuration = ExtractDurationUseCase(VideoMetaServiceImpl());
    pickVideo = PickVideoUseCase(
      files: VideoPickerFiles(),
      gallery: VideoPickerGallery(),
    );
    _saveClip = SaveClipUseCase(repo: mediaProvider, staging: staging);
    _transcribe = TranscribeUseCase(
      OpenAIWhisperAdapter(apiKey: dotenv.env['OPENAI_API_KEY'] ?? ''),
    );
    _timecode = TimecodeService();

    // 세그먼트 폼 초기화
    initSegmentForms();

    // 편집 모드 로드
    if (clipId != null) {
      _isEdit = true;
      _loadForEdit(clipId!);
    }

    // 작품명 목록 로드
    loadTitleNames();
  }

  // ─────────────────────────────────────────────────────────────────
  // Stepper 제어
  // ─────────────────────────────────────────────────────────────────
  void goToStep(int step) {
    if (step >= 0 && step <= 6) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentStep < 6) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Mixin 로직으로 대체됨
  // pickFromSandbox, pickFromPhotos 등

  // ─────────────────────────────────────────────────────────────────
  // 콘텐츠 타입
  // ─────────────────────────────────────────────────────────────────
  void setContentType(ContentType type) {
    _contentType = type;
    notifyListeners();
  }

  // Mixin 로직으로 대체됨 (세그먼트, 태그 관리)

  // Mixin 로직으로 대체됨 (자동완성)

  // ─────────────────────────────────────────────────────────────────
  // STT + 초안 생성
  // ─────────────────────────────────────────────────────────────────
  Future<void> onSttAndDraft() async {
    if (picked == null || (picked!.path ?? '').isEmpty) {
      showToast('먼저 영상 파일을 선택해 주세요.');
      return;
    }
    final path = picked!.path!;
    _setSaving(true);

    int? durationMs = int.tryParse(durationCtl.text.trim());
    durationMs ??= await extractDuration(path);

    if (durationMs == null || durationMs <= 0) {
      showToast('영상 길이를 확인할 수 없습니다.');
      _setSaving(false);
      return;
    }

    final cost = _calculateCoinCost(durationMs);
    if (cost > 0 && userProvider.coins < cost) {
      showToast('코인이 부족합니다. (필요: $cost, 보유: ${userProvider.coins})');
      _setSaving(false);
      return;
    }

    try {
      // 1) STT
      final asr = await _transcribe(
        filePath: path,
        language: 'ja',
        withSegments: true,
      );
      showToast('STT 완료: 세그먼트 ${asr.segments.length}개');

      // 2) LLM
      final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      if (apiKey.trim().isEmpty) {
        throw Exception('OPENAI_API_KEY가 비어 있습니다.');
      }
      final llm = OpenAIAdapter(apiKey: apiKey);

      final allDraftSegments = <Map<String, dynamic>>[];
      const batchSize = 5;
      final sys = await PromptLoader.loadSttDraftSystem();
      final userPrefix = await PromptLoader.loadSttDraftUser();

      for (int offset = 0; offset < asr.segments.length; offset += batchSize) {
        final batch = asr.segments.sublist(
          offset,
          (offset + batchSize > asr.segments.length)
              ? asr.segments.length
              : offset + batchSize,
        );

        final asrArray = batch
            .map((s) => {
                  'start_ms': s.startMs,
                  'end_ms': s.endMs,
                  'text': s.text,
                })
            .toList();

        final userPrompt = '$userPrefix${jsonEncode(asrArray)}';

        final jsonStr = await llm.complete(
          systemPrompt: sys,
          userPrompt: userPrompt,
          model: 'gpt-4o-mini',
          timeout: const Duration(seconds: 60),
        );

        final map = jsonDecode(jsonStr);
        final segs = (map is Map && map['segments'] is List)
            ? (map['segments'] as List)
            : const [];

        final count = segs.length < batch.length ? segs.length : batch.length;
        for (int i = 0; i < count; i++) {
          final e = segs[i];
          if (e is Map) {
            allDraftSegments.add({
              'orig': (e['orig'] ?? '').toString(),
              'ko': (e['ko'] ?? '').toString(),
              'pron': (e['pron'] ?? '').toString(),
            });
          } else {
            allDraftSegments.add({'orig': '', 'ko': '', 'pron': ''});
          }
        }
      }

      // 3) UI 채움
      if (allDraftSegments.isNotEmpty && asr.segments.isNotEmpty) {
        _fillSegmentsFromAsrAndDraft(
          llmSegments: allDraftSegments,
          asrSegments: asr.segments,
        );
        showToast('세그먼트 ${allDraftSegments.length}개 자동 채움');

        // 코인 차감
        if (cost > 0) {
          userProvider.addCoins(-cost);
          showToast('STT/초안 생성에 코인 $cost개 사용');
        }
      }
    } catch (e) {
      showToast('STT/번역 실패: $e');
    } finally {
      _setSaving(false);
    }
  }

  void _fillSegmentsFromAsrAndDraft({
    required List<dynamic> llmSegments,
    required List<ASRSegment> asrSegments,
  }) {
    final count = llmSegments.length < asrSegments.length
        ? llmSegments.length
        : asrSegments.length;

    ensureSegmentFormsLength(count);

    for (int i = 0; i < count; i++) {
      final draft = llmSegments[i] as Map;
      final asrSeg = asrSegments[i];

      setSegmentAt(
        i,
        start: _timecode.msToMMSSmmm(asrSeg.startMs),
        end: _timecode.msToMMSSmmm(asrSeg.endMs),
        original: (draft['orig'] ?? '').toString(),
        pron: (draft['pron'] ?? '').toString(),
        ko: (draft['ko'] ?? '').toString(),
      );
    }
  }

  int _calculateCoinCost(int durationMs) {
    final seconds = (durationMs / 1000).ceil();
    if (seconds <= 0) return 0;
    return ((seconds + 29) ~/ 30);
  }

  // ─────────────────────────────────────────────────────────────────
  // 저장
  // ─────────────────────────────────────────────────────────────────
  static const int _maxDurationMs = 5 * 60 * 1000;

  Future<void> save() async {
    final stagedPath = picked?.path;
    if (stagedPath == null || stagedPath.isEmpty) {
      showToast('영상 파일을 먼저 선택해 주세요.');
      return;
    }

    final normalizedPath = await audioToVideo.ensureMp4(stagedPath);

    // 메타 검증
    final type = _contentType == ContentType.season ? 'season' : 'movie';
    final name = nameCtl.text.trim();
    final nameNative = nameNativeCtl.text.trim();
    final clipTitle = titleCtl.text.trim();
    final epiTitle = epiTitleCtl.text.trim();

    if (clipTitle.isEmpty) {
      showToast('클립 제목은 필수입니다.');
      return;
    }
    if (name.isEmpty) {
      showToast('작품명은 필수입니다.');
      return;
    }
    if (nameNative.isEmpty) {
      showToast('원어 작품명은 필수입니다.');
      return;
    }
    if (epiTitle.isEmpty) {
      showToast(type == 'movie' ? '영화 제목은 필수입니다.' : '회차 제목은 필수입니다.');
      return;
    }

    int? seasonNum, epiNumber;
    if (type == 'season') {
      seasonNum = int.tryParse(seasonCtl.text.trim());
      epiNumber = int.tryParse(episodeCtl.text.trim());
      if (seasonNum == null || seasonNum <= 0) {
        showToast('시즌 번호는 1 이상의 숫자로 필수입니다.');
        return;
      }
      if (epiNumber == null || epiNumber <= 0) {
        showToast('화 번호는 1 이상의 숫자로 필수입니다.');
        return;
      }
    }

    final durationMs = int.tryParse(durationCtl.text.trim());
    if (durationMs == null || durationMs <= 0) {
      showToast('영상 길이(duration)는 필수입니다.');
      return;
    }
    if (durationMs > _maxDurationMs) {
      showToast('영상 길이는 최대 5분까지만 허용됩니다.');
      return;
    }

    // 세그먼트 수집/검증
    final segments = _collectAndValidateSegments(durationMs: durationMs);
    if (segments == null) return;

    _setSaving(true);
    try {
      await _saveClip(
        isEdit: _isEdit,
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
        tags: tags,
        picked: PlatformFile(
            name: picked!.name, size: picked!.size, path: normalizedPath),
        existingRelPath: _existingRelPath,
      );
      showToast(_isEdit ? '업데이트 완료!' : '저장 완료!');
      _saveState = EditorSaveState.success;
      _shouldClose = true;
      notifyListeners();
    } catch (e) {
      showToast('저장 실패: $e');
      _saveState = EditorSaveState.error;
      notifyListeners();
    } finally {
      _setSaving(false);
    }
  }

  List<db.Segment>? _collectAndValidateSegments({required int durationMs}) {
    final result = <db.Segment>[];
    for (int i = 0; i < segmentForms.length; i++) {
      final f = segmentForms[i];
      final sText = f.startCtl.text.trim();
      final eText = f.endCtl.text.trim();
      final ja = f.originalCtl.text.trim();
      final pr = f.pronCtl.text.trim();
      final ko = f.koCtl.text.trim();

      if (sText.isEmpty ||
          eText.isEmpty ||
          ja.isEmpty ||
          pr.isEmpty ||
          ko.isEmpty) {
        showToast('세그먼트 ${i + 1}: 모든 필드는 필수입니다.');
        return null;
      }
      if (!TimecodeService.mmssmmm.hasMatch(sText)) {
        showToast('세그먼트 ${i + 1}: 시작 시각 형식 오류.');
        return null;
      }
      if (!TimecodeService.mmssmmm.hasMatch(eText)) {
        showToast('세그먼트 ${i + 1}: 종료 시각 형식 오류.');
        return null;
      }
      final start = _timecode.parseToMs(sText);
      final end = _timecode.parseToMs(eText);
      if (end <= start) {
        showToast('세그먼트 ${i + 1}: 종료가 시작보다 커야 합니다.');
        return null;
      }
      if (start < 0 || end > durationMs) {
        showToast('세그먼트 ${i + 1}: 구간이 영상 길이를 벗어납니다.');
        return null;
      }
      result.add(db.Segment(
        id: 0,
        clipId: 0,
        startMs: start,
        endMs: end,
        original: ja,
        pron: pr,
        trans: ko,
      ));
    }
    if (result.isEmpty) {
      showToast('세그먼트는 최소 1개 이상 필요합니다.');
      return null;
    }
    result.sort((a, b) => a.startMs.compareTo(b.startMs));
    for (int i = 1; i < result.length; i++) {
      if (result[i].startMs < result[i - 1].endMs) {
        showToast('세그먼트 ${i}와 ${i + 1}이 겹칩니다.');
        return null;
      }
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────────
  // 편집 모드 로드
  // ─────────────────────────────────────────────────────────────────
  Future<void> _loadForEdit(int clipId) async {
    db.Clip? clip;
    try {
      clip = mediaProvider.clips.firstWhere((c) => c.id == clipId);
    } catch (_) {
      showToast('편집할 클립을 찾을 수 없습니다.');
      return;
    }

    db.Episode? ep;
    if (clip.episodeId != null) {
      try {
        ep = mediaProvider.episodes.firstWhere((e) => e.id == clip!.episodeId);
      } catch (_) {}
    }

    db.Release? rel;
    if (ep?.releaseId != null) {
      try {
        rel = mediaProvider.releases.firstWhere((r) => r.id == ep!.releaseId);
      } catch (_) {}
    }

    db.Title? title;
    if (rel?.titleId != null) {
      try {
        title = mediaProvider.titles.firstWhere((t) => t.id == rel!.titleId);
      } catch (_) {}
    }

    nameCtl.text = title?.name ?? '';
    nameNativeCtl.text = title?.nameNative ?? '';
    seasonCtl.text = rel?.number?.toString() ?? '';
    episodeCtl.text = ep?.number?.toString() ?? '';
    epiTitleCtl.text = ep?.title ?? '';
    titleCtl.text = clip.title ?? '';
    _existingRelPath = clip.filePath;
    final existingDurationMs = clip.durationMs;

    final tagList = (mediaProvider.tagsByClip[clipId] ?? const <db.Tag>[])
        .map((t) => t.name)
        .toList();
    tags.clear();
    tags.addAll(tagList);

    final cv = await mediaProvider.fetchClipById(clipId);
    if (cv == null) {
      showToast('편집할 클립을 찾을 수 없습니다.');
      return;
    }

    segmentForms.clear();
    for (final s in cv.segments) {
      final f = SegmentFormData.empty();
      f.startCtl.text = _timecode.msToMMSSmmm(s.startMs);
      f.endCtl.text = _timecode.msToMMSSmmm(s.endMs);
      f.originalCtl.text = s.original;
      f.pronCtl.text = s.pron;
      f.koCtl.text = s.trans;
      segmentForms.add(f);
    }
    if (segmentForms.isEmpty) {
      segmentForms.add(SegmentFormData.empty());
    }

    if (existingDurationMs != null && existingDurationMs > 0) {
      durationCtl.text = existingDurationMs.toString();
    }

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────
  void _setSaving(bool saving) {
    _saveState = saving ? EditorSaveState.saving : EditorSaveState.idle;
    notifyListeners();
  }

  @override
  void showToast(String msg) {
    _toastMessage = msg;
    notifyListeners();
    // 잠시 후 초기화
    Future.delayed(const Duration(milliseconds: 100), () {
      _toastMessage = null;
    });
  }

  void clearToast() {
    _toastMessage = null;
  }

  // ─────────────────────────────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    titleCtl.dispose();
    nameCtl.dispose();
    nameNativeCtl.dispose();
    seasonCtl.dispose();
    episodeCtl.dispose();
    epiTitleCtl.dispose();
    durationCtl.dispose();
    tagsCtl.dispose();
    for (final f in segmentForms) {
      f.dispose();
    }
    super.dispose();
  }
}
