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

import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/services/daily_limit_service.dart';
import 'package:parrokit/data/local/dao/collections_dao.dart';
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
import '../data/services/video_meta_service.dart';
import '../data/usecases/extract_duration_usecase.dart';
import '../data/usecases/extract_thumbnail_usecase.dart';
import '../data/usecases/generate_draft_usecase.dart';
import '../data/usecases/load_clip_for_edit_usecase.dart';
import '../data/usecases/pick_video_usecase.dart';
import '../data/usecases/save_clip_usecase.dart';
import '../data/usecases/transcribe_usecase.dart';

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
    required this.collectionsDao,
    this.clipId,
    this.initialCollectionName,
  }) {
    _init();
  }

  final String? initialCollectionName;

  // ─────────────────────────────────────────────────────────────────
  // 의존성
  // ─────────────────────────────────────────────────────────────────
  final MediaProvider mediaProvider;
  final UserProvider userProvider;
  @override
  final CollectionsDao collectionsDao;
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
  final ClipValidator _validator = ClipValidator();

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────

  // 저장 상태
  EditorSaveState _saveState = EditorSaveState.idle;
  EditorSaveState get saveState => _saveState;
  bool get isSaving => _saveState == EditorSaveState.saving;

  // STT 처리 진행 상태
  SttProcessState _sttState = SttProcessState.idle;
  SttProcessState get sttState => _sttState;
  bool get isSttProcessing =>
      _sttState != SttProcessState.idle &&
      _sttState != SttProcessState.done &&
      _sttState != SttProcessState.error;

  // 배치 진행률 (번역 단계에서)
  int _sttProgress = 0;
  int _sttTotal = 0;
  int get sttProgress => _sttProgress;
  int get sttTotal => _sttTotal;
  String get sttProgressText => _sttTotal > 0 ? '$_sttProgress/$_sttTotal' : '';

  // 에디터 모드
  EditorMode _mode = const CreateMode();
  EditorMode get mode => _mode;
  bool get isEdit => _mode is EditMode;

  // TextEditingControllers (View에서 직접 사용)
  final titleCtl = TextEditingController();         // 클립 제목
  final collectionNameCtl = TextEditingController(); // 컬렉션 이름 (선택)
  @override
  final durationCtl = TextEditingController();
  final tagsCtl = TextEditingController();

  // 저장 후 닫기 플래그
  bool _shouldClose = false;
  bool get shouldClose => _shouldClose;

  dynamic _closeResult;
  dynamic get closeResult => _closeResult;

  // ─────────────────────────────────────────────────────────────────
  // 초기화
  // ─────────────────────────────────────────────────────────────────

  void showToast(String msg) => utils.showToast(msg);

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

    // 세그먼트 폼 초기화
    initSegmentForms();

    // 편집 모드 로드
    if (clipId != null) {
      _loadForEdit(clipId!);
    }

    // 컬렉션 이름 목록 로드
    loadCollectionNames();

    // 초기 컬렉션 이름 pre-fill
    if (initialCollectionName != null && clipId == null) {
      collectionNameCtl.text = initialCollectionName!;
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

    // 하루 사용 제한 체크
    final allowed = await DailyLimitService.consume(
      'stt',
      limit: AppConfig.sttDailyLimit,
    );
    if (!allowed) {
      final limit = AppConfig.sttDailyLimit;
      showToast('오늘 자막 생성은 하루 $limit회까지 가능합니다. 내일 다시 시도해 주세요.');
      return;
    }
    final path = picked!.path!;

    // Step 1: 오디오 추출 준비
    _setSttState(SttProcessState.extracting);

    int? durationMs = int.tryParse(durationCtl.text.trim());
    durationMs ??= await extractDuration(path);

    if (durationMs == null || durationMs <= 0) {
      showToast('영상 길이를 확인할 수 없습니다.');
      _setSttState(SttProcessState.error);
      return;
    }

    // 코인 비용 미리 계산
    final cost = _calculateCoinCost(durationMs);
    if (cost > 0 && userProvider.coins < cost) {
      showToast('코인이 부족합니다. (필요: $cost, 보유: ${userProvider.coins})');
      _setSttState(SttProcessState.idle);
      return;
    }

    try {
      // Step 2: 음성 인식 (STT)
      _setSttState(SttProcessState.transcribing);

      // UseCase 호출 (내부에서 STT + 번역 처리)
      final result = await _generateDraft(
        filePath: path,
        durationMs: durationMs,
        language: 'ja',
        onProgress: (current, total, message) {
          _sttProgress = current;
          _sttTotal = total;
          if (_sttState != SttProcessState.translating) {
            _setSttState(SttProcessState.translating);
          } else {
            notifyListeners();
          }
        },
      );

      if (result.segments.isNotEmpty) {
        // UI에 세그먼트 채우기
        _fillSegmentsFromDraft(result.segments);
        showToast('세그먼트 ${result.segments.length}개 자동 채움');

        // 코인 차감
        if (result.coinCost > 0) {
          userProvider.addCoins(-result.coinCost);
          showToast('자막 생성 완료! (${result.coinCost}코인 사용)');
        }
      }

      _setSttState(SttProcessState.done);
      // 잠시 후 idle로 복귀
      Future.delayed(const Duration(seconds: 2), () {
        if (_sttState == SttProcessState.done) {
          _setSttState(SttProcessState.idle);
        }
      });
    } catch (e) {
      showToast('STT/번역 실패: $e');
      _setSttState(SttProcessState.error);
      Future.delayed(const Duration(seconds: 2), () {
        if (_sttState == SttProcessState.error) {
          _setSttState(SttProcessState.idle);
        }
      });
    }
  }

  void _setSttState(SttProcessState state) {
    _sttState = state;
    notifyListeners();
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

    final colName = collectionNameCtl.text.trim();

    return ClipFormData(
      collectionName: colName.isEmpty ? null : colName,
      clipTitle: titleCtl.text.trim(),
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
      collectionNameCtl.text = form.collectionName ?? '';
      titleCtl.text = form.clipTitle;

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

      // 기존 파일 경로가 있으면 Step 1에 표시
      if (form.filePath != null && form.filePath!.isNotEmpty) {
        await setExistingFile(form.filePath!);
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
    collectionNameCtl.dispose();
    durationCtl.dispose();
    tagsCtl.dispose();
    for (final f in segmentForms) {
      f.dispose();
    }
    super.dispose();
  }
}
