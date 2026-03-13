import 'package:flutter/material.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/services/ad_service.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:provider/provider.dart';

/// 광고 보고 코인 받기 섹션.
///
/// 자체적으로 광고 로드/시청/보상 처리. more_screen에서 독립적으로 사용.
class AdRewardSection extends StatefulWidget {
  const AdRewardSection({super.key});

  @override
  State<AdRewardSection> createState() => _AdRewardSectionState();
}

class _AdRewardSectionState extends State<AdRewardSection> {
  @override
  void initState() {
    super.initState();
    AdService().loadRewardedAd();
  }

  void _onWatchAd() {
    AdService().showRewardedAd(
      onRewarded: (coins) {
        if (!mounted) return;
        if (coins < 0) {
          showToast('광고가 아직 준비 중이에요. 잠시 후 다시 시도해 주세요.');
          return;
        }
        context.read<UserProvider>().addCoins(coins);
        showToast('코인 $coins개를 받았어요!');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '코인 받기',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '광고를 시청하면 코인 ${AdService.rewardCoins}개를 받을 수 있어요. '
          '코인이 있으면 하루 제한 없이 자막 생성을 사용할 수 있어요.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _onWatchAd,
            icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
            label: Text('광고 보고 코인 ${AdService.rewardCoins}개 받기'),
          ),
        ),
      ],
    );
  }
}
