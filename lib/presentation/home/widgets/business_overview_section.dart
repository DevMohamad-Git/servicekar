import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';

/// "نمای کلی کسب‌وکار" KPI section: three independent, real database
/// counts (registered invoices / customers / registered services).
///
/// Presentation-only: it receives the three `AsyncValue<int>` states from
/// the owning feature controllers (via [HomePage]) and renders them. No
/// provider is watched here, no database query lives in this file.
///
/// Visual language mirrors the existing dashboard: white cards with the
/// same 16-radius used by the recent-activities card, the tinted icon
/// chip from the activity tiles, and the section header pattern
/// (right-aligned title + accent bar).
///
/// Layout: a single row of three equal-width, equal-height cards (each
/// [Expanded], stretched via [IntrinsicHeight]) so the three KPI boxes
/// sit on one line and stay the same size regardless of label length.
///
/// States per card:
///   * loading  → the label stays visible, a small spinner fills the
///                number slot (no fake value).
///   * data     → the real count, formatted with Persian digits; `0`
///                renders as `۰`.
///   * error    → the localized "خطا" label in grey — never fake data.
class BusinessOverviewSection extends StatelessWidget {
  const BusinessOverviewSection({
    super.key,
    required this.invoices,
    required this.customers,
    required this.services,
  });

  final AsyncValue<int> invoices;
  final AsyncValue<int> customers;
  final AsyncValue<int> services;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: text at the start (right in RTL), accent bar to its left.
        Row(
          children: [
            Text(
              context.l10n.businessOverview,
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
                color: kKpiInvoice,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // One row of three equal-width, equal-height KPI cards.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _KpiCard(
                  title: context.l10n.registeredInvoices,
                  icon: Icons.receipt_long_outlined,
                  accent: kKpiInvoice,
                  accentBackground: kKpiInvoiceBackground,
                  value: invoices,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  title: context.l10n.registeredCustomers,
                  icon: Icons.people_outline_rounded,
                  accent: kKpiCustomer,
                  accentBackground: kKpiCustomerBackground,
                  value: customers,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  title: context.l10n.registeredServices,
                  icon: Icons.build_outlined,
                  accent: kKpiService,
                  accentBackground: kKpiServiceBackground,
                  value: services,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single white KPI card: tinted icon chip on top, label, then the
/// count slot (value / spinner / error). Compact padding fits three
/// cards side by side on a narrow Android screen without overflow.
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.accentBackground,
    required this.value,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Color accentBackground;
  final AsyncValue<int> value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 10),
          // Persian labels are wide; allow wrapping (up to two lines)
          // so the cards never overflow on narrow Android screens.
          Text(
            title,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kGrey3Color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          _CountSlot(value: value, accent: accent),
        ],
      ),
    );
  }
}

/// The number slot of a KPI card. Renders exactly one of: the real
/// count (Persian digits), a lightweight loading spinner, or the
/// localized error label — never a placeholder like `---` or a fake
/// figure.
class _CountSlot extends StatelessWidget {
  const _CountSlot({required this.value, required this.accent});

  final AsyncValue<int> value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (count) => FittedBox(
        // Scale large counts down instead of overflowing the card.
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          formatPersianNumber(count),
          // `titleLarge` (24) instead of `headlineSmall` (28) so large
          // counts stay proportional inside the narrow 3-across card;
          // the FittedBox above still scales down if the value grows
          // huge, so it never overflows.
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: kTextPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      loading: () => SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: accent),
      ),
      error: (_, _) => Text(
        context.l10n.error,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: kGrey3Color,
            ),
      ),
    );
  }
}
