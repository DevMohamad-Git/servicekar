import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../logic/service_entry_state.dart';

/// Bottom-pinned submit button bar for the service-entry page.
///
/// Stays above the keyboard and within one-hand reach. The button is the
/// largest control on the page — 66dp tall with a 20dp radius, one step
/// above the 16dp form cards, so the primary action visibly outranks
/// every other element. Visual state follows [submitState] and
/// cross-fades between states with a subtle scale:
///   * `idle` — enabled or disabled [FilledButton] reading "ثبت سرویس";
///   * `submitting` — disabled button with a [CircularProgressIndicator];
///   * `success` — green filled button with a checkmark for a brief
///     moment before the page resets;
///   * `error` — red filled button with "تلاش دوباره" that simulates a
///     failure next submission.
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
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: kGrey4Color.withValues(alpha: 0.6)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 66,
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
            child: FilledButton(
              // Keyed by state so AnimatedSwitcher swaps the whole button
              // look (colour + content) as one cross-fading unit.
              key: ValueKey<ServiceEntrySubmitState>(submitState),
              onPressed: disabled ? null : (showRetry ? onRetry : onSubmit),
              style: FilledButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                disabledBackgroundColor: scheme.onSurface.withValues(
                  alpha: 0.12,
                ),
                disabledForegroundColor: scheme.onSurface.withValues(
                  alpha: 0.38,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
