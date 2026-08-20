import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';

/// Empty state shown when there are no customers to display.
///
/// Mirrors the reference: a soft grey circular icon, a short title, a
/// one-line hint, and a solid primary CTA with a plus icon.
class EmptyCustomerStateWidget extends StatelessWidget {
  const EmptyCustomerStateWidget({
    super.key,
    this.onCreatePressed,
  });

  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: _PeopleOutlineIcon(
                size: 40,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'مشتری یافت نشد',
              // titleMedium (18sp SemiBold) instead of the heavy 24sp Bold:
              // Vazirmatn reads cleaner at the smaller weight for this
              // one-line empty-state title.
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'هنوز مشتری‌ای ثبت نشده است.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onCreatePressed != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreatePressed,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addCustomer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hand-drawn outline of two people — a small figure behind a larger one —
/// drawn stroke-only so it reads as a light, custom empty-state glyph
/// instead of the bundled material people icon.
class _PeopleOutlineIcon extends StatelessWidget {
  const _PeopleOutlineIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PeopleOutlinePainter(color: color)),
    );
  }
}

class _PeopleOutlinePainter extends CustomPainter {
  _PeopleOutlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw in a 40-unit design space, scaled to whatever canvas we get.
    final scale = size.shortestSide / 40.0;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.scale(scale);

    // Figure behind: smaller, tucked into the upper-left.
    canvas.drawCircle(const Offset(13, 12.5), 4.5, stroke);
    final backShoulders = Path()
      ..moveTo(5.5, 25)
      ..quadraticBezierTo(13, 19, 20.5, 25);
    canvas.drawPath(backShoulders, stroke);

    // Figure in front: larger, lower-right, slightly overlapping.
    canvas.drawCircle(const Offset(27, 17.5), 6, stroke);
    final frontShoulders = Path()
      ..moveTo(17, 32)
      ..quadraticBezierTo(27, 25.5, 37, 32);
    canvas.drawPath(frontShoulders, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeopleOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}
