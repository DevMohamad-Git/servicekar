import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';

/// Presentation status of a customer's account balance.
///
/// Mirrors the Balance feature's `BalanceStatus` semantics (debtor /
/// settled / creditor) as a pure presentation value — this widget never
/// derives or computes the balance itself.
enum CustomerAccountStatus { debtor, settled, creditor }

extension CustomerAccountStatusX on CustomerAccountStatus {
  String get label => switch (this) {
    CustomerAccountStatus.debtor => 'بدهکار',
    CustomerAccountStatus.creditor => 'بستانکار',
    CustomerAccountStatus.settled => 'تسویه',
  };
}

/// Two-pane account summary box from the reference mockup: the account
/// status on the start side (right in RTL) and the remaining balance with
/// its last-update caption on the end side (left in RTL), separated by a
/// thin vertical divider. The whole box sits on a soft grey fill so it
/// reads as a distinct sub-surface inside the profile card.
///
/// The rendered colour follows the same status mapping the customer list
/// cards use: debtor → error (red), creditor → neutral grey, settled →
/// success (green). The status is presented as a tinted pill with a small
/// semantic icon so it reads at a glance instead of as a bare word.
class CustomerAccountSummaryWidget extends StatelessWidget {
  const CustomerAccountSummaryWidget({
    super.key,
    required this.status,
    required this.amount,
    required this.lastUpdated,
    this.outerPadding = const EdgeInsets.fromLTRB(14, 0, 14, 14),
  });

  final CustomerAccountStatus status;

  /// Absolute outstanding amount in Toman (unsigned — the [status] carries
  /// the direction). Rendered with Persian digits via [formatPersianMoney].
  final double amount;

  /// Pre-formatted "last updated" caption, e.g. `'امروز، ۹:۱۵'`.
  final String lastUpdated;

  /// Inset between the grey box and its host surface. Defaults to the
  /// profile-card inset; hosts that already pad their content (e.g. a
  /// form card) pass a tighter inset so the summary fills its slot.
  final EdgeInsetsGeometry outerPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(status, scheme);

    return Padding(
      // Inset the grey box from the host surface's edges.
      padding: outerPadding,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          // kGrey4 blends toward white here so the grey reads lighter.
          color: kGrey4Color.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Status pane (start side — right in RTL).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('وضعیت حساب', style: _paneLabelStyle(theme)),
                  const SizedBox(height: 8),
                  // Soft tinted pill (the 12%-tint chip convention used by
                  // the dashboard): a semantic icon beside the status word.
                  // Sized one step up (titleSmall + 18dp icon) so the
                  // account state is legible at a glance on any host page.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status), size: 18, color: statusColor),
                        const SizedBox(width: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            status.label,
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Thin vertical separator between the two panes.
            Container(
              width: 1,
              height: 46,
              color: kGrey3Color.withValues(alpha: 0.55),
            ),
            // Small breathing room so the balance labels don't touch the
            // separator.
            const SizedBox(width: 12),
            // Balance pane (end side — left in RTL). Every line is
            // right-aligned (toward the separator) so the label, amount and
            // caption line up cleanly instead of zig-zagging.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مانده حساب', style: _paneLabelStyle(theme)),
                  const SizedBox(height: 6),
                  // FittedBox keeps the amount on one line on narrow
                  // screens instead of overflowing the pane.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text.rich(
                      TextSpan(
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: formatPersianMoney(amount)),
                          TextSpan(
                            text: ' تومان',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'آخرین بروزرسانی: $lastUpdated',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle? _paneLabelStyle(ThemeData theme) =>
      theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      );

  /// Small semantic glyph for each status: debt trends down, credit trends
  /// up, settled gets a check.
  static IconData _statusIcon(CustomerAccountStatus status) => switch (status) {
    CustomerAccountStatus.debtor => Icons.trending_down,
    CustomerAccountStatus.creditor => Icons.trending_up,
    CustomerAccountStatus.settled => Icons.check_circle,
  };

  static Color _statusColor(CustomerAccountStatus status, ColorScheme scheme) =>
      switch (status) {
        CustomerAccountStatus.debtor => scheme.error,
        CustomerAccountStatus.creditor => kGrey2Color,
        CustomerAccountStatus.settled => kSuccessColor,
      };
}
