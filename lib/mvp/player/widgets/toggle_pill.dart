import 'package:flutter/material.dart';
class TogglePill extends StatelessWidget {
  const TogglePill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.isLight = true,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool isLight;


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color bg = active
        ? (isLight ? cs.primary.withOpacity(0.14) : Colors.white24)
        : (isLight ? cs.surface.withOpacity(0.9) : Colors.white12);
    final Color fg = active
        ? (isLight ? cs.primary : Colors.white)
        : (isLight ? cs.onSurface : Colors.white70);
    final Color? border = active
        ? (isLight ? cs.primary.withOpacity(0.6) : Colors.white30)
        : null; // 비활성일 때는 테두리 없음

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: border != null ? Border.all(color: border, width: 0.8) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style:
                TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
