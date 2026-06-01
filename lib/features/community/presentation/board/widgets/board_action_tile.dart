import 'package:flutter/material.dart';

class BoardActionTile extends StatefulWidget {
  const BoardActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<BoardActionTile> createState() => _BoardActionTileState();
}

class _BoardActionTileState extends State<BoardActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.selected ? widget.accentColor : const Color(0xFFD8D8D8);
    final borderWidth = _pressed ? 2.0 : 1.4;
    final contentColor = widget.selected
        ? widget.accentColor
        : const Color.fromARGB(255, 193, 193, 193);
    final labelColor =
        widget.selected ? widget.accentColor : const Color(0xFF5E5E5E);

    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: contentColor),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
