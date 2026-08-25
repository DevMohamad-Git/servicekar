import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';

/// Understandable error state for the debtors page: error-tinted
/// circle, one plain-language line, and a retry action that re-runs
/// the (mock) load.
class DebtorsErrorState extends StatelessWidget {
  const DebtorsErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

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
                color: scheme.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: scheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.debtorsLoadError,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: kTextPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
