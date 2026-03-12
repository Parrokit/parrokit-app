// ============================================================================
// lib/core/router/app_routes.dart
// ============================================================================
//
// [역할]
// 라우트 이름 및 경로 상수 정의.
// 앱 전체에서 사용하는 라우트 이름과 경로를 중앙 집중 관리.
//
// [레이어]
// Core Layer > Router
// ============================================================================

/// 라우트 이름/경로 상수.
abstract class AppRoutes {
  // ─────────────────────────────────────────────────────────────────
  // Route Names
  // ─────────────────────────────────────────────────────────────────

  static const dashboard = 'dashboard';
  static const explore = 'explore';
  static const library = 'library';
  static const more = 'more';
  static const clips = 'clips';
  static const recom = 'recom';
  static const recomResult = 'recom_result';
  static const recents = 'recents';
  static const clipsCreate = 'clips_create';
  static const clipsEdit = 'clips_edit';
  static const clipsPlay = 'clips_play';
  static const intro = 'intro';
  static const auth = 'auth';
  static const payment = 'payment';
  static const paymentSuccess = 'payment_success';
  static const paymentFail = 'payment_fail';

  // ─────────────────────────────────────────────────────────────────
  // Route Paths
  // ─────────────────────────────────────────────────────────────────

  static const dashboardPath = '/dashboard';
  static const explorePath = '/explore';
  static const libraryPath = '/library';
  static const morePath = '/more';
  static const clipsPath = '/clips';
  static const recentsPath = '/recents';
  static const clipsCreatePath = 'create';
  static const clipsEditPath = 'edit';
  static const clipsPlayPath = 'play';
  static const introPath = '/intro';
  static const authPath = '/auth';
  static const paymentPath = '/payment';
  static const paymentSuccessPath = '/payment/success';
  static const paymentFailPath = '/payment/fail';
}
