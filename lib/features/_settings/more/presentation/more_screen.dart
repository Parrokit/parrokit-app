// ============================================================================
// lib/features/more/presentation/more_screen.dart
// ============================================================================
//
// [역할]
// 설정/더보기 화면.
//
// [레이어]
// Presentation Layer - View
//
// [구성 요소]
// - AccountSection: 계정 섹션
// - PlayerSettingsSection: 플레이어 설정
// - ShortsSettingsSection: 쇼츠 설정
// - AppSettingsSection: 앱 설정
// - PaymentSection: 결제 섹션
// - BackupSection: 백업 섹션
// - InfoSection: 정보 섹션
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_spacing.dart';

import 'sections/account_section.dart';
import 'sections/app_settings_section.dart';
import 'sections/backup_section.dart';
import 'sections/info_section.dart';
import 'sections/payment_section.dart';
import 'sections/player_settings_section.dart';
import 'sections/shorts_settings_section.dart';

/// 설정/더보기 화면.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ).copyWith(bottom: AppSpacing.xxl),
          children: const [
            SizedBox(height: AppSpacing.md),

            // 계정
            AccountSection(),
            SizedBox(height: AppSpacing.sectionGap),

            // 플레이어 설정
            PlayerSettingsSection(),
            SizedBox(height: AppSpacing.sectionGap),

            // 쇼츠 설정
            ShortsSettingsSection(),
            SizedBox(height: AppSpacing.sectionGap),

            // 앱 설정
            AppSettingsSection(),
            SizedBox(height: AppSpacing.sectionGap),

            // 결제
            PaymentSection(),
            SizedBox(height: AppSpacing.sectionGap),

            // 백업
            BackupSection(),
            SizedBox(height: AppSpacing.sectionGap),

            // 정보
            InfoSection(),
          ],
        ),
      ),
    );
  }
}
