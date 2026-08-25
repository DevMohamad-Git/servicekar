import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/jalali_date.dart';
import '../../../core/utils/money_formatter.dart';
import '../../customer/widgets/customer_card_widget.dart';
import '../models/mock_debtors.dart';

/// One debtor card on the debtors list.
///
/// Layout mirrors [CustomerCardWidget]'s recipe (white surface,
/// hairline border + soft shadow on the grey canvas): profile side
/// (avatar + name + phone + last-service meta) on the start, the
/// outstanding amount as the card's loudest datum in the semantic
/// error colour on the end. Below sits the per-customer
/// «ارسال پیامک یادآوری» action.
///
/// In multi-select mode the action button is replaced by a leading
/// checkbox and the whole card becomes a selection toggle.
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.5)),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (selectionMode) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggleSelected(),
                      ),
                      const SizedBox(width: 4),
                    ],
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
                              Icon(
                                Icons.call,
                                size: 14,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _formatPhoneNumber(debtor.phoneNumber),
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
                    // End-side amount zone — the debt is the loudest datum:
                    // big bold figure in the semantic error colour with a
                    // quiet toman caption beneath. FittedBox keeps long
                    // amounts on one line.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            formatPersianMoney(debtor.debtAmount),
                            maxLines: 1,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.error,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.toman,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Per-customer reminder action — hidden while selecting.
                if (!selectionMode) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onSendReminder,
                      icon: const Icon(Icons.sms_outlined, size: 18),
                      label: Text(l10n.sendReminderSms),
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

  /// Groups an 11-digit mobile number for readability: "09121234567" →
  /// "0912 123 4567". Same convention as the customer-list card.
  String _formatPhoneNumber(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 4)} ${phone.substring(4, 7)} '
        '${phone.substring(7)}';
  }
}
