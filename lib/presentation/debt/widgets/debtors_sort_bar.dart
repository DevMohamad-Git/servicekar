import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../logic/debtors_list_controller.dart';

/// Sort control for the debtors list — a Material 3
/// [SegmentedButton] with the two product-mandated options
/// («بیشترین بدهی» / «کمترین بدهی»).
///
/// Restyled with the app's pill recipe (brand primary fill when
/// selected, 5% tint + hairline border when idle, 12 radius) so it
/// reads as the same family as the payments-list filter pills.
class DebtorsSortBar extends StatelessWidget {
  const DebtorsSortBar({
    super.key,
    required this.order,
    required this.onChanged,
  });

  final DebtorsSortOrder order;
  final ValueChanged<DebtorsSortOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<DebtorsSortOrder>(
        selected: {order},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: scheme.primary.withValues(alpha: 0.04),
          foregroundColor: scheme.primary,
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: Colors.white,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.25)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        segments: [
          ButtonSegment(
            value: DebtorsSortOrder.highestDebt,
            icon: const Icon(Icons.south_rounded, size: 16),
            label: Text(l10n.sortByHighestDebt),
          ),
          ButtonSegment(
            value: DebtorsSortOrder.lowestDebt,
            icon: const Icon(Icons.north_rounded, size: 16),
            label: Text(l10n.sortByLowestDebt),
          ),
        ],
      ),
    );
  }
}
