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
  static const community = 'community';
  static const explore = 'explore';
  static const library = 'library';
  static const more = 'more';
  static const profileEdit = 'profile_edit';
  static const clips = 'clips';
  static const recom = 'recom';
  static const recomResult = 'recom_result';
  static const recents = 'recents';
  static const clipsCreate = 'clips_create';
  static const clipsEdit = 'clips_edit';
  static const clipsPlay = 'clips_play';
  static const intro = 'intro';
  static const auth = 'auth';
  static const signIn = 'sign_in';
  static const signUp = 'sign_up';
  static const findPw = 'find_pw';
  static const onboarding = 'onboarding';
  static const payment = 'payment';
  static const paymentSuccess = 'payment_success';
  static const paymentFail = 'payment_fail';
  static const communityBoardView = 'community_board_view';
  static const communityBoardWrite = 'community_board_write';
  static const communityQuestionWrite = 'community_question_write';
  static const communityQuestionView = 'community_question_view';
  static const communityVoteWrite = 'community_vote_write';
  static const communityVoteView = 'community_vote_view';
  static const communityMenu = 'community_menu';
  static const communityNotification = 'community_notification';
  static const communityActivity = 'community_activity';

  // ─────────────────────────────────────────────────────────────────
  // Route Paths
  // ─────────────────────────────────────────────────────────────────

  static const dashboardPath = '/dashboard';
  static const communityPath = '/community';
  static const communityBoardViewPath = '/community/board/:postId';
  static const communityBoardWritePath = '/community/board/write';
  static const communityQuestionWritePath = '/community/question/write';
  static const communityQuestionViewPath = '/community/question/:questionId';
  static const communityVoteWritePath = '/community/vote/write';
  static const communityVoteViewPath = '/community/vote/:voteId';
  static const communityMenuPath = '/community/menu';
  static const communityNotificationPath = '/community/notification';
  static const communityActivityPath = '/community/activity';
  static const explorePath = '/explore';
  static const libraryPath = '/library';
  static const morePath = '/more';
  static const profileEditPath = 'profile_edit';
  static const clipsPath = '/clips';
  static const recentsPath = '/recents';
  static const clipsCreatePath = 'create';
  static const clipsEditPath = 'edit';
  static const clipsPlayPath = 'play';
  static const introPath = '/intro';
  static const authPath = '/auth'; // Root of auth flows
  static const signInPath = 'sign-in';
  static const signUpPath = 'sign-up';
  static const findPwPath = 'find-pw';
  static const onboardingPath = '/onboarding';
  static const paymentPath = '/payment';
  static const paymentSuccessPath = '/payment/success';
  static const paymentFailPath = '/payment/fail';

  static String communityBoardViewPathOf(String postId) =>
      '/community/board/$postId';

  static String communityQuestionViewPathOf(String questionId) =>
      '/community/question/$questionId';

  static String communityVoteViewPathOf(String voteId) =>
      '/community/vote/$voteId';

  static String communityActivityPathOf({required String boardType, required String activityType}) =>
      '/community/activity?boardType=$boardType&activityType=$activityType';
}
