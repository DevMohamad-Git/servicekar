import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';

/// Kind of a dashboard activity row. Drives the icon + accent colour.
///
/// These are *presentation* semantics only — they do NOT map to a domain
/// entity because no Activity/Ledger collection exists yet.
enum DashboardActivityType { paymentReceived, invoiceCreated, customerCreated }

/// Static mock row for the "آخرین فعالیت‌ها" list.
///
/// TODO: replace with real derived data once an Activity feature (or a
/// ledger) is designed — the dashboard UI is being validated first, and
/// building that infrastructure now would be premature.
class DashboardActivity {
  const DashboardActivity({
    required this.type,
    required this.title,
    required this.timestamp,
    this.amount,
  });

  final DashboardActivityType type;
  final String title;
  final String timestamp;

  /// `null` hides the amount line (used by the "new customer" row, which
  /// shows only a date).
  final double? amount;
}

/// The three approved mock rows (outflow/refund item intentionally omitted:
/// the payment domain only models money-in today).
const _mockActivities = <DashboardActivity>[
  DashboardActivity(
    type: DashboardActivityType.paymentReceived,
    title: 'دریافت پرداخت از شرکت آریا',
    timestamp: 'امروز، ۱۰:۳۰',
    amount: 5600000,
  ),
  DashboardActivity(
    type: DashboardActivityType.invoiceCreated,
    title: 'ثبت فاکتور برای شرکت پارس',
    timestamp: 'دیروز، ۱۵:۴۵',
    amount: 3200000,
  ),
  DashboardActivity(
    type: DashboardActivityType.customerCreated,
    title: 'ثبت مشتری جدید: شرکت توین',
    timestamp: '۱۴۰۳/۰۲/۲۵',
  ),
];

/// "آخرین فعالیت‌ها" section: right-aligned header with a blue accent bar,
/// the mock activity rows laid directly on the page background (no
/// enclosing card), and a "view all" footer — so the floating bottom dock
/// below stays visually prominent.
class RecentActivitiesSection extends StatelessWidget {
  const RecentActivitiesSection({super.key, required this.onViewAll});

  /// Currently routed to a "coming soon" toast.
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: text at the start (right), blue accent bar to its left.
        Row(
          children: [
            Text(
              context.l10n.recentActivities,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: kActivityInvoice,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Activity rows render directly on the background — no enclosing
        // white card, so the floating dock below is clearly visible.
        for (var i = 0; i < _mockActivities.length; i++) ...[
          _ActivityTile(activity: _mockActivities[i]),
          if (i < _mockActivities.length - 1)
            const Divider(height: 1, indent: 56),
        ],
        const SizedBox(height: 4),
        InkWell(
          onTap: onViewAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.viewAllActivities,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: kActivityInvoice,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: kActivityInvoice,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final DashboardActivity activity;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(activity.type);
    final background = _backgroundFor(activity.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Icon chip — start (right) in RTL.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(activity.type), color: accent, size: 24),
          ),
          const SizedBox(width: 12),
          // Title + subtitle.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: kTextPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.byYou,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kGrey3Color,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount + timestamp — trailing (left) side in RTL.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity.amount != null)
                _AmountLine(
                  amount: activity.amount!,
                  color: accent,
                  showPlus:
                      activity.type == DashboardActivityType.paymentReceived,
                )
              else
                const SizedBox.shrink(),
              const SizedBox(height: 2),
              Text(
                activity.timestamp,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kGrey3Color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(DashboardActivityType type) => switch (type) {
        DashboardActivityType.paymentReceived => Icons.arrow_downward,
        DashboardActivityType.invoiceCreated => Icons.description_outlined,
        DashboardActivityType.customerCreated =>
          Icons.person_add_alt_1_outlined,
      };

  static Color _accentFor(DashboardActivityType type) => switch (type) {
        DashboardActivityType.paymentReceived => kActivityIncome,
        DashboardActivityType.invoiceCreated => kActivityInvoice,
        DashboardActivityType.customerCreated => kActivityCustomer,
      };

  static Color _backgroundFor(DashboardActivityType type) => switch (type) {
        DashboardActivityType.paymentReceived => kActivityIncomeBackground,
        DashboardActivityType.invoiceCreated => kActivityInvoiceBackground,
        DashboardActivityType.customerCreated => kActivityCustomerBackground,
      };
}

/// Single-line amount rendered as one RTL run so the Persian digits and the
/// "تومان" unit keep their natural order (number → sign → unit).
class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.amount,
    required this.color,
    required this.showPlus,
  });

  final double amount;
  final Color color;
  final bool showPlus;

  @override
  Widget build(BuildContext context) {
    final number = formatPersianMoney(amount);
    final text = showPlus
        ? '$number + ${context.l10n.toman}'
        : '$number ${context.l10n.toman}';
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
