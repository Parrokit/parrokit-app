import 'package:flutter/material.dart';
class Badge extends StatelessWidget {
  const Badge({required this.label, required this.icon, super.key});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // ✅ 다크/라이트 무시하고 고정 색상 사용
    const Color fixedColor = Colors.white; // 필요시 Colors.white 등으로 변경

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fixedColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fixedColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fixedColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: fixedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}