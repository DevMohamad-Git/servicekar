import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/jalali_date.dart';
import '../../../core/utils/money_formatter.dart';
import '../../customer/widgets/customer_card_widget.dart';
import '../models/mock_debtors.dart';

/// One debtor card on the debtors list («لیست سرخ بدهکاران»).
///
/// Visual recipe mirrors [CustomerCardWidget]: white surface, hairline
/// border + soft shadow on the grey canvas, brand-tinted ripple.
///
/// Hierarchy inside the card:
///   * identity zone (start)   — avatar, name, phone, last-service meta;
///   * data zone (end)         — the outstanding amount, the card's
///     loudest datum, in the semantic error colour with an inline
///     quiet «تومان» unit;
///   * action zone (footer)    — a compact brand-tinted pill
///     «ارسال پیامک یادآوری», deliberately NOT a boxed button so the
///     per-row reminder stays discoverable without reading as a heavy
///     financial CTA (the same tint-pill family as the app's status /
///     count chips).
///
/// In multi-select mode the footer action is hidden, a leading
/// checkbox appears, the whole card becomes a selection toggle, and
/// the picked state is echoed by a primary-tinted border + wash.
class DebtorCardWidget extends StatelessWidget {
  const DebtorCardWidget({
    super.key,
    required this.debtor,
    required this.selectionMode,
    required this.isSelected,
    required this.onSendReminder,
    required this.onToggleSelected,
  });

  final MockDebtor debtor;

  final bool selectionMode;
  final bool isSelected;

  final VoidCallback onSendReminder;
  final VoidCallback onToggleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // Picked rows swap the hairline for a primary edge plus a faint
        // brand wash — visible from a list-scanning distance, not just
        // at the checkbox.
        color: isSelected ? scheme.primary.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.55)
              : kGrey4Color.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Only multi-select mode makes the card body itself tappable.
          onTap: selectionMode ? onToggleSelected : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              children: [
                _InfoRow(
                  debtor: debtor,
                  selectionMode: selectionMode,
                  isSelected: isSelected,
                  onToggleSelected: onToggleSelected,
                ),
                // Per-customer reminder action — hidden while selecting
                // so checkboxes become the single interaction.
                if (!selectionMode) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: kGrey4Color.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _ReminderPill(
                      label: l10n.sendReminderSms,
                      onPressed: onSendReminder,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Top zone of the card: the selection-aware avatar, the identity
/// column (name / phone / last-service meta) and the end-side amount
/// block.
///
/// Selection deliberately reuses the avatar slot instead of inserting
/// a leading checkbox: on narrow phones a 24dp+ checkbox steals just
/// enough width from the identity column to squeeze (and eventually
/// overflow) the phone/date meta lines. Morphing the avatar into a
/// ring/check indicator keeps row geometry identical in both modes.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.debtor,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggleSelected,
  });

  final MockDebtor debtor;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (selectionMode)
          _SelectableAvatar(isSelected: isSelected)
        else
          CustomerAvatar(color: scheme.error),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                debtor.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: kTextPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      formatGroupedPhoneNumber(debtor.phoneNumber),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${l10n.lastServiceDateLabel}: '
                      '${toJalali(debtor.lastServiceDate).format()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _AmountBlock(amount: debtor.debtAmount),
      ],
    );
  }
}

/// Selection indicator riding the avatar slot. Unselected rows show
/// the regular debtor avatar wrapped in a quiet grey ring («این ردیف
/// قابل انتخاب است»); picked rows morph into a solid primary disc with
/// a white check — the same visual language as a Material checkbox,
/// scaled to the avatar.
class _SelectableAvatar extends StatelessWidget {
  const _SelectableAvatar({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? scheme.primary : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? scheme.primary
              : kGrey3Color.withValues(alpha: 0.55),
          width: 1.6,
        ),
      ),
      alignment: AlignmentDirectional.center,
      child: isSelected
          ? Icon(Icons.check_rounded, size: 26, color: Colors.white)
          : Padding(
              padding: const EdgeInsets.all(2),
              child: CustomerAvatar(color: scheme.error, radius: 19),
            ),
    );
  }
}

/// End-side data zone. The figure is the card's loudest datum — bold,
/// error-red — with a quiet «تومان» caption one step beneath. Kept as a
/// compact vertical stack (not an inline unit run) so the block stays
/// narrow enough to coexist with the identity column on small phones;
/// a FittedBox still guards against extreme amounts.
class _AmountBlock extends StatelessWidget {
  const _AmountBlock({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            formatPersianMoney(amount),
            maxLines: 1,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.l10n.toman,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Compact footer reminder action: sms glyph + label on the app's
/// 12%-tint pill recipe (the same family as the status / count chips).
///
/// Why a tinted pill instead of a boxed button: the reminder must be
/// easy to find on every row without each card shouting a full-width
/// dark CTA that reads like a money transaction. Brand-blue tint says
/// «communication utility», stays quiet next to the red amount, and
/// keeps the card compact.
class _ReminderPill extends StatelessWidget {
  const _ReminderPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        splashColor: scheme.primary.withValues(alpha: 0.15),
        highlightColor: scheme.primary.withValues(alpha: 0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sms_outlined, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Groups an 11-digit mobile number for readability: "09121234567" →
/// "0912 123 4567". Same convention as the customer-list card.
String formatGroupedPhoneNumber(String phone) {
  if (phone.length != 11) return phone;
  return '${phone.substring(0, 4)} ${phone.substring(4, 7)} '
      '${phone.substring(7)}';
}
