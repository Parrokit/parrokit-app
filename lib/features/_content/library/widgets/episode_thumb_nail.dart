import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
class EpisodeThumbnail extends StatelessWidget {
  const EpisodeThumbnail({
    required this.imageProvider,
    required this.duration,
    this.width = 64,
    this.height = 48,
    super.key,
  });

  final ImageProvider? imageProvider;
  final String? duration;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant, width: 0.8),
      ),
      child: const Center(child: Icon(Icons.play_arrow_rounded, size: 28)),
    );

    final thumb = (imageProvider == null)
        ? placeholder
        : ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: imageProvider!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true, // ✅ 깜빡임 줄이기
        filterQuality: FilterQuality.medium,
      ),
    );

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            thumb,
            if (imageProvider != null)
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black26,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
        if (duration != null) ...[
          const SizedBox(height: 6),
          Text(
            duration!,
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}