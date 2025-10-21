import 'package:flutter/material.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    required this.time,
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
    this.leadingIcon = Icons.edit_note_rounded,
  }) : _isSkeleton = false;

  /// 로딩 스켈레톤 전용
  const ActivityTile.skeleton({
    super.key,
    required this.cardBg,
    required this.subtle,
    this.leadingIcon = Icons.edit_note_rounded,
  })  : title = '',
        subtitle = null,
        subtitleWidget = null,
        time = '',
        textPrimary = Colors.transparent,
        textSecondary = Colors.transparent,
        onTap = _noop,
        _isSkeleton = true;

  // 데이터
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final String time;

  // 스타일
  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;
  final IconData leadingIcon;

  // 동작
  final VoidCallback onTap;

  // 내부 플래그
  final bool _isSkeleton;

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    if (_isSkeleton) {
      // 🔹 로딩 스켈레톤 UI
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: subtle),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: subtle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 12, color: subtle),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 10, color: subtle),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      );
    }

    // 🔹 실제 타일 UI
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: subtle),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: subtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(leadingIcon, size: 20, color: textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 서브타이틀: 위젯 우선, 없으면 문자열
                  if (subtitleWidget != null)
                    subtitleWidget!
                  else if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 시간: 값이 있을 때만 표시
            if (time.isNotEmpty)
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}