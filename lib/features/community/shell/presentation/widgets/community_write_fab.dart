import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';

class CommunityWriteFab extends StatelessWidget {
  const CommunityWriteFab({
    super.key,
    required this.isExtended,
    required this.onTap,
  });

  final bool isExtended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.communityBoardAccent,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.22), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isExtended ? 20.0 : 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: colorScheme.onPrimary, size: 24),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: isExtended ? null : 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          '글쓰기',
                          style: TextStyle(color: colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
