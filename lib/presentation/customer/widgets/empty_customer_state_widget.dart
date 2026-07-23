import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';

/// Placeholder empty-state shown when the customer list returns zero
/// records or no search match. Includes an optional CTA hook so the
/// list page can wire "Create new customer" without duplicating UI.
class EmptyCustomerStateWidget extends StatelessWidget {
  const EmptyCustomerStateWidget({
    super.key,
    this.onCreatePressed,
  });

  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              context.l10n.emptyCustomersTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.emptyCustomersBody,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onCreatePressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onCreatePressed,
                child: Text(context.l10n.addCustomer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
