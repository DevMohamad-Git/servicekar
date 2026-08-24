import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';

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
///   * end side   — data-first status zone: the bare amount (red for
///     debtors, green for creditors) or the quiet «تسویه» pill, anchored
///     to the card's end edge so every card's state sits at the same
///     x-position.
///
/// Tappability is signalled by a soft brand-tinted ripple on press plus
/// the trailing chevron.
class CustomerCardWidget extends StatelessWidget {
  const CustomerCardWidget({super.key, required this.customer, this.onTap});

  final CustomerCardData customer;
  final VoidCallback? onTap;

  /// Whether the end side shows the bare amount. Settled customers
  /// carry no number — the green «تسویه» pill alone says enough.
  bool get _showBalance =>
      customer.balance != null &&
      customer.status != CustomerCardStatus.settled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(customer.status, scheme);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Hairline border (the app's field-card recipe) so the card keeps
        // a crisp edge even when it sits on a white surface, while the
        // soft shadow still lifts it off the grey list canvas.
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.5)),
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
                CustomerAvatar(color: statusColor),
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
                        // Headline-style name kept one weight below bold
                        // (w500): still the card's main line, but lighter
                        // so the data beside it can breathe.
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: kTextPrimaryColor,
                          fontWeight: FontWeight.w500,
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
                // End-side status zone — data-first, one glance:
                //   * debtor   → the bare outstanding amount in a red
                //     halo pill;
                //   * creditor → the bare credit amount in a green halo
                //     pill;
                //   * settled  → the quiet green «تسویه» pill (there is
                //     no number worth showing).
                // All three share the app-wide 12%-tint halo so every
                // state reads as one family; numbers stay bold-but-small
                // so they scan without shouting. A FittedBox keeps long
                // amounts on one line.
                if (_showBalance)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        formatPersianMoney(customer.balance!),
                        maxLines: 1,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      customer.status.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                // Trailing chevron — the RTL end-side affordance used by
                // the date tiles and quick-action rows; together with the
                // soft brand ripple it signals tappability.
                const Icon(Icons.chevron_left, size: 20, color: kGrey3Color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular avatar holding the app's person glyph (آدمک) — the same
/// profile placeholder the customer list card uses. Tint it with any
/// accent colour; the glyph softens to 70% so the tint stays
/// informational.
class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({super.key, required this.color, this.radius = 22});

  final Color color;

  /// Avatar radius. The glyph scales proportionally (24dp at the
  /// default 22dp radius).
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.12),
      child: _PersonOutlineIcon(
        size: radius * 24 / 22,
        // Icon colour softened a touch so the status tint stays
        // informational instead of shouting next to the card text.
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}

/// Accent colour for one status: debt is red, credit is green (the
/// user-facing convention for this card — the whole creditor section
/// reads green), settled is green too but word-only — the same mapping
/// the account summary uses for debtor/settled.
Color _statusColor(CustomerCardStatus status, ColorScheme scheme) =>
    switch (status) {
      CustomerCardStatus.debtor => scheme.error,
      CustomerCardStatus.creditor => kSuccessColor,
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
