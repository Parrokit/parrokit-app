// lib/core/theme/app_colors.dart
//
// 앱 전역 색상 시스템 - Toss-like Blue 베이스

import 'package:flutter/material.dart';

/// 앱 전역 색상 상수
///
/// Toss 스타일 블루 기반의 일관된 색상 팔레트
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════════════
  // Light Mode
  // ═══════════════════════════════════════════════════════════════════

  // ─────────────────────────────────────────────────────────────────
  // Surface (배경)
  // ─────────────────────────────────────────────────────────────────

  /// 기본 배경 (흰색)
  static const Color surface = Color(0xFFFFFFFF);

  /// 카드/컨테이너 배경
  static const Color surfaceContainer = Color(0xFFF7F8FA);

  /// 강조 컨테이너 배경
  static const Color surfaceContainerHigh = Color(0xFFF0F2F5);

  /// 구분선 (10% 검정)
  static const Color divider = Color(0x1A000000);

  /// 얇은 구분선 (6% 검정)
  static const Color dividerSubtle = Color(0x0F000000);

  // ─────────────────────────────────────────────────────────────────
  // Text (텍스트)
  // ─────────────────────────────────────────────────────────────────

  /// 주요 텍스트 (거의 검정)
  static const Color textPrimary = Color(0xFF111418);

  /// 보조 텍스트 (회색)
  static const Color textSecondary = Color(0xFF5B636E);

  /// 힌트/비활성 텍스트
  static const Color textTertiary = Color(0xFF8C95A1);

  /// 비활성 텍스트 (더 연함)
  static const Color textDisabled = Color(0xFFADB5BD);

  // ─────────────────────────────────────────────────────────────────
  // Accent (강조 - Toss Blue)
  // ─────────────────────────────────────────────────────────────────

  /// 프라이머리 블루 (토스 블루)
  static const Color primary = Color(0xFF0064FF);

  /// 프라이머리 호버/눌림
  static const Color primaryPressed = Color(0xFF0052D4);

  /// 프라이머리 소프트 배경 (버튼/칩 배경용)
  static const Color primarySoft = Color(0xFFE8F1FF);

  /// 프라이머리 아주 연한 배경 (선택 하이라이트)
  static const Color primarySubtle = Color(0xFFF5F9FF);

  // ─────────────────────────────────────────────────────────────────
  // Secondary (보조 컬러)
  // ─────────────────────────────────────────────────────────────────

  /// 보조 퍼플 (프리미엄/특별 기능)
  static const Color secondary = Color(0xFF7C3AED);

  /// 보조 퍼플 소프트
  static const Color secondarySoft = Color(0xFFF3EEFF);

  // ─────────────────────────────────────────────────────────────────
  // Feedback (피드백)
  // ─────────────────────────────────────────────────────────────────

  /// 성공 (그린)
  static const Color success = Color(0xFF16A34A);

  /// 성공 소프트 배경
  static const Color successSoft = Color(0xFFECFDF5);

  /// 경고 (옐로우/앰버)
  static const Color warning = Color(0xFFF59E0B);

  /// 경고 소프트 배경
  static const Color warningSoft = Color(0xFFFFFBEB);

  /// 위험/에러 (레드)
  static const Color danger = Color(0xFFDC2626);

  /// 위험 소프트 배경
  static const Color dangerSoft = Color(0xFFFEF2F2);

  /// 정보 (블루 - 프라이머리와 동일)
  static const Color info = Color(0xFF0064FF);

  /// 정보 소프트 배경
  static const Color infoSoft = Color(0xFFE8F1FF);

  // ─────────────────────────────────────────────────────────────────
  // Interactive (상호작용)
  // ─────────────────────────────────────────────────────────────────

  /// 링크 텍스트
  static const Color link = Color(0xFF0064FF);

  /// 비활성 요소 배경
  static const Color disabled = Color(0xFFE9ECEF);

  /// 비활성 요소 전경
  static const Color disabledForeground = Color(0xFF868E96);

  // ─────────────────────────────────────────────────────────────────
  // Skeleton & Overlay
  // ─────────────────────────────────────────────────────────────────

  /// 스켈레톤 로딩 배경
  static const Color skeleton = Color(0xFFE9ECEF);

  /// 스켈레톤 하이라이트 (shimmer)
  static const Color skeletonHighlight = Color(0xFFF8F9FA);

  /// 오버레이 (모달 뒤 배경)
  static const Color overlay = Color(0x80000000);

  /// 라이트 오버레이 (드롭다운 등)
  static const Color overlayLight = Color(0x1A000000);

  // ─────────────────────────────────────────────────────────────────
  // Gradient (그라디언트)
  // ─────────────────────────────────────────────────────────────────

  /// 그라디언트 시작색 (블루)
  static const Color gradientStart = Color(0xFF3B82F6);

  /// 그라디언트 끝색 (민트)
  static const Color gradientEnd = Color(0xFF06B6D4);

  /// 썸네일 다크 그라디언트 시작
  static const Color thumbGradientStart = Color(0xFF0f172a);

  /// 썸네일 다크 그라디언트 끝
  static const Color thumbGradientEnd = Color(0xFF1f2937);

  /// 계정 카드 그라데이션 (라이트)
  static const LinearGradient accountCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8FAFF), // 아주 연한 블루
      Color(0xFFF0F4FF), // 살짝 더 진한 블루
    ],
  );

  /// 계정 카드 그라데이션 (다크)
  static const LinearGradient accountCardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1F2E), // 어두운 네이비
      Color(0xFF1F2438), // 살짝 퍼플틱한 네이비
    ],
  );

  // ═══════════════════════════════════════════════════════════════════
  // Dark Mode
  // ═══════════════════════════════════════════════════════════════════

  // ─────────────────────────────────────────────────────────────────
  // Surface (배경)
  // ─────────────────────────────────────────────────────────────────

  /// 다크 기본 배경
  static const Color surfaceDark = Color(0xFF0D0F12);

  /// 다크 카드/컨테이너 배경
  static const Color surfaceContainerDark = Color(0xFF1A1D21);

  /// 다크 강조 컨테이너
  static const Color surfaceContainerHighDark = Color(0xFF24272C);

  /// 다크 구분선 (20% 흰색)
  static const Color dividerDark = Color(0x33FFFFFF);

  /// 다크 얇은 구분선
  static const Color dividerSubtleDark = Color(0x1AFFFFFF);

  // ─────────────────────────────────────────────────────────────────
  // Text (텍스트)
  // ─────────────────────────────────────────────────────────────────

  /// 다크 주요 텍스트
  static const Color textPrimaryDark = Color(0xFFECEFF3);

  /// 다크 보조 텍스트
  static const Color textSecondaryDark = Color(0xFFB0B8C1);

  /// 다크 힌트 텍스트
  static const Color textTertiaryDark = Color(0xFF7A828C);

  /// 다크 비활성 텍스트
  static const Color textDisabledDark = Color(0xFF5A6270);

  // ─────────────────────────────────────────────────────────────────
  // Accent (강조 - Toss Blue, 다크 조정)
  // ─────────────────────────────────────────────────────────────────

  /// 다크 프라이머리 (약간 밝게)
  static const Color primaryDark = Color(0xFF3C8DFF);

  /// 다크 프라이머리 눌림
  static const Color primaryPressedDark = Color(0xFF5A9FFF);

  /// 다크 프라이머리 소프트 (어두운 배경에 맞게 조정)
  static const Color primarySoftDark = Color(0xFF1A2A40);

  /// 다크 프라이머리 서브틀
  static const Color primarySubtleDark = Color(0xFF141E2D);

  // ─────────────────────────────────────────────────────────────────
  // Secondary (보조 컬러)
  // ─────────────────────────────────────────────────────────────────

  /// 다크 보조 퍼플
  static const Color secondaryDark = Color(0xFF9B6DFF);

  /// 다크 보조 퍼플 소프트
  static const Color secondarySoftDark = Color(0xFF1F1A30);

  // ─────────────────────────────────────────────────────────────────
  // Feedback (피드백)
  // ─────────────────────────────────────────────────────────────────

  /// 다크 성공
  static const Color successDark = Color(0xFF22C55E);

  /// 다크 성공 소프트
  static const Color successSoftDark = Color(0xFF0D2818);

  /// 다크 경고
  static const Color warningDark = Color(0xFFFBBF24);

  /// 다크 경고 소프트
  static const Color warningSoftDark = Color(0xFF2D2510);

  /// 다크 위험
  static const Color dangerDark = Color(0xFFEF4444);

  /// 다크 위험 소프트
  static const Color dangerSoftDark = Color(0xFF2D1515);

  /// 다크 정보
  static const Color infoDark = Color(0xFF3C8DFF);

  /// 다크 정보 소프트
  static const Color infoSoftDark = Color(0xFF1A2A40);

  // ─────────────────────────────────────────────────────────────────
  // Interactive (상호작용)
  // ─────────────────────────────────────────────────────────────────

  /// 다크 링크
  static const Color linkDark = Color(0xFF3C8DFF);

  /// 다크 비활성 배경
  static const Color disabledDark = Color(0xFF2C3038);

  /// 다크 비활성 전경
  static const Color disabledForegroundDark = Color(0xFF6B7280);

  // ─────────────────────────────────────────────────────────────────
  // Skeleton & Overlay
  // ─────────────────────────────────────────────────────────────────

  /// 다크 스켈레톤 배경
  static const Color skeletonDark = Color(0xFF24272C);

  /// 다크 스켈레톤 하이라이트
  static const Color skeletonHighlightDark = Color(0xFF2E3136);

  /// 다크 오버레이
  static const Color overlayDark = Color(0xBF000000);

  /// 다크 라이트 오버레이
  static const Color overlayLightDark = Color(0x33000000);

  // ===================================================================
  // Community Specific Colors
  // ===================================================================

  static const Color comm111827 = Color(0xFF111827);
  static const Color comm16A34A = Color(0xFF16A34A);
  static const Color comm1F1F1F = Color(0xFF1F1F1F);
  static const Color comm202225 = Color(0xFF202225);
  static const Color comm212529 = Color(0xFF212529);
  static const Color comm222222 = Color(0xFF222222);
  static const Color comm232323 = Color(0xFF232323);
  static const Color comm2563EB = Color(0xFF2563EB);
  static const Color comm2F67BF = Color(0xFF2F67BF);
  static const Color comm343A40 = Color(0xFF343A40);
  static const Color comm3F3F3F = Color(0xFF3F3F3F);
  static const Color comm3F72C4 = Color(0xFF3F72C4);
  static const Color comm495057 = Color(0xFF495057);
  static const Color comm4A4F57 = Color(0xFF4A4F57);
  static const Color comm5E5E5E = Color(0xFF5E5E5E);
  static const Color comm65676B = Color(0xFF65676B);
  static const Color comm666666 = Color(0xFF666666);
  static const Color comm6A6A6A = Color(0xFF6A6A6A);
  static const Color comm6B7280 = Color(0xFF6B7280);
  static const Color comm6E6E6E = Color(0xFF6E6E6E);
  static const Color comm707070 = Color(0xFF707070);
  static const Color comm7A7A7A = Color(0xFF7A7A7A);
  static const Color comm7E7E7E = Color(0xFF7E7E7E);
  static const Color comm7E8794 = Color(0xFF7E8794);
  static const Color comm868E96 = Color(0xFF868E96);
  static const Color comm888888 = Color(0xFF888888);
  static const Color comm8A8A8A = Color(0xFF8A8A8A);
  static const Color comm8B8B8B = Color(0xFF8B8B8B);
  static const Color comm8F96A3 = Color(0xFF8F96A3);
  static const Color comm9AA3AF = Color(0xFF9AA3AF);
  static const Color comm9B9B9B = Color(0xFF9B9B9B);
  static const Color comm9CA3AF = Color(0xFF9CA3AF);
  static const Color comm9E9E9E = Color(0xFF9E9E9E);
  static const Color comm9EA4AF = Color(0xFF9EA4AF);
  static const Color comm9F9F9F = Color(0xFF9F9F9F);
  static const Color commADB5BD = Color(0xFFADB5BD);
  static const Color commB0B0B0 = Color(0xFFB0B0B0);
  static const Color commB0B7C3 = Color(0xFFB0B7C3);
  static const Color commB2B2B2 = Color(0xFFB2B2B2);
  static const Color commB8BEC9 = Color(0xFFB8BEC9);
  static const Color commC9AE58 = Color(0xFFC9AE58);
  static const Color commD34B4B = Color(0xFFD34B4B);
  static const Color commD3D6DB = Color(0xFFD3D6DB);
  static const Color commD8D8D8 = Color(0xFFD8D8D8);
  static const Color commDCDCDC = Color(0xFFDCDCDC);
  static const Color commE34D4D = Color(0xFFE34D4D);
  static const Color commE5E5E5 = Color(0xFFE5E5E5);
  static const Color commE6F0FF = Color(0xFFE6F0FF);
  static const Color commE9ECEF = Color(0xFFE9ECEF);
  static const Color commEA580C = Color(0xFFEA580C);
  static const Color commEAF2FF = Color(0xFFEAF2FF);
  static const Color commEDEDED = Color(0xFFEDEDED);
  static const Color commEEEEEE = Color(0xFFEEEEEE);
  static const Color commEFEFEF = Color(0xFFEFEFEF);
  static const Color commEFF6FF = Color(0xFFEFF6FF);
  static const Color commF0F0F0 = Color(0xFFF0F0F0);
  static const Color commF0FDF4 = Color(0xFFF0FDF4);
  static const Color commF1F3F5 = Color(0xFFF1F3F5);
  static const Color commF2F3F5 = Color(0xFFF2F3F5);
  static const Color commF3F4F6 = Color(0xFFF3F4F6);
  static const Color commF6F6F6 = Color(0xFFF6F6F6);
  static const Color commF6F7F8 = Color(0xFFF6F7F8);
  static const Color commF8F9FA = Color(0xFFF8F9FA);
  static const Color commF9F9F9 = Color(0xFFF9F9F9);
  static const Color commFFF7ED = Color(0xFFFFF7ED);
  static const Color commFFF9F0 = Color(0xFFFFF9F0);
  static const Color commFFFFFF = Color(0xFFFFFFFF);
}
