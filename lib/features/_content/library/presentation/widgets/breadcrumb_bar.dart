import 'package:flutter/material.dart';

/// [역할]
/// 라이브러리 폴더 계층 구조를 나타내는 브레드크럼 네비게이션 바.
///
/// [path] 리스트를 순서대로 나열하며, 클릭 시 해당 계층으로 이동 이벤트를 발생시킵니다.
class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({
    super.key,
    required this.path,
    required this.onTapCrumb,
  });

  final List<String> path;
  final ValueChanged<int> onTapCrumb;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (int i = 0; i < path.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onTapCrumb(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  path[i],
                  style: TextStyle(
                    color: i == path.length - 1
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.75),
                    fontWeight: i == path.length - 1
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (i != path.length - 1)
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
          ]
        ],
      ),
    );
  }
}
