import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.emphasized = false,
    this.bg,
    this.fg,
    this.size = 44,
    this.isLight = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool emphasized;
  final Color? bg;
  final Color? fg;
  final double size;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final background = bg ??
        (emphasized
            ? Colors.white
            : (isLight ? cs.surface.withOpacity(0.9) : Colors.white12));
    final foreground = fg ??
        (emphasized ? Colors.black : (isLight ? cs.onSurface : Colors.white));

    final btn = InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: foreground, size: emphasized ? 26 : 22),
      ),
    );

    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
