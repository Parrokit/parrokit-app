// ============================================================================
// lib/features/more/presentation/sections/payment_section.dart
// ============================================================================
//
// [역할]
// 결제 섹션 위젯 (프리미엄 구매).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/core/theme/app_radius.dart';
import 'package:parrokit/core/provider/iap_provider.dart';
import '../widgets/card_container.dart';
import '../widgets/nav_tile.dart';
import '../widgets/section_title.dart';
import '../premium_dialog.dart';
import 'package:parrokit/core/utils/show_toast.dart';

/// 결제 섹션.
class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('결제'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            children: [
              NavTile(
                icon: Icons.add_shopping_cart_rounded,
                title: '광고 제거',
                showArrow: false,
                trailing: _buildPaymentButton(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    final iap = context.watch<IapProvider>();
    final cs = Theme.of(context).colorScheme;

    // 이미 프리미엄이면 '구매 완료' 비활성 버튼
    if (iap.isPremium) {
      return FilledButton.icon(
        onPressed: null,
        label: const Text('구매 완료'),
        style: FilledButton.styleFrom(
          disabledBackgroundColor: cs.surfaceContainerHighest,
          disabledForegroundColor: cs.onSurface.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    // 결제 버튼
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
      ),
      onPressed: () async {
        final iap = context.read<IapProvider>();

        if (iap.loading) {
          showToast('결제 정보를 불러오는 중입니다… 잠시만요.');
          return;
        }
        if (!iap.available) {
          showToast('스토어에 연결할 수 없습니다.');
          return;
        }
        if (iap.removeAdsProduct == null) {
          await iap.init();
          if (!context.mounted) return;
          if (iap.removeAdsProduct == null) {
            showToast('상품 정보를 찾을 수 없습니다.');
            return;
          }
        }

        if (!context.mounted) return;
        showPremiumDialog(
          context,
          price: iap.removeAdsProduct!.price,
          onBuy: () => context.read<IapProvider>().buyRemoveAds(),
          onRestore: () => context.read<IapProvider>().restorePurchases(),
        );
      },
      child: Text(
        context.watch<IapProvider>().removeAdsProduct?.price ?? 'US\$0.99',
      ),
    );
  }
}
