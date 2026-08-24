import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../logic/service_entry_state.dart';

/// Bottom-pinned submit button bar for the service-entry page.
///
/// Spans the full width of the page with the same button geometry as
/// the `_SubmitActionBar` in `CreateCustomerPage`: 52 dp height and the
/// global FilledButton theme radius (12 dp), so every primary form CTA
/// in the app looks identical. Text uses `labelLarge.w600`.
class ServiceEntrySubmitBar extends StatelessWidget {
  const ServiceEntrySubmitBar({
    super.key,
    required this.canSubmit,
    required this.isSubmitting,
    required this.submitState,
    required this.onSubmit,
    required this.onRetry,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final ServiceEntrySubmitState submitState;
  final VoidCallback onSubmit;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bool showRetry = submitState == ServiceEntrySubmitState.error;
    final bool showSuccess = submitState == ServiceEntrySubmitState.success;
    final bool disabled = isSubmitting || (!canSubmit && !showRetry);

    Color bgColor = scheme.primary;
    Color fgColor = scheme.onPrimary;
    Widget child = Text(l10n.registerService);

    if (showSuccess) {
      bgColor = kSuccessColor;
      fgColor = Colors.white;
      child = const Icon(Icons.check_rounded, size: 30);
    } else if (showRetry) {
      bgColor = kErrorColor;
      fgColor = Colors.white;
      child = Text(l10n.retry);
    } else if (isSubmitting) {
      child = SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    return Container(
      // Same bar padding as `_SubmitActionBar` in `CreateCustomerPage`:
      // a 16 dp horizontal inset so the button doesn't touch the edges.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: kGrey4Color.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (transitionChild, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: transitionChild,
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              key: ValueKey<ServiceEntrySubmitState>(submitState),
              onPressed: disabled ? null : (showRetry ? onRetry : onSubmit),
              style: FilledButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                disabledBackgroundColor: scheme.onSurface.withValues(
                  alpha: 0.12,
                ),
                disabledForegroundColor: scheme.onSurface.withValues(
                  alpha: 0.38,
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}