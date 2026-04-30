import 'package:flutter/material.dart';

class CommunityNotificationScreen extends StatefulWidget {
  const CommunityNotificationScreen({super.key});

  @override
  State<CommunityNotificationScreen> createState() =>
      _CommunityNotificationScreenState();
}

class _CommunityNotificationScreenState
    extends State<CommunityNotificationScreen> {
  late final List<_NotificationItem> _items;
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _items = [
      const _NotificationItem(
        icon: Icons.campaign_rounded,
        iconColor: Color(0xFF6B7280),
        iconBgColor: Color(0xFFF3F4F6),
        category: '공지',
        title: '새로운 쉐도잉 챌린지가 시작됐어요.',
        timeAgo: '2일 전',
      ),
      const _NotificationItem(
        icon: Icons.record_voice_over_rounded,
        iconColor: Color(0xFF2563EB),
        iconBgColor: Color(0xFFEFF6FF),
        category: '학습 팁',
        title: '발음 교정에 도움 되는 반복 구간이 추천됐어요.',
        timeAgo: '4일 전',
      ),
      const _NotificationItem(
        icon: Icons.subtitles_rounded,
        iconColor: Color(0xFFEA580C),
        iconBgColor: Color(0xFFFFF7ED),
        category: '자막',
        title: '업로드한 영상의 자동 자막 생성이 완료됐어요.',
        timeAgo: '1주 전',
      ),
      const _NotificationItem(
        icon: Icons.forum_rounded,
        iconColor: Color(0xFF16A34A),
        iconBgColor: Color(0xFFF0FDF4),
        category: '커뮤니티',
        title: '내 글에 새로운 댓글이 달렸어요.',
        timeAgo: '2주 전',
      ),
    ];
  }

  void _showItemActionSheet(int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        '삭제',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE34D4D),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 24, color: Colors.black),
        ),
        title: const Text(
          '알림',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isDeleteMode = true),
            icon: const Icon(Icons.delete_outline_rounded,
                size: 24, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined,
                size: 24, color: Colors.black87),
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEDEDED)),
        ),
      ),
      body: Column(
        children: [
          if (_isDeleteMode)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEDEDED))),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _items.isEmpty
                            ? null
                            : () => setState(() => _items.clear()),
                        child: const Text(
                          '전체삭제',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE34D4D),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isDeleteMode = false),
                        child: const Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      '알림이 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF2F3F5)),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: item.iconBgColor,
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Icon(item.icon, size: 20, color: item.iconColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.category,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            item.timeAgo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              if (_isDeleteMode) {
                                                setState(
                                                    () => _items.removeAt(index));
                                              } else {
                                                _showItemActionSheet(index);
                                              }
                                            },
                                            splashRadius: 18,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: Icon(
                                              _isDeleteMode
                                                  ? Icons.close_rounded
                                                  : Icons.more_vert_rounded,
                                              size: 24,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String category;
  final String title;
  final String timeAgo;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.category,
    required this.title,
    required this.timeAgo,
  });
}
