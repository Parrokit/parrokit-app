import 'package:flutter/material.dart';
import 'package:parrokit/features/content-studio/captioning/presentation/clip_editor_screen.dart';
import 'package:parrokit/features/content-studio/tts/presentation/tts_screen.dart';
import 'package:parrokit/features/content-studio/video/presentation/video_screen.dart';
import 'package:parrokit/features/home/dashboard/presentation/widgets/dashboard_studio_switch_fab.dart';

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
    if (_selectedIndex == 0) return;
    await _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceContainer;

    return Scaffold(
      backgroundColor: bg,
      body: PopScope(
        canPop: _selectedIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBack();
        },
        child: SafeArea(
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
                  children: const [
                    _StudioPageSlot(child: CaptioningScreen()),
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
