import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/features/_settings/more/data/coin_package.dart';
import 'package:parrokit/features/_settings/more/presentation/widgets/coin_package_card.dart';
import 'package:parrokit/features/_settings/payment/domain/payment_args.dart';

/// 코인 결제 섹션. UI + 결제 네비게이션 로직 자체 내포.
class CoinStoreSection extends StatelessWidget {
  const CoinStoreSection({super.key});

  void _onPackageSelected(BuildContext context, CoinPackage pkg) {
    final user = context.read<UserProvider>().currentUser;
    context.push(
      AppRoutes.paymentPath,
      extra: PaymentArgs(
        merchantUid: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        amount: pkg.price,
        coins: pkg.totalCoins,
        productName: '코인 ${pkg.totalCoins}개',
        buyerEmail: user?.email ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '코인 충전',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '1,000원 단위로 결제하고, 각 결제마다 10% 보너스 코인이 추가로 지급돼요.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: CoinPackage.packages
              .map(
                (pkg) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CoinPackageCard(
                    package: pkg,
                    onTap: () => _onPackageSelected(context, pkg),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
