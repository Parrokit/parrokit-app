// ============================================================================
// lib/features/_content/editor/presentation/clip_editor_screen.dart
// ============================================================================
//
// [역할]
// 클립 에디터 화면. ViewModel에서 상태와 로직을 가져옴.
// sections 위젯을 사용하여 UI 구성.
//
// [레이어]
// Presentation Layer > Screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                ],
              ),
            ),
          ],
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Stepper(
                      type: StepperType.horizontal,
                      currentStep: vm.currentStep,
                      onStepContinue: vm.nextOrSave,
                      onStepCancel: vm.prevOrCancel,
                      onStepTapped: vm.isSttProcessing ? null : vm.goToStep,
                      controlsBuilder: (context, details) =>
                          const SizedBox.shrink(),
                      steps: [
                        _buildStep(0, vm, FileSection(vm: vm)),
                        _buildStep(1, vm, WorkNameSection(vm: vm)),
                        _buildStep(2, vm, TitlesSection(vm: vm)),
                        _buildStep(3, vm, TagsSection(vm: vm)),
                        _buildStep(4, vm, SegmentsSection(vm: vm)),
                      ],
                    ),
                    if (vm.isSaving)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.25),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ),
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
                child: _buildStepperControls(context, vm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExitConfirmation(
      BuildContext context, ClipEditorViewModel vm) async {
    // STT 처리 중이면 무시
    if (vm.isSttProcessing) return;

    final result = await showExitConfirmSheet(context);

    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Step _buildStep(int index, ClipEditorViewModel vm, Widget content) {
    return Step(
      title: const SizedBox.shrink(),
      isActive: vm.currentStep >= index,
      state: vm.currentStep > index ? StepState.complete : StepState.indexed,
      content: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        child: content,
      ),
    );
  }

  Widget _buildStepperControls(BuildContext context, ClipEditorViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: (vm.isSaving || vm.isSttProcessing)
                ? null
                : () {
                    if (vm.currentStep == 0) {
                      _showExitConfirmation(context, vm);
                    } else {
                      vm.prevOrCancel();
                    }
                  },
            child: Text(vm.currentStep == 0 ? '취소' : '이전'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed:
                (vm.isSaving || vm.isSttProcessing) ? null : vm.nextOrSave,
            child: Text(vm.currentStep == ClipEditorViewModel.totalSteps - 1
                ? '저장'
                : '다음'),
          ),
        ),
      ],
    );
  }
}
