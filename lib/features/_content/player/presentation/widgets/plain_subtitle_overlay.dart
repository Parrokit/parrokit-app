import 'package:flutter/material.dart';

class PlainSubtitleOverlay extends StatelessWidget {
  const PlainSubtitleOverlay({
    super.key,
    required this.ja,
    required this.pron,
    required this.ko,
  });

  final String ja;
  final String pron;
  final String ko;

  @override
  Widget build(BuildContext context) {
    const shadow = [
      Shadow(blurRadius: 3, color: Colors.black54, offset: Offset(0, 1))
    ];
    TextStyle base(double size,
            {FontWeight w = FontWeight.w600, Color c = Colors.white}) =>
        TextStyle(fontSize: size, fontWeight: w, color: c, shadows: shadow);

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ja, textAlign: TextAlign.center, style: base(18)),
              const SizedBox(height: 4),
              Text(pron,
                  textAlign: TextAlign.center,
                  style: base(14, w: FontWeight.w500, c: Colors.white70)),
              const SizedBox(height: 4),
              Text(ko, textAlign: TextAlign.center, style: base(16)),
            ],
          ),
        ),
      ),
    );
  }
}
