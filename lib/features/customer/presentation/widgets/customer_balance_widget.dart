import 'package:flutter/material.dart';

/// Single-purpose widget that renders a customer's outstanding balance
/// in the standard "chip" look used across detail/list/dashboard.
class CustomerBalanceWidget extends StatelessWidget {
  const CustomerBalanceWidget({
    super.key,
    required this.balance,
    this.currency = 'IRR', // TODO: derive from Locale in real UI.
  });

  final double balance;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = balance > 0
        ? theme.colorScheme.error
        : balance < 0
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        // TODO: AppLocalizations.of(context).customersBalanceLabel
        '$balance $currency',
        style: theme.textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}
