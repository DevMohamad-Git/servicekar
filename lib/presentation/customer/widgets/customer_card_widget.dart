import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';

/// Status variants used only to present the UI mock cards.
enum CustomerCardStatus { debtor, creditor, settled }

extension CustomerCardStatusX on CustomerCardStatus {
  String get label => switch (this) {
    CustomerCardStatus.debtor => 'بدهکار',
    CustomerCardStatus.creditor => 'بستانکار',
    CustomerCardStatus.settled => 'تسویه',
  };
}

/// Presentation data for one customer card.
///
/// This is deliberately separate from the domain entity: the list is using
/// mock UI data in this task and does not read the domain or data layers.
class CustomerCardData {
  const CustomerCardData({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.status,
    this.balance,
  });

  /// Stable identifier used to open this customer's profile.
  final String id;

  final String name;
  final String phoneNumber;
  final CustomerCardStatus status;

  /// Outstanding balance in Toman, shown only for [CustomerCardStatus.debtor]
  /// and [CustomerCardStatus.creditor]. Ignored for [CustomerCardStatus.settled].
  final double? balance;
}

/// Tappable summary card for one customer, designed for scan-ability.
///
/// The card reads as a distinct white surface because the list body sits on
/// the app's neutral grey background — tonal contrast, not an outline,
/// defines where each card starts and ends. Inside, the layout is a fixed
/// two-zone grid so every row aligns when scanning down the list:
///
///   * start side — status-tinted avatar, then a name + phone column;
///   * end side   — the plain status word (بدهکار / بستانکار / تسویه) in its
///     semantic colour, anchored to the card's end edge so every card's
///     status sits at the same x-position.
///
/// Tappability is signalled by a soft brand-tinted ripple on press instead
/// of a chevron.
class CustomerCardWidget extends StatelessWidget {
  const CustomerCardWidget({super.key, required this.customer, this.onTap});

  final CustomerCardData customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(customer.status, scheme);

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          // The soft brand-tinted ripple is the card's tappability
          // affordance (the end chevron was removed): subtle enough not to
          // compete with the content, visible enough to confirm the tap.
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                _CustomerAvatar(color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Headline-style name, tuned down from the 24sp Bold
                        // that read too heavy: 18sp SemiBold keeps it the
                        // card's main line without shouting.
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: kTextPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatPhoneNumber(customer.phoneNumber),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              // Subtitle-style line under the name: 16sp
                              // regular so it stays subordinate to the name.
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Plain status word — no tag, icon, or amount, per the
                // requested simplification. Only the semantic colour stays.
                Text(
                  customer.status.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular avatar tinted by the customer's status colour, holding a
/// person glyph instead of initials.
class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withValues(alpha: 0.12),
      child: _PersonOutlineIcon(
        size: 24,
        // Icon colour softened a touch so the status tint stays
        // informational instead of shouting next to the card text.
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}

/// Accent colour for one status: debt is red, settled is green, credit is
/// neutral grey — the same mapping the account summary uses.
Color _statusColor(CustomerCardStatus status, ColorScheme scheme) =>
    switch (status) {
      CustomerCardStatus.debtor => scheme.error,
      CustomerCardStatus.creditor => kGrey2Color,
      CustomerCardStatus.settled => kSuccessColor,
    };

/// Groups an 11-digit mobile number for readability: "09121234567" →
/// "0912 123 4567". Longer/shorter numbers are left untouched.
String _formatPhoneNumber(String phone) {
  if (phone.length != 11) return phone;
  return '${phone.substring(0, 4)} ${phone.substring(4, 7)} '
      '${phone.substring(7)}';
}

/// Hand-drawn outline of a single person (head + shoulders) — the
/// stroke-only sibling of the empty/error state icons, used as the
/// profile placeholder in the customer avatar.
class _PersonOutlineIcon extends StatelessWidget {
  const _PersonOutlineIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PersonOutlinePainter(color: color)),
    );
  }
}

class _PersonOutlinePainter extends CustomPainter {
  _PersonOutlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw in a 40-unit design space, scaled to whatever canvas we get.
    final scale = size.shortestSide / 40.0;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      // Slightly heavier than the /20 ratio used by the 40dp+ state
      // icons, so the smaller 24dp avatar glyph still reads clearly.
      ..strokeWidth = size.shortestSide / 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.scale(scale);

    // Head.
    canvas.drawCircle(const Offset(20, 12), 5, stroke);

    // Shoulders as a gentle hump.
    final shoulders = Path()
      ..moveTo(10.5, 28.5)
      ..quadraticBezierTo(20, 22, 29.5, 28.5);
    canvas.drawPath(shoulders, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PersonOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}
