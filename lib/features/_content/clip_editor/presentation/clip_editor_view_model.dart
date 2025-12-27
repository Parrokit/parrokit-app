// ============================================================================
// lib/features/_content/clip_editor/presentation/clip_editor_view_model.dart
// ============================================================================
//
// [역할]
// 클립 에디터 ViewModel. UI 상태 관리에 집중.
// 비즈니스 로직은 Domain/UseCase 레이어에 위임.
//
// [레이어]
// Presentation Layer - ViewModel
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/data/local/dao/titles_dao.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/utils/show_toast.dart' as utils;

import '../data/adapters/openai_llm_adapter.dart';
import '../data/adapters/openai_asr_adapter.dart';
import '../data/adapters/video_picker_files.dart';
import '../data/adapters/video_picker_gallery.dart';
import '../data/services/audio_to_video.dart';
import '../data/services/clip_load_service.dart';
import '../data/services/clip_save_service.dart';
import '../data/services/draft_generation_service.dart';
import '../data/services/file_staging_service.dart';
import '../data/services/native_title_service.dart';
import '../data/services/video_meta_service.dart';
import '../data/usecases/extract_duration_usecase.dart';
import '../data/usecases/extract_thumbnail_usecase.dart';
import '../data/usecases/generate_draft_usecase.dart';
import '../data/usecases/load_clip_for_edit_usecase.dart';
import '../data/usecases/pick_video_usecase.dart';
import '../data/usecases/save_clip_usecase.dart';
import '../data/usecases/transcribe_usecase.dart';
import '../data/usecases/lookup_native_title_usecase.dart';

import '../domain/clip_form_data.dart';
import '../domain/clip_validator.dart';
import '../domain/editor_mode.dart';
import '../domain/editor_state.dart';

import 'view_model/editor_file_mixin.dart';
import 'view_model/editor_segment_mixin.dart';
import 'view_model/editor_tag_mixin.dart';
import 'view_model/editor_autocomplete_mixin.dart';

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
  @override
  final TitlesDao titlesDao;
  final int? clipId;

  @override
  late final FileStagingService staging;
  @override
  late final AudioToVideoService audioToVideo;
  @override
  late final ExtractThumbnailUseCase extractThumb;
  @override
  late final ExtractDurationUseCase extractDuration;
  @override
  late final PickVideoUseCase pickVideo;

  late final SaveClipUseCase _saveClip;
  late final LoadClipForEditUseCase _loadClipForEdit;
  late final GenerateDraftUseCase _generateDraft;
  late final LookupNativeTitleUseCase _lookupNativeTitle;
  final ClipValidator _validator = ClipValidator();

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

  // 원어 작품명 조회 상태
  bool _isLookingUpNativeTitle = false;
  bool get isLookingUpNativeTitle => _isLookingUpNativeTitle;

  // 에디터 모드
  EditorMode _mode = const CreateMode();
  EditorMode get mode => _mode;
  bool get isEdit => _mode is EditMode;

  // 메타데이터
  ContentType _contentType = ContentType.season;
  @override
  ContentType get contentType => _contentType;

  // TextEditingControllers (View에서 직접 사용)
  final titleCtl = TextEditingController();
  @override
  final nameCtl = TextEditingController();
  @override
  final nameNativeCtl = TextEditingController();
  @override
  final seasonCtl = TextEditingController();
  @override
  final episodeCtl = TextEditingController();
  @override
  final epiTitleCtl = TextEditingController();
  @override
  final durationCtl = TextEditingController();
  final tagsCtl = TextEditingController();

  // 저장 후 닫기 플래그
  bool _shouldClose = false;
  bool get shouldClose => _shouldClose;

  dynamic _closeResult;
  dynamic get closeResult => _closeResult;

  static const int totalSteps = 7;

  // ─────────────────────────────────────────────────────────────────
  // 초기화
  // ─────────────────────────────────────────────────────────────────

  void showToast(String msg) {
    if (rootNavigatorKey.currentContext != null) {
      utils.showToast(rootNavigatorKey.currentContext!, msg);
    }
  }

  void _init() {
    staging = FileStagingService();
    audioToVideo = FfmpegAudioToVideoService();
    extractThumb = ExtractThumbnailUseCase(VideoMetaServiceImpl());
    extractDuration = ExtractDurationUseCase(VideoMetaServiceImpl());
    pickVideo = PickVideoUseCase(
      files: VideoPickerFiles(),
      gallery: VideoPickerGallery(),
    );

    // Service 기반 UseCase 초기화
    _saveClip = SaveClipUseCase(
      service: ClipSaveService(repo: mediaProvider, staging: staging),
    );
    _loadClipForEdit = LoadClipForEditUseCase(
      service: ClipLoadService(mediaProvider: mediaProvider),
    );

    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final llmAdapter = OpenAILlmAdapter(apiKey: apiKey);

    _generateDraft = GenerateDraftUseCase(
      service: DraftGenerationService(
        transcribe: TranscribeUseCase(
          OpenAIAsrAdapter(apiKey: apiKey),
        ),
        llm: llmAdapter,
      ),
    );

    _lookupNativeTitle =
        LookupNativeTitleUseCase(NativeTitleService(llmAdapter));

    // 세그먼트 폼 초기화
    initSegmentForms();

    // 편집 모드 로드
    if (clipId != null) {
      _loadForEdit(clipId!);
    }

    // 작품명 목록 로드
    loadTitleNames();
  }

  // ─────────────────────────────────────────────────────────────────
  // Stepper 제어
  // ─────────────────────────────────────────────────────────────────

  /// 특정 스텝으로 이동합니다.
  void goToStep(int step) {
    if (step >= 0 && step <= totalSteps - 1) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// 다음 스텝으로 이동합니다.
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// 이전 스텝으로 이동합니다.
  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// 다음 버튼 또는 저장 버튼 동작
  void nextOrSave() {
    if (_currentStep < totalSteps - 1) {
      nextStep();
    } else {
      save();
    }
  }

  /// 이전 버튼 또는 취소 버튼 동작
  void prevOrCancel() {
    if (_currentStep == 0) {
      _shouldClose = true;
      _closeResult = null;
      notifyListeners();
    } else {
      prevStep();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 콘텐츠 타입
  // ─────────────────────────────────────────────────────────────────

  /// 콘텐츠 타입(시즌/영화)을 설정합니다.
  void setContentType(ContentType type) {
    _contentType = type;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // 원어 작품명 자동 조회
  // ─────────────────────────────────────────────────────────────────

  /// 작품명을 기반으로 원어 작품명을 자동으로 조회합니다.
  Future<void> lookupNativeTitle() async {
    final workName = nameCtl.text.trim();
    if (workName.isEmpty) {
      showToast('먼저 작품명을 입력해 주세요.');
      return;
    }

    _isLookingUpNativeTitle = true;
    notifyListeners();

    try {
      final result = await _lookupNativeTitle(workName: workName);
      nameNativeCtl.text = result.nativeTitle;
      showToast('원어 작품명: ${result.nativeTitle}');
    } catch (e) {
      showToast('원어 작품명 조회 실패: $e');
    } finally {
      _isLookingUpNativeTitle = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // STT + 초안 생성 (UseCase 위임)
  // ─────────────────────────────────────────────────────────────────

  /// 선택된 비디오 파일에 대해 STT를 수행하고 초안을 생성합니다.
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

    // 코인 비용 미리 계산
    final cost = _calculateCoinCost(durationMs);
    if (cost > 0 && userProvider.coins < cost) {
      showToast('코인이 부족합니다. (필요: $cost, 보유: ${userProvider.coins})');
      _setSaving(false);
      return;
    }

    try {
      // UseCase 호출
      final result = await _generateDraft(
        filePath: path,
        durationMs: durationMs,
        language: 'ja',
      );

      if (result.segments.isNotEmpty) {
        // UI에 세그먼트 채우기
        _fillSegmentsFromDraft(result.segments);
        showToast('세그먼트 ${result.segments.length}개 자동 채움');

        // 코인 차감
        if (result.coinCost > 0) {
          userProvider.addCoins(-result.coinCost);
          showToast('STT/초안 생성에 코인 ${result.coinCost}개 사용');
        }
      }
    } catch (e) {
      showToast('STT/번역 실패: $e');
    } finally {
      _setSaving(false);
    }
  }

  void _fillSegmentsFromDraft(List<SegmentInput> segments) {
    ensureSegmentFormsLength(segments.length);

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      setSegmentAt(
        i,
        start: seg.start,
        end: seg.end,
        original: seg.original,
        pron: seg.pron,
        ko: seg.ko,
      );
    }
  }

  int _calculateCoinCost(int durationMs) {
    final seconds = (durationMs / 1000).ceil();
    if (seconds <= 0) return 0;
    return ((seconds + 29) ~/ 30);
  }

  // ─────────────────────────────────────────────────────────────────
  // 저장 (Domain Validator + UseCase 위임)
  // ─────────────────────────────────────────────────────────────────

  /// 클립과 세그먼트 정보를 저장합니다.
  Future<void> save() async {
    final stagedPath = picked?.path;
    if (stagedPath == null || stagedPath.isEmpty) {
      showToast('영상 파일을 먼저 선택해 주세요.');
      return;
    }

    final normalizedPath = await audioToVideo.ensureMp4(stagedPath);

    // ClipFormData 생성
    final formData = _buildFormData(filePath: normalizedPath);

    // Domain Validator로 검증
    final validationResult = _validator.validateForm(formData);
    if (!validationResult.isValid) {
      showToast(validationResult.errorMessage!);
      return;
    }

    _setSaving(true);
    try {
      await _saveClip(
        formData: formData,
        mode: _mode,
        stagedFilePath: normalizedPath,
      );
      showToast(isEdit ? '업데이트 완료!' : '저장 완료!');
      _saveState = EditorSaveState.success;
      _shouldClose = true;
      _closeResult = true;
      notifyListeners();
    } catch (e) {
      showToast('저장 실패: $e');
      _saveState = EditorSaveState.error;
      notifyListeners();
    } finally {
      _setSaving(false);
    }
  }

  /// 현재 UI 상태에서 ClipFormData를 빌드합니다.
  ClipFormData _buildFormData({String? filePath}) {
    final segments = segmentForms
        .map((f) => SegmentInput(
              start: f.startCtl.text.trim(),
              end: f.endCtl.text.trim(),
              original: f.originalCtl.text.trim(),
              pron: f.pronCtl.text.trim(),
              ko: f.koCtl.text.trim(),
            ))
        .toList();

    return ClipFormData(
      titleName: nameCtl.text.trim(),
      titleNameNative: nameNativeCtl.text.trim(),
      clipTitle: titleCtl.text.trim(),
      epiTitle: epiTitleCtl.text.trim(),
      seasonNumber: int.tryParse(seasonCtl.text.trim()),
      episodeNumber: int.tryParse(episodeCtl.text.trim()),
      contentType: _contentType,
      durationMs: int.tryParse(durationCtl.text.trim()),
      segments: segments,
      tags: tags,
      filePath: filePath ?? picked?.path,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // 편집 모드 로드 (UseCase 위임)
  // ─────────────────────────────────────────────────────────────────
  Future<void> _loadForEdit(int clipId) async {
    try {
      final result = await _loadClipForEdit(clipId);

      // 모드 설정
      _mode = result.mode;

      // UI에 데이터 채우기
      final form = result.formData;
      nameCtl.text = form.titleName;
      nameNativeCtl.text = form.titleNameNative;
      titleCtl.text = form.clipTitle;
      epiTitleCtl.text = form.epiTitle;
      seasonCtl.text = form.seasonNumber?.toString() ?? '';
      episodeCtl.text = form.episodeNumber?.toString() ?? '';
      _contentType = form.contentType;

      if (form.durationMs != null && form.durationMs! > 0) {
        durationCtl.text = form.durationMs.toString();
      }

      // 태그
      tags.clear();
      tags.addAll(form.tags);

      // 세그먼트
      segmentForms.clear();
      for (final seg in form.segments) {
        final f = SegmentFormData.empty();
        f.startCtl.text = seg.start;
        f.endCtl.text = seg.end;
        f.originalCtl.text = seg.original;
        f.pronCtl.text = seg.pron;
        f.koCtl.text = seg.ko;
        segmentForms.add(f);
      }
      if (segmentForms.isEmpty) {
        segmentForms.add(SegmentFormData.empty());
      }

      notifyListeners();
    } catch (e) {
      showToast('편집 데이터 로드 실패: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────
  void _setSaving(bool saving) {
    _saveState = saving ? EditorSaveState.saving : EditorSaveState.idle;
    notifyListeners();
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
