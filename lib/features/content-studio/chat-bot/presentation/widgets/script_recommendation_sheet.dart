import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/features/content-studio/tts/presentation/providers/tts_provider.dart';

Future<void> showScriptRecommendationSheet(
  BuildContext context,
  String scriptText,
  void Function(int tabIndex, Map<String, dynamic>? actionData)? onTriggerAction,
) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  await showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.surfaceContainerHighDark : AppColors.surfaceContainerHigh,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.post_add_rounded,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '스크립트에 추가하시겠습니까?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '생성된 스크립트를 TTS 입력창으로 복사합니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('아니오'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 1. 바텀시트 닫기
                        Navigator.of(sheetContext).pop();
                        
                        // 2. TTS Provider에 스크립트 추가
                        final ttsProvider = context.read<TtsProvider>();
                        ttsProvider.updateText(scriptText);
                        
                        // 3. 챗봇 패널 닫기 (이전 라우트 팝)
                        Navigator.of(context).pop();

                        // 4. TTS 탭(인덱스 1)으로 이동
                        if (onTriggerAction != null) {
                          onTriggerAction(1, null);
                        }
                      },
                      child: const Text('예'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
