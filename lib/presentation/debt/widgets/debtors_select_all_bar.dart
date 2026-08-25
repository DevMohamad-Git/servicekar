import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';

/// «انتخاب همه» strip shown above the list in multi-select mode:
/// master checkbox + toggle label on the start, a live count pill
/// (brand-tinted, Persian digits) on the end. Hidden entirely while no
/// row is picked so the bar stays quiet until it has something to say.
class DebtorsSelectAllBar extends StatelessWidget {
  const DebtorsSelectAllBar({
    super.key,
    required this.allSelected,
    required this.selectedCount,
    required this.onToggleAll,
  });

  final bool allSelected;
  final int selectedCount;

  final VoidCallback? onToggleAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Checkbox(value: allSelected, onChanged: (_) => onToggleAll?.call()),
          Expanded(
            child: InkWell(
              onTap: onToggleAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  allSelected ? l10n.deselectAll : l10n.selectAll,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (selectedCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.selectedCount(formatPersianNumber(selectedCount)),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
