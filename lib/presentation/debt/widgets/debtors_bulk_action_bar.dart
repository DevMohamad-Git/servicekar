import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';

/// Pinned bottom action of the debtors page.
///
///   * Normal mode  → one full-width primary CTA
///     «ارسال پیامک یادآوری برای چند مشتری» that enters multi-select.
///   * Select mode  → «انصراف» plus the group-send CTA, labelled with
///     the live selection count and disabled while nothing is picked.
///
/// The group send itself is intentionally a UI-only stub for this
/// phase — the page decides what pressing it does (a toast); this bar
/// only renders the affordance.
class DebtorsBulkActionBar extends StatelessWidget {
  const DebtorsBulkActionBar({
    super.key,
    required this.selectionMode,
    required this.selectedCount,
    required this.formattedCount,
    required this.onEnterSelection,
    required this.onExitSelection,
    required this.onSendBulk,
  });

  final bool selectionMode;

  /// Raw number of selected rows (drives the enabled state).
  final int selectedCount;

  /// Pre-formatted Persian count for the button label.
  final String formattedCount;

  final VoidCallback onEnterSelection;
  final VoidCallback onExitSelection;
  final VoidCallback onSendBulk;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: kGrey4Color.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: selectionMode
                ? _SelectionActions(
                    key: const ValueKey<bool>(true),
                    selectedCount: selectedCount,
                    formattedCount: formattedCount,
                    onExit: onExitSelection,
                    onSend: onSendBulk,
                  )
                : FilledButton.icon(
                    key: const ValueKey<bool>(false),
                    onPressed: onEnterSelection,
                    icon: const Icon(Icons.forward_to_inbox_outlined),
                    label: Text(l10n.bulkReminderEntry),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SelectionActions extends StatelessWidget {
  const _SelectionActions({
    super.key,
    required this.selectedCount,
    required this.formattedCount,
    required this.onExit,
    required this.onSend,
  });

  final int selectedCount;
  final String formattedCount;
  final VoidCallback onExit;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        // Quiet exit affordance — grey text instead of a boxed dark
        // outline so it never competes with the group-send CTA.
        TextButton(
          onPressed: onExit,
          style: TextButton.styleFrom(foregroundColor: kGrey2Color),
          child: Text(l10n.cancel),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            // Logical gating: no selection → nothing to send.
            onPressed: selectedCount > 0 ? onSend : null,
            icon: const Icon(Icons.sms_outlined, size: 18),
            label: Text(l10n.sendBulkReminders(formattedCount)),
          ),
        ),
      ],
    );
  }
}
