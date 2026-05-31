import 'package:flutter/material.dart';

class CommunityMenuScreen extends StatelessWidget {
  const CommunityMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '커뮤니티 메뉴',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 24, color: Colors.black),
                  tooltip: '닫기',
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            const SizedBox(height: 12),
            _buildSectionTitle('나의 활동'),
            _buildCategoryLabel('일반 게시판'),
            _buildMenuTile(
              icon: Icons.article_rounded,
              iconColor: Colors.blue[600]!,
              bgColor: Colors.blue[50]!,
              title: '내 글',
            ),
            _buildMenuTile(
              icon: Icons.chat_bubble_rounded,
              iconColor: Colors.blue[600]!,
              bgColor: Colors.blue[50]!,
              title: '내 댓글',
            ),
            _buildMenuTile(
              icon: Icons.thumb_up_rounded,
              iconColor: Colors.blue[600]!,
              bgColor: Colors.blue[50]!,
              title: '내 공감',
            ),
            _buildMenuTile(
              icon: Icons.favorite_rounded,
              iconColor: Colors.blue[600]!,
              bgColor: Colors.blue[50]!,
              title: '내 공감 댓글',
            ),
            _buildMenuTile(
              icon: Icons.bookmark_rounded,
              iconColor: Colors.blue[600]!,
              bgColor: Colors.blue[50]!,
              title: '내 스크랩',
            ),
            const SizedBox(height: 8),
            _buildCategoryLabel('질문 게시판'),
            _buildMenuTile(
              icon: Icons.help_rounded,
              iconColor: Colors.deepPurple[600]!,
              bgColor: Colors.deepPurple[50]!,
              title: '내 질문',
            ),
            _buildMenuTile(
              icon: Icons.forum_rounded,
              iconColor: Colors.deepPurple[600]!,
              bgColor: Colors.deepPurple[50]!,
              title: '내 답변',
            ),
            _buildMenuTile(
              icon: Icons.chat_rounded,
              iconColor: Colors.deepPurple[600]!,
              bgColor: Colors.deepPurple[50]!,
              title: '내 답변에 대한 댓글',
            ),
            _buildMenuTile(
              icon: Icons.thumb_up_rounded,
              iconColor: Colors.deepPurple[600]!,
              bgColor: Colors.deepPurple[50]!,
              title: '공감한 질문',
            ),
            _buildMenuTile(
              icon: Icons.favorite_rounded,
              iconColor: Colors.deepPurple[600]!,
              bgColor: Colors.deepPurple[50]!,
              title: '공감한 답변',
            ),
            _buildMenuTile(
              icon: Icons.bookmark_rounded,
              iconColor: Colors.deepPurple[600]!,
              bgColor: Colors.deepPurple[50]!,
              title: '내 스크랩 질문',
            ),
            const SizedBox(height: 8),
            _buildCategoryLabel('투표 게시판'),
            _buildMenuTile(
              icon: Icons.how_to_vote_rounded,
              iconColor: Colors.teal[600]!,
              bgColor: Colors.teal[50]!,
              title: '내 투표',
            ),
            _buildMenuTile(
              icon: Icons.chat_rounded,
              iconColor: Colors.teal[600]!,
              bgColor: Colors.teal[50]!,
              title: '내 투표 댓글',
            ),
            _buildMenuTile(
              icon: Icons.thumb_up_rounded,
              iconColor: Colors.teal[600]!,
              bgColor: Colors.teal[50]!,
              title: '공감한 투표',
            ),
            _buildMenuTile(
              icon: Icons.favorite_rounded,
              iconColor: Colors.teal[600]!,
              bgColor: Colors.teal[50]!,
              title: '공감한 투표 댓글',
            ),
            _buildMenuTile(
              icon: Icons.bookmark_rounded,
              iconColor: Colors.teal[600]!,
              bgColor: Colors.teal[50]!,
              title: '스크랩한 투표',
            ),
            const SizedBox(height: 18),
            _buildSectionTitle('커뮤니티 설정'),
            _buildMenuTile(
              icon: Icons.notifications_rounded,
              iconColor: Colors.purple[500]!,
              bgColor: Colors.purple[50]!,
              title: '알림 설정',
            ),
            _buildMenuTile(
              icon: Icons.shield_rounded,
              iconColor: Colors.teal[600]!,
              bgColor: Colors.teal[50]!,
              title: '차단 사용자 관리',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9AA3AF),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF7E8794),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Color(0xFFB0B7C3), size: 24),
      onTap: onTap ?? () {},
    );
  }
}
