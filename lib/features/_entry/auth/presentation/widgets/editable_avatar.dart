// ============================================================================
// lib/features/_entry/auth/presentation/widgets/editable_avatar.dart
// ============================================================================
//
// [역할]
// 편집 가능한 사용자 아바타 위젯.
// 프로필 이미지 표시 및 편집 버튼 제공.
//
// [레이어]
// Presentation Layer > Widgets
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'avatar_selection_sheet.dart';

/// 편집 가능한 사용자 아바타.
class EditableAvatar extends StatelessWidget {
  /// 사용자 프로필 이미지 URL
  final String? photoUrl;

  /// 아바타 크기
  final double size;

  const EditableAvatar({
    super.key,
    required this.photoUrl,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => const AvatarSelectionSheet(),
          showDragHandle: true,
        );
      },
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainerHighest,
              border: Border.all(
                color: cs.outlineVariant,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildAvatar(photoUrl, cs),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: Icon(
                Icons.edit_rounded,
                size: 12,
                color: cs.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, ColorScheme cs) {
    if (photoUrl == null) {
      return Center(
        child: Icon(
          Icons.person_outline,
          size: size * 0.55, // 크기에 비례하여 아이콘 크기 조정
          color: cs.onSurfaceVariant,
        ),
      );
    }

    return SvgPicture.network(
      photoUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      placeholderBuilder: (context) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
