import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';

/// Gradient "مجموع بدهکاران" summary card from the dashboard design.
///
/// Presentation-only: it receives an already-derived `amount` (the sum of
/// all debtor balances) and renders the gradient, decorative wallet/bars
/// artwork, and the "view debtors" affordance. Loading and error states are
/// rendered explicitly so a fake `0` is never shown as a real figure.
class TotalDebtorsCard extends StatelessWidget {
  const TotalDebtorsCard({
    super.key,
    required this.amount,
    required this.isLoading,
    required this.hasError,
    required this.onViewDebtors,
  });

  /// Sum of all debtor balances; `null` while loading or after an error.
  final double? amount;

  final bool isLoading;
  final bool hasError;

  /// Currently routed to a "coming soon" toast (the debtors screen is not
  /// built yet).
  final VoidCallback onViewDebtors;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kDebtorsGradientStart, kDebtorsGradientEnd],
        ),
      ),
      child: Stack(
        children: [
          // Decorative artwork — non-interactive.
          Positioned(
            top: -32,
            left: -24,
            child: IgnorePointer(
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 140,
                color: kDebtorsCardDecorationTint,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IgnorePointer(
              child: const _AscendingBars(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.totalDebtors,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  _amountLabel(context),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.toman,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 20),
                Center(child: _ViewDebtorsButton(onTap: onViewDebtors)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _amountLabel(BuildContext context) {
    // Never show a fake zero: error → localized error, loading → dash,
    // otherwise the derived figure.
    if (hasError) return context.l10n.error;
    final value = amount;
    if (value == null || isLoading) return '—';
    return formatPersianMoney(value);
  }
}

class _ViewDebtorsButton extends StatelessWidget {
  const _ViewDebtorsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.viewDebtors,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: kDebtorsGradientStart,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_left,
                size: 18,
                color: kDebtorsGradientStart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative ascending chart bars shown in the card's bottom-right corner.
class _AscendingBars extends StatelessWidget {
  const _AscendingBars();

  @override
  Widget build(BuildContext context) {
    const heights = <double>[16, 28, 40];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final height in heights)
          Container(
            width: 10,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: kDebtorsCardDecorationTint,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
