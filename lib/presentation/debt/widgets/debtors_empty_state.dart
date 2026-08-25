import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';

/// Friendly empty state for the debtors page — soft grey circle +
/// person-off glyph + the single reassuring message. Same recipe as
/// [EmptyCustomerStateWidget] minus the CTA (there is no action to
/// take when nobody owes money).
class DebtorsEmptyState extends StatelessWidget {
  const DebtorsEmptyState({super.key});

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
              child: Icon(
                Icons.person_off_outlined,
                size: 40,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.emptyDebtors,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
