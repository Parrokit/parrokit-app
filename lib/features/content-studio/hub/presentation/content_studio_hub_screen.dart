import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/app/router/app_routes.dart';
import 'package:parrokit/core/state/provider/user_provider.dart';
import 'package:parrokit/features/content-studio/captioning/presentation/captioning_screen.dart';
import 'package:parrokit/features/content-studio/tts/presentation/tts_screen.dart';
import 'package:parrokit/features/content-studio/video/presentation/video_screen.dart';
import 'package:parrokit/features/home/dashboard/presentation/widgets/dashboard_studio_switch_fab.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'content_studio_app_bar.dart';
import 'widgets/content_studio_exit_confirm_sheet.dart';

class ContentStudioHubScreen extends StatefulWidget {
  const ContentStudioHubScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<ContentStudioHubScreen> createState() => _ContentStudioHubScreenState();
}

class _ContentStudioHubScreenState extends State<ContentStudioHubScreen> {
  late final PageController _pageController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 2);
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void didUpdateWidget(covariant ContentStudioHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = widget.initialIndex.clamp(0, 2);
    if (nextIndex == _selectedIndex) return;
    _selectedIndex = nextIndex;
    _pageController.jumpToPage(nextIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setPage(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleBack() async {
    final router = GoRouter.of(context);
    final shouldExit = await showContentStudioExitConfirmSheet(context);
    if (shouldExit != true) return;
    router.go(AppRoutes.dashboardPath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : theme.colorScheme.surface;
    final appBarTitle = switch (_selectedIndex) {
      0 => '편집',
      1 => 'TTS 생성',
      _ => 'Video 생성',
    };

    return Scaffold(
      backgroundColor: bg,
      appBar: ContentStudioAppBar(
        title: appBarTitle,
        coins: userProvider.coins,
        onBack: _handleBack,
        backgroundColor: bg,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBack();
        },
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 108),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (_selectedIndex == index) return;
                    setState(() => _selectedIndex = index);
                  },
                  children: [
                    _StudioPageSlot(
                      child: CaptioningScreen(
                        showAppBar: false,
                        onClose: (_) async => context.go(
                          AppRoutes.dashboardPath,
                        ),
                      ),
                    ),
                    _StudioPageSlot(child: TtsScreen()),
                    _StudioPageSlot(child: VideoScreen()),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: DashboardStudioSwitchFab(
                    selectedIndex: _selectedIndex,
                    onSelectedIndexChanged: _setPage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudioPageSlot extends StatefulWidget {
  const _StudioPageSlot({required this.child});

  final Widget child;

  @override
  State<_StudioPageSlot> createState() => _StudioPageSlotState();
}

class _StudioPageSlotState extends State<_StudioPageSlot>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
