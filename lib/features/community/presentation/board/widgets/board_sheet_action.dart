import 'package:flutter/material.dart';

class BoardSheetAction extends StatelessWidget {
  const BoardSheetAction({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDestructive ? const Color(0xFFD34B4B) : const Color(0xFF222222);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
