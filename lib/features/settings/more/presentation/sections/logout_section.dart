import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:parrokit/features/community/shell/presentation/providers/community_provider.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:provider/provider.dart';

/// 로그아웃 섹션.
class LogoutSection extends StatelessWidget {
  const LogoutSection({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '로그아웃',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final userProvider = context.read<UserProvider>();
    final communityProvider = context.read<CommunityProvider>();
    
    try {
      // 1. 커뮤니티 전역 상태(글 목록, 스크랩, 조회수 등) 초기화
      communityProvider.clear();
      
      // 2. 실제 인증 로그아웃 처리
      await userProvider.signOut();
      
      if (context.mounted) {
        showToast('로그아웃되었습니다.');
        context.go('${AppRoutes.authPath}/${AppRoutes.signInPath}');
      }
    } catch (e) {
      if (context.mounted) showToast('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => _confirmLogout(context),
        child: Text(
          '로그아웃',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
