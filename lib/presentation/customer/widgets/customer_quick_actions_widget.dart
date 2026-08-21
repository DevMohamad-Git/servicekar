import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';

/// Quick-action row from the reference mockup: four tappable tiles —
/// صدور فاکتور، ثبت سرویس، ثبت پرداخت، تماس — laid out right-to-left.
///
/// Every tile is a softly elevated card: a gentle grey-to-white gradient
/// with a hairline border and a soft shadow, so the row stands apart from
/// the pure white page background. Hovering with a pointer or pressing a
/// tile washes it in a light primary tint. Handlers are injected by the
/// page so the row stays navigation-agnostic.
class CustomerQuickActionsWidget extends StatelessWidget {
  const CustomerQuickActionsWidget({
    super.key,
    required this.onIssueInvoice,
    required this.onRegisterService,
    required this.onRegisterPayment,
    required this.onCall,
  });

  final VoidCallback onIssueInvoice;
  final VoidCallback onRegisterService;
  final VoidCallback onRegisterPayment;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // RTL order: the first child is the rightmost tile.
        Expanded(
          child: _QuickActionTile(
            icon: Icons.fact_check_outlined,
            label: 'صدور فاکتور',
            onTap: onIssueInvoice,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.build_rounded,
            label: 'ثبت سرویس',
            onTap: onRegisterService,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.credit_card_rounded,
            label: 'ثبت پرداخت',
            onTap: onRegisterPayment,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.phone_rounded,
            label: 'تماس',
            onTap: onCall,
          ),
        ),
      ],
    );
  }
}

/// One rounded quick-action tile: an accent icon over its label on a soft
/// grey-to-white gradient surface with a hairline border and a gentle
/// shadow. Pointer hover and press both tint the tile with a light primary
/// wash so every action gives the same feedback.
class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.primary;
    final tint = accent.withValues(alpha: 0.10);

    return Container(
      decoration: BoxDecoration(
        // Very soft grey-to-white gradient lifts the tiles off the pure
        // white page background so the row reads as distinct cards.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F3F6), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        // Hairline border defines the tile edges on the white page.
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: tint,
          highlightColor: tint,
          splashColor: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: accent),
                const SizedBox(height: 6),
                // FittedBox keeps long labels («صدور فاکتور») on one line
                // inside the narrow quarter-width tile.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: kTextPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
