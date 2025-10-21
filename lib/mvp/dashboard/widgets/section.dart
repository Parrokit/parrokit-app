import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  const Section({
    required this.title,
    this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
    required this.padding,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Color textPrimary;
  final Color textSecondary;
  final EdgeInsets padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
