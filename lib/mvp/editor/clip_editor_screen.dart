// lib/mvp/editor/clip_editor_screen.dart
/// 기본 패키지 및 외부 패키지
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parrokit/mvp/editor/services/file_staging_service.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// 내부 패키지
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:parrokit/mvp/editor/clip_editor_model.dart';
import 'package:parrokit/mvp/editor/clip_editor_presenter.dart';
import 'package:parrokit/mvp/editor/clip_editor_view.dart';
import 'package:parrokit/utils/show_toast.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:parrokit/data/local/pa_database.dart' as db;

/// 위젯
import 'widgets/file_hero_card.dart';
import 'widgets/hairline_divider.dart';
import 'widgets/input_card.dart';
import 'widgets/labeled_text_field.dart';
import 'widgets/section_title.dart';
import 'widgets/segment_card.dart';

enum _PickSource { file, photos }

class ClipEditorScreen extends StatefulWidget {
  const ClipEditorScreen({super.key, this.clipId});

  final int? clipId;

  @override
  State<ClipEditorScreen> createState() => _ClipEditorScreenState();
}

class _ClipEditorScreenState extends State<ClipEditorScreen>
    implements ClipEditorView {
  /// --- 파일/플레이어 상태 ---
  PlatformFile? _picked;
  Uint8List? _thumb;
  VideoPlayerController? _vp;
  bool _vpReady = false;
  bool _saving = false;
  bool _isEdit = false;
  String? _existingRelPath;
  int? _existingDurationMS;
  _PickSource _lastPickSource = _PickSource.file;

  /// --- 폼 컨트롤러
  final _titleCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _nameNativeCtl = TextEditingController();
  final _episodeCtl = TextEditingController();
  final _durationCtl = TextEditingController();
  final _seasonCtl = TextEditingController();
  final _epiTitleCtl = TextEditingController();
  final _tagsCtl = TextEditingController();
  final List<String> _tags = [];
  final List<SegmentInput> _segForms = [SegmentInput.empty()];

  /// presenter
  late final ClipEditorPresenter _presenter;

  /// 그 외 변수
  String _selectedType = 'season';

  /// view 구현
  @override
  BuildContext get context => super.context;

  @override
  String get clipTitle => _titleCtl.text;

  @override
  String get workName => _nameCtl.text;

  @override
  String get workNameNative => _nameNativeCtl.text;

  @override
  String get seasonText => _seasonCtl.text;

  @override
  String get episodeText => _episodeCtl.text;

  @override
  String get epiTitle => _epiTitleCtl.text;

  @override
  String get type => _selectedType;

  @override
  List<String> get tags => _tags;

  @override
  List<SegmentInput> get segments => _segForms;

  @override
  int? get durationMsInput => int.tryParse(_durationCtl.text.trim());

  @override
  PlatformFile? get pickedFile => _picked;

  @override
  void setPicked(PlatformFile? f) {
    setState(() => _picked = f);
  }

  @override
  void setThumb(Uint8List? bytes) => setState(() => _thumb = bytes);

  @override
  void setDurationMs(int ms) =>
      setState(() => _durationCtl.text = ms.toString());

  @override
  void setSaving(bool saving) => setState(() => _saving = saving);

  @override
  void showToastMsg(String msg) => showToast(context, msg);

  @override
  void refresh() => setState(() => ());

  @override
  Future<void> closeAfterSaved() async {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void ensureSegmentFormsLength(int count) {
    setState(() {
      if (_segForms.length < count) {
        // 늘리기
        while (_segForms.length < count) {
          final nf = SegmentInput.empty();
          // UX: 직전 end를 새 start로 프리필
          if (_segForms.isNotEmpty) {
            nf.startCtl.text = _segForms.last.endCtl.text;
          }
          _segForms.add(nf);
        }
      } else if (_segForms.length > count) {
        // 줄이기 (뒤에서부터 제거)
        while (_segForms.length > count) {
          final removed = _segForms.removeLast();
          removed.dispose();
        }
      }
    });
  }

  @override
  void setSegmentAt(
    int index, {
    required String start,
    required String end,
    required String original,
    required String pron,
    required String ko,
  }) {
    setState(() {
      final f = _segForms[index];
      f.startCtl.text = start;
      f.endCtl.text = end;
      f.originalCtl.text = original;
      f.pronCtl.text = pron;
      f.koCtl.text = ko;
    });
  }

  /// initState & dispose
  @override
  void initState() {
    super.initState();
    _presenter = ClipEditorPresenter(
      view: this,
      mediaProvider: context.read<MediaProvider>(),
    );
    if (widget.clipId != null) {
      _isEdit = true;
      _loadForEdit(widget.clipId!);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _nameCtl.dispose();
    _nameNativeCtl.dispose();
    _episodeCtl.dispose();
    _durationCtl.dispose();
    _seasonCtl.dispose();
    _epiTitleCtl.dispose();
    _tagsCtl.dispose();
    _vp?.dispose();
    for (final f in _segForms) {
      f.dispose();
    }
    super.dispose();
  }

  /// 내부 정의 메소드
  Future<void> _loadForEdit(int clipId) async {
    final mp = context.read<MediaProvider>();

    // 1) clip 찾기
    db.Clip? clip;
    try {
      clip = mp.clips.firstWhere((c) => c.id == clipId);
    } catch (_) {
      showToast(context, '편집할 클립을 찾을 수 없습니다.');
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    // 2) 상위 엔티티 추적
    db.Episode? ep;
    if (clip.episodeId != null) {
      try {
        ep = mp.episodes.firstWhere((e) => e.id == clip!.episodeId);
      } catch (_) {}
    }

    db.Release? rel;
    if (ep?.releaseId != null) {
      try {
        rel = mp.releases.firstWhere((r) => r.id == ep!.releaseId);
      } catch (_) {}
    }

    db.Title? title;
    if (rel?.titleId != null) {
      try {
        title = mp.titles.firstWhere((t) => t.id == rel!.titleId);
      } catch (_) {}
    }

    // 3) 메타/태그 프리필 (동기 setState)
    setState(() {
      _nameCtl.text = title?.name ?? '';
      _nameNativeCtl.text = title?.nameNative ?? '';
      _seasonCtl.text = rel?.number?.toString() ?? '';
      _episodeCtl.text = ep?.number?.toString() ?? '';
      _epiTitleCtl.text = ep?.title ?? '';
      _titleCtl.text = clip?.title ?? '';
      _existingRelPath = clip?.filePath;
      _existingDurationMS = clip?.durationMs;
      final type = rel?.type ?? 'season';
      _tags
        ..clear()
        ..addAll(
            (mp.tagsByClip[clipId] ?? const <db.Tag>[]).map((t) => t.name));
    });

    // 4) 세그먼트 로드 (await는 setState 밖)
    final cv = await mp.fetchClipById(clipId);
    if (cv == null) {
      showToast(context, '편집할 클립을 찾을 수 없습니다.');
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    _segForms.clear();
    for (final s in cv.segments) {
      final f = SegmentInput.empty();
      f.startCtl.text = _msToMMSSmmm(s.startMs);
      f.endCtl.text = _msToMMSSmmm(s.endMs);
      f.originalCtl.text = s.original;
      f.pronCtl.text = s.pron;
      f.koCtl.text = s.trans;
      _segForms.add(f);
    }
    if (_segForms.isEmpty) {
      _segForms.add(SegmentInput.empty());
    }
    if (mounted) setState(() {}); // 세그먼트 UI 갱신

    // 5) 파일 경로 → 절대경로 변환 + 썸네일/길이
    if (_existingRelPath != null && _existingRelPath!.isNotEmpty) {
      final abs = await _absoluteFromRelative(_existingRelPath!);
      final file = File(abs);
      final size = await file.exists() ? await file.length() : 0;

      if (mounted) {
        setState(() {
          _picked =
              PlatformFile(name: abs.split('/').last, size: size, path: abs);
        });
      }

      try {
        final bytes = await VideoThumbnail.thumbnailData(
          video: abs,
          imageFormat: ImageFormat.PNG,
          maxWidth: 256,
          quality: 75,
          timeMs: 0,
        );
        if (mounted) setState(() => _thumb = bytes);

        if (_existingDurationMS == null || _existingDurationMS == 0) {
          final temp = VideoPlayerController.file(file);
          await temp.initialize();
          _existingDurationMS = temp.value.duration.inMilliseconds;
          if (mounted)
            setState(() {
              _durationCtl.text = _existingDurationMS!.toString();
            });
          await temp.dispose();
        } else {
          if (mounted)
            setState(() {
              _durationCtl.text = _existingDurationMS!.toString();
            });
        }
      } catch (_) {}
    }
  }

  String _msToMMSSmmm(int ms) {
    final m = ms ~/ 60000;
    final s = (ms % 60000) ~/ 1000;
    final u = ms % 1000;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${u.toString().padLeft(3, '0')}';
  }

  Future<String> _absoluteFromRelative(String rel) async {
    final base = await getApplicationDocumentsDirectory();
    return '${base.path}/$rel';
  }

  void _onAddSeg() {
    setState(() {
      final nf = SegmentInput.empty();
      // UX: 직전 세그 끝을 새 세그 시작으로 미리 채움
      if (_segForms.isNotEmpty) {
        final last = _segForms.last;
        nf.startCtl.text = last.endCtl.text;
      }
      _segForms.add(nf);
    });
  }

  void _onRemoveSeg(int idx) {
    if (_segForms.length == 1) {
      showToast(context, '세그먼트는 최소 1개 이상 필요합니다.');
      return;
    }
    setState(() {
      final f = _segForms.removeAt(idx);
      f.dispose();
    });
  }

  Future<void> _playInline() async {
    final path = _picked?.path;
    if (path == null) {
      showToast(context, '재생할 파일 경로가 없습니다.');
      return;
    }
    try {
      await _vp?.dispose();
      final c = VideoPlayerController.file(File(path));
      await c.initialize();
      _durationCtl.text = c.value.duration.inMilliseconds.toString();

      // 끝까지 재생했는지 감지 → 아이콘 갱신
      c.addListener(() {
        if (!mounted) return;
        final v = c.value;
        final done =
            v.isInitialized && !v.isPlaying && v.position >= v.duration;
        if (done) setState(() {}); // 버튼 아이콘이 ▶로 돌아오게 리빌드
      });

      setState(() {
        _vp = c;
        _vpReady = true;
      });
      await _vp!.play();
    } catch (e) {
      showToast(context, '재생 초기화 실패: $e');
    }
  }

  void _toggleInline() {
    if (!_vpReady || _vp == null) return;
    setState(() {
      _vp!.value.isPlaying ? _vp!.pause() : _vp!.play();
    });
  }

  Future<void> _stopInline() async {
    await _vp?.dispose();
    setState(() {
      _vp = null;
      _vpReady = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('편집'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _buildFileSection(),
                const SizedBox(height: 24),
                const HairlineDivider(),
                const SizedBox(height: 16),
                _buildMetaSection(),
                const SizedBox(height: 20),
                const HairlineDivider(),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.subtitles_outlined, size: 18),
                  label: const Text('STT 테스트 (업로드된 영상으로)'),
                  onPressed: _presenter.onSttAndDraft,
                ),
                _buildSegmentsSection(),
                _buildBottomActions(),
                const SizedBox(height: 200),
              ],
            ),
            if (_saving) Positioned.fill(child: _buildSavingOverlay()),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // Section builders (private)
  // ------------------------------
  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('영상 파일'),
        const SizedBox(height: 10),
        FileHeroCard(
          picked: _picked,
          onPick: _presenter.pickFromSandbox,
          onRemove: () {
            final p = _picked?.path;
            setState(() {
              _picked = null;
              _thumb = null;
              _vp?.dispose();
              _vp = null;
              _vpReady = false;
            });
            if (p != null && FileStagingService().isInStaging(p)) {
              FileStagingService().discard(p);
            }
          },
          onAddToSandbox: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowMultiple: false,
            );
            if (result != null && result.files.isNotEmpty) {
              final f = result.files.first;
              if (f.path == null) return showToastMsg('경로를 찾을 수 없습니다.');
              await _presenter.afterPick(
                path: f.path!,
                name: f.name,
                size: f.size,
              );
              showToastMsg("샌드박에서 추가했다고 가정");
            }
          },
          onPickFromPhotos: _presenter.pickFromPhotos,
          thumb: _thumb,
          isPlayingInline: _vpReady,
          playerController: _vp,
          onPlayInline: _playInline,
          onToggleInline: _toggleInline,
          onStopInline: _stopInline,
          onReopenLast: () {},
          onReopenFile: _presenter.pickFromSandbox,
          onReopenPhotos: _presenter.pickFromPhotos,
          lastSourceLabel: _lastPickSource == _PickSource.file ? '파일' : '사진',
        ),
      ],
    );
  }

  Widget _buildTypeSelector(TextTheme tt) {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'season',
                label: Text(
                  '시즌',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ButtonSegment(
                value: 'movie',
                label: Text(
                  '영화',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (s) => setState(() => _selectedType = s.first),
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsEditor(TextTheme tt, ColorScheme cs) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledTextField(
          label: '태그(선택)',
          hint: '기억하기 쉽고 다시 찾기 편한 태그를 입력하세요.',
          controller: _tagsCtl,
          helper: '“태그 추가” 버튼을 누르면 태그가 생성됩니다.',
          prefixIcon: Icons.tag_outlined,
          clearable: true,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('태그 추가'),
              onPressed: () {
                final t = _tagsCtl.text.trim();
                if (t.isEmpty) return;
                setState(() {
                  if (!_tags.contains(t)) _tags.add(t);
                  _tagsCtl.clear();
                });
              },
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: t.colorScheme.onPrimary,
                foregroundColor: t.colorScheme.primary,
              ),
              child: const Text('모두 지우기'),
              onPressed: () => setState(_tags.clear),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: -8,
          children: _tags
              .map((t) => Chip(
                    label: Text(
                      t,
                      style: tt.bodyMedium?.copyWith(color: cs.onPrimary),
                    ),
                    backgroundColor: cs.primary,
                    deleteIcon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white70,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onDeleted: () => setState(() => _tags.remove(t)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMetaSection() {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('영상 정보'),
        const SizedBox(height: 10),
        InputCard(
          children: [
            LabeledTextField(
              label: '클립 제목',
              hint: '클립 제목을 입력하세요.',
              controller: _titleCtl,
              helper: '어떤 장면인지 바로 알아볼 수 있게 간결하게 적어주세요.',
              prefixIcon: Icons.title,
              clearable: true,
            ),
            const SizedBox(height: 10),
            LabeledTextField(
              label: '작품명',
              hint: '작품의 이름을 입력하세요.',
              controller: _nameCtl,
              prefixIcon: Icons.movie_outlined,
              clearable: true,
            ),
            LabeledTextField(
              label: '원어 작품명',
              hint: '작품의 본토 이름을 입력하세요.',
              controller: _nameNativeCtl,
              prefixIcon: Icons.movie_outlined,
              clearable: true,
            ),
            const SizedBox(height: 10),
            _buildTypeSelector(tt),
            const SizedBox(height: 10),
            if (_selectedType == 'season')
              LabeledTextField(
                label: '시즌',
                hint: '몇 번째 시즌인지 숫자로 입력하세요.',
                controller: _seasonCtl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.layers_outlined,
                clearable: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            const SizedBox(height: 10),
            if (_selectedType == 'season')
              LabeledTextField(
                label: '화',
                hint: '몇 번째 회차인지 숫자로 입력하세요.',
                controller: _episodeCtl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.confirmation_number_outlined,
                clearable: true,
              ),
            const SizedBox(height: 10),
            LabeledTextField(
              label: _selectedType == 'movie' ? '영화 제목' : '회차 제목',
              hint: _selectedType == 'movie'
                  ? '회차의 제목을 입력하세요.'
                  : '영화의 제목을 입력하세요.',
              helper: _selectedType == 'movie'
                  ? '시리즈가 없는 단독 영화의 경우,\n작품명과 동일하거나 편한대로 작성해주세요.'
                  : '수정한 경우, 기존 값은 새 내용으로 갱신됩니다.',
              controller: _epiTitleCtl,
              prefixIcon: Icons.title_outlined,
              clearable: true,
            ),
            const SizedBox(height: 10),
            _buildTagsEditor(tt, cs),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentsHeader() {
    return Row(
      children: [
        const SectionTitle('구간 정보'),
        const Spacer(),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('구간 추가'),
          onPressed: _onAddSeg,
        ),
      ],
    );
  }

  Widget _buildSegmentsList() {
    return Column(
      children: [
        for (int i = 0; i < _segForms.length; i++) ...[
          SegmentCard(
            index: i + 1,
            startCtl: _segForms[i].startCtl,
            endCtl: _segForms[i].endCtl,
            originalCtl: _segForms[i].originalCtl,
            pronCtl: _segForms[i].pronCtl,
            koCtl: _segForms[i].koCtl,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('구간 삭제'),
                onPressed: () => _onRemoveSeg(i),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSegmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSegmentsHeader(),
        const SizedBox(height: 8),
        _buildSegmentsList(),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            child: const Text('저장'),
            onPressed: () => _presenter.save(
              isEdit: _isEdit,
              clipId: widget.clipId,
              picked: _picked,
              existingRelPath: _existingRelPath,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.25),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
