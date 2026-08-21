import 'package:flutter/material.dart';

/// Loading presentation for the customer list.
///
/// Mirrors the redesigned card skeleton: an avatar circle, name/phone
/// placeholder bars, and a small status bar on the end side — so the
/// loading shape matches the data shape it will become.
class CustomerListLoadingStateWidget extends StatelessWidget {
  const CustomerListLoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _CustomerCardSkeleton(placeholderColor: placeholderColor),
    );
  }
}

class _CustomerCardSkeleton extends StatelessWidget {
  const _CustomerCardSkeleton({required this.placeholderColor});

  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _SkeletonCircle(color: placeholderColor, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkeletonBar(color: placeholderColor, width: 130, height: 16),
                const SizedBox(height: 8),
                _SkeletonBar(color: placeholderColor, width: 96, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // A short bar mirrors the plain status word on the end side.
          _SkeletonBar(color: placeholderColor, width: 56, height: 14),
        ],
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.color,
    required this.width,
    required this.height,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Error presentation for the customer list.
///
/// Mirrors the reference: a red-outlined circular "!" icon, a short title,
/// a retry hint, and a blue retry button with a refresh icon.
class CustomerListErrorStateWidget extends StatelessWidget {
  const CustomerListErrorStateWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // LayoutBuilder + ConstrainedBox keep the column truly centered in the
    // remaining viewport: a bare SingleChildScrollView fills the viewport
    // and pins its child to the top (scroll offset 0), which reads as
    // "not centered". Forcing the child to at least the padded viewport
    // height lets the inner Center do the vertical centering.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 48
                  ? constraints.maxHeight - 48
                  : 0,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.error.withValues(alpha: 0.06),
                      border: Border.all(
                        color: scheme.error.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: _ErrorOutlineIcon(size: 56, color: scheme.error),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'خطایی رخ داده است',
                    // Larger than the empty-state title but still SemiBold
                    // (w600) — the weight the user preferred over heavy
                    // 24sp Bold for these one-line states.
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'لطفاً دوباره تلاش کنید.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 26),
                    label: const Text('تلاش مجدد'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Hand-drawn outline of an alert ring with an exclamation mark — the
/// stroke-only sibling of [_PeopleOutlineIcon] in the empty state, so the
/// error and empty states share one custom, non-material glyph language.
class _ErrorOutlineIcon extends StatelessWidget {
  const _ErrorOutlineIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ErrorOutlinePainter(color: color)),
    );
  }
}

class _ErrorOutlinePainter extends CustomPainter {
  _ErrorOutlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      // Scale the stroke with the icon so it stays visually consistent
      // (2.0 at 40dp, ~2.8 at the 56dp error icon), matching the empty
      // state's people icon which scales its stroke with the canvas.
      ..strokeWidth = size.shortestSide / 20
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.36;

    // Outlined alert ring.
    canvas.drawCircle(center, radius, stroke);

    // Exclamation stem, kept inside the ring.
    final stem = Path()
      ..moveTo(center.dx, center.dy - radius * 0.42)
      ..lineTo(center.dx, center.dy + radius * 0.08);
    canvas.drawPath(stem, stroke);

    // Exclamation dot, filled so it reads as a glyph, not a stroke.
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius * 0.30),
      radius * 0.08,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ErrorOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}
