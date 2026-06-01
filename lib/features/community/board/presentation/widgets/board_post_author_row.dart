import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:shimmer/shimmer.dart';
import 'package:parrokit/core/theme/app_colors.dart';

class BoardPostAuthorRow extends StatelessWidget {
  const BoardPostAuthorRow({
    super.key,
    required this.post,
    required this.currentUser,
    required this.cachedAuthor,
    required this.isMe,
    required this.timeAgoText,
  });

  final Post post;
  final AppUser? currentUser;
  final AppUser? cachedAuthor;
  final bool isMe;
  final String timeAgoText;

  @override
  Widget build(BuildContext context) {
    final photoUrl = (isMe ? currentUser?.photoUrl : cachedAuthor?.photoUrl) ?? post.authorAvatarUrl;
    final displayName = (isMe ? currentUser?.displayName : cachedAuthor?.displayName) ?? post.authorNickname;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 220, 220, 220),
            ),
            child: ClipOval(
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person, size: 30, color: Colors.white),
                    )
                  : const Icon(Icons.person, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                timeAgoText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
