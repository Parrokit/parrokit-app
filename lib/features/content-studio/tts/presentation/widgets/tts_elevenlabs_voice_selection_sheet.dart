import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/features/content-studio/tts/data/data_sources/tts_remote_data_source.dart';
import 'package:parrokit/features/content-studio/tts/data/repositories/tts_voice_cache.dart';
import 'package:parrokit/features/content-studio/tts/domain/models/tts_elevenlabs_models.dart';
import 'package:parrokit/features/content-studio/tts/presentation/providers/tts_provider.dart';

class TtsElevenLabsVoiceSelectionSheet extends StatelessWidget {
  const TtsElevenLabsVoiceSelectionSheet({
    super.key,
    required this.provider,
  });

  final TtsProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'ElevenLabs 보이스 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: FutureBuilder<List<TtsElevenLabsVoice>>(
              future: TtsVoiceCache().fetchElevenLabsVoicesIfNeeded(TtsRemoteDataSource()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '보이스 목록을 불러오지 못했습니다.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  );
                }

                final voices = snapshot.data ?? [];
                if (voices.isEmpty) {
                  return const Center(child: Text('사용 가능한 보이스가 없습니다.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: voices.length,
                  itemBuilder: (context, index) {
                    final voice = voices[index];
                    // 첫 로드 시 voiceId가 빈 값이면 첫 번째를 선택된 것으로 간주
                    final isSelected = provider.voiceId == voice.id || (provider.voiceId.isEmpty && index == 0);

                    return ListTile(
                      title: Text(
                        voice.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF9B72CB) : null,
                        ),
                      ),
                      subtitle: Text(
                        '카테고리: ${voice.category}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF9B72CB))
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      onTap: () {
                        provider.updateVoiceId(voice.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
