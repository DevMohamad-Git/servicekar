import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';
import '../logic/service_entry_state.dart';

/// Section that displays mock service photos and provides an add-photo tile.
///
/// When [photos] is empty, a single large tile with a `+` icon invites the
/// user to add a photo.  When photos exist, they're rendered as a
/// horizontally-scrollable row of placeholder tiles, followed by the add
/// tile so the user can continue adding. The add tile wears a dashed
/// border — the universal "upload zone" affordance in modern minimal UIs.
class ServicePhotosSection extends StatelessWidget {
  const ServicePhotosSection({
    super.key,
    required this.photos,
    required this.onAddPhoto,
  });

  final List<MockServicePhoto> photos;
  final VoidCallback onAddPhoto;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (photos.isNotEmpty)
            ...photos.map(
              (photo) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: _PhotoTile(key: ValueKey(photo.id)),
              ),
            ),
          _AddPhotoTile(onTap: onAddPhoto),
        ],
      ),
    );
  }
}

/// A placeholder tile representing one uploaded service photo.
///
/// Renders as a grey rounded square with an image icon; no real image is
/// loaded because this is mock-only.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.7)),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 34,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// The dashed "upload zone" tile that opens the camera/gallery sheet.
class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.primary.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          foregroundPainter: _DashedRRectPainter(
            color: scheme.primary.withValues(alpha: 0.45),
          ),
          child: SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: Icon(
                Icons.add_rounded,
                size: 34,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a dashed rounded-rectangle border — Flutter ships no dashed
/// border out of the box, so this walks the rrect path in dash/gap steps.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    const dashLength = 6.0;
    const gapLength = 5.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
