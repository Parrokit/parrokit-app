// ============================================================================
// lib/features/_content/editor/presentation/clip_editor_screen.dart
// ============================================================================
//
// [역할]
// 클립 에디터 화면. ViewModel에서 상태와 로직을 가져옴.
// 모든 섹션을 단일 스크롤 페이지에 표시.
//
// [레이어]
// Presentation Layer > Screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/data/local/app_database.dart' as db;

import 'clip_editor_view_model.dart';
import 'widgets/exit_confirm_sheet.dart';
import 'sections/sections.dart';

/// 클립 에디터 화면.
class ClipEditorScreen extends StatelessWidget {
  const ClipEditorScreen({super.key, this.clipId, this.initialCollectionName});

  final int? clipId;
  final String? initialCollectionName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClipEditorViewModel(
        mediaProvider: context.read<MediaProvider>(),
        userProvider: context.read<UserProvider>(),
        collectionsDao: context.read<db.AppDatabase>().collectionsDao,
        clipId: clipId,
        initialCollectionName: initialCollectionName,
      ),
      child: const _ClipEditorBody(),
    );
  }
}

class _ClipEditorBody extends StatefulWidget {
  const _ClipEditorBody();

  @override
  State<_ClipEditorBody> createState() => _ClipEditorBodyState();
}

class _ClipEditorBodyState extends State<_ClipEditorBody> {
  bool _hasHandledClose = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClipEditorViewModel>();
    final userProvider = context.watch<UserProvider>();

    // 저장 후 닫기 - 한 번만 처리
    if (vm.shouldClose && !_hasHandledClose) {
      _hasHandledClose = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(vm.closeResult);
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _showExitConfirmation(context, vm);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('편집'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showExitConfirmation(context, vm),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${userProvider.coins}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.today_rounded,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${vm.dailyRemaining}/${AppConfig.sttDailyLimit}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                  ),
                ],
              ),
            ),
          ],
          elevation: 0,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      children: [
                        FileSection(vm: vm),
                        const SizedBox(height: 24),
                        WorkNameSection(vm: vm),
                        const SizedBox(height: 24),
                        TitlesSection(vm: vm),
                        const SizedBox(height: 24),
                        TagsSection(vm: vm),
                        const SizedBox(height: 24),
                        SegmentsSection(vm: vm),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (vm.isSaving || vm.isSttProcessing)
                            ? null
                            : vm.save,
                        child: vm.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('저장'),
                      ),
                    ),
                  ),
                ],
              ),
              if (vm.isSaving)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExitConfirmation(
      BuildContext context, ClipEditorViewModel vm) async {
    if (vm.isSttProcessing) return;
    final result = await showExitConfirmSheet(context);
    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
