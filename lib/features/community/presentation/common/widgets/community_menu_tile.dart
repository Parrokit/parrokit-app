import 'package:flutter/material.dart';
import '../models/community_menu_item.dart';

class CommunityMenuTile extends StatelessWidget {
  const CommunityMenuTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final CommunityMenuItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: item.colors.bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: item.colors.iconColor, size: 20),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFB0B7C3),
        size: 24,
      ),
      onTap: onTap ?? () {},
    );
  }
}
