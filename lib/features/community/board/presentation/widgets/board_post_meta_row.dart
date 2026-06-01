import 'package:flutter/material.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/core/theme/app_colors.dart';

class BoardPostMetaRow extends StatelessWidget {
  const BoardPostMetaRow({
    super.key,
    required this.post,
    required this.likeMetaColor,
    required this.likeIconColor,
  });

  final Post post;
  final Color likeMetaColor;
  final Color likeIconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 245, 245),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Text(
                  post.category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.comm6E6E6E,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 20, color: AppColors.comm7E7E7E),
              ],
            ),
          ),
          const Spacer(),
          const Icon(Icons.remove_red_eye_outlined, color: AppColors.commB2B2B2, size: 24),
          const SizedBox(width: 6),
          Text(
            '${post.viewCount}',
            style: const TextStyle(color: AppColors.comm9F9F9F, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 18),
          Icon(Icons.thumb_up_outlined, color: likeIconColor, size: 24),
          const SizedBox(width: 6),
          Text(
            '${post.likeCount}',
            style: TextStyle(color: likeMetaColor, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
