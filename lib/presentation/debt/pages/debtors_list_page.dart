import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../injection/global_providers.dart';
import '../../customer/widgets/customer_page_header.dart';
import '../logic/debtors_list_controller.dart';
import '../models/mock_debtors.dart';
import '../widgets/debtor_card_widget.dart';
import '../widgets/debtors_bulk_action_bar.dart';
import '../widgets/debtors_empty_state.dart';
import '../widgets/debtors_error_state.dart';
import '../widgets/debtors_select_all_bar.dart';
import '../widgets/debtors_sort_bar.dart';

/// UI-first debtors list («بدهکاران»), opened from the dashboard's
/// «مشاهده‌ی بدهکاران» card.
///
/// Everything on this page runs on mock data via
/// [debtorsListControllerProvider] — no Isar, repository, use case or
/// SMS gateway is touched in this phase:
///   * sorting (بیشترین/کمترین بدهی) lives in the controller state;
///   * each card carries its own «ارسال پیامک یادآوری» action
///     (feedback through the shared toast);
///   * multi-select mode supports per-row selection, select-all, a live
///     count and a logically-gated group-send stub that only shows a
///     toast;
///   * loading / data / empty / error phases all have dedicated views.
@RoutePage()
class DebtorsListPage extends ConsumerStatefulWidget {
  const DebtorsListPage({super.key});

  @override
  ConsumerState<DebtorsListPage> createState() => _DebtorsListPageState();
}

class _DebtorsListPageState extends ConsumerState<DebtorsListPage> {
  /// Single-reminder feedback — UI-only; no real SMS is sent in this
  /// phase and no SMS abstraction exists yet to call into.
  void _sendSingleReminder(MockDebtor debtor) {
    ref
        .read(appHelperProvider)
        .displayToast(
          context,
          message: context.l10n.reminderSmsQueued(debtor.fullName),
        );
  }

  /// Group send is intentionally not implemented — exact mandated copy.
  void _showBulkUnavailableToast() {
    ref
        .read(appHelperProvider)
        .displayToast(context, message: context.l10n.bulkSmsUnavailable);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(debtorsListControllerProvider);
    final controller = ref.read(debtorsListControllerProvider.notifier);

    return PopScope(
      // In selection mode, system/gesture back exits selection first.
      canPop: !state.selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && state.selectionMode) controller.exitSelectionMode();
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: CustomerPageHeader(
          title: l10n.debtorsTitle,
          subtitle: l10n.debtorsSubtitle,
          // The intro sentence is long; the header measures the
          // wrapped height itself and grows the toolbar to fit.
          subtitleMaxLines: 3,
          onBack: () => context.router.maybePop(),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.hasData) ...[
                // Glanceable context line («۶ بدهکار · مجموع بدهی …») —
                // quiet metadata that answers «چقدر طلب دارم؟» in one
                // fixation. Hidden in selection mode where the
                // select-all strip owns this slot.
                if (!state.selectionMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _DebtorsSummaryLine(debtors: state.debtors),
                  ),
                const SizedBox(height: 10),
                // Sort control swaps for the select-all strip while
                // multi-select mode is active.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: state.selectionMode
                        ? _CardContainer(
                            key: const ValueKey<bool>(true),
                            child: DebtorsSelectAllBar(
                              allSelected: state.allSelected,
                              selectedCount: state.selectedIds.length,
                              onToggleAll: controller.toggleSelectAll,
                            ),
                          )
                        : _CardContainer(
                            key: const ValueKey<bool>(false),
                            padding: const EdgeInsets.all(8),
                            child: DebtorsSortBar(
                              order: state.sortOrder,
                              onChanged: controller.setSortOrder,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(child: _buildPhaseView(theme, state)),
              if (state.hasData)
                DebtorsBulkActionBar(
                  selectionMode: state.selectionMode,
                  selectedCount: state.selectedIds.length,
                  formattedCount: formatPersianNumber(state.selectedIds.length),
                  onEnterSelection: controller.enterSelectionMode,
                  onExitSelection: controller.exitSelectionMode,
                  onSendBulk: _showBulkUnavailableToast,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phase switch: loading / data / empty / error.
  Widget _buildPhaseView(ThemeData theme, DebtorsListViewState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (state.phase) {
        DebtorsListPhase.loading => Center(
          key: const ValueKey<DebtorsListPhase>(DebtorsListPhase.loading),
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        DebtorsListPhase.empty => const Center(
          key: ValueKey<DebtorsListPhase>(DebtorsListPhase.empty),
          child: DebtorsEmptyState(),
        ),
        DebtorsListPhase.error => Center(
          key: const ValueKey<DebtorsListPhase>(DebtorsListPhase.error),
          child: DebtorsErrorState(
            onRetry: () =>
                ref.read(debtorsListControllerProvider.notifier).retry(),
          ),
        ),
        DebtorsListPhase.data => _buildListView(state),
      },
    );
  }

  Widget _buildListView(DebtorsListViewState state) {
    final rows = state.sortedDebtors;

    return KeyedSubtree(
      key: const ValueKey<DebtorsListPhase>(DebtorsListPhase.data),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final debtor = rows[index];
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
            child: DebtorCardWidget(
              debtor: debtor,
              selectionMode: state.selectionMode,
              isSelected: state.selectedIds.contains(debtor.id),
              onSendReminder: () => _sendSingleReminder(debtor),
              onToggleSelected: () => ref
                  .read(debtorsListControllerProvider.notifier)
                  .toggleSelected(debtor.id),
            ),
          );
        },
      ),
    );
  }
}

/// One-line summary above the list: debtor count plus the total
/// outstanding, both in Persian digits. Presentation-only — it sums
/// the rows the page already holds; no balance use case is involved.
///
/// Styled like the customer-list count label (muted, semibold) so the
/// line reads as quiet context rather than a competing datum.
class _DebtorsSummaryLine extends StatelessWidget {
  const _DebtorsSummaryLine({required this.debtors});

  final List<MockDebtor> debtors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = debtors.fold<double>(0, (sum, d) => sum + d.debtAmount);

    return Text(
      context.l10n.debtorsSummaryLine(
        formatPersianNumber(debtors.length),
        formatPersianMoney(total),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: theme.textTheme.labelLarge?.copyWith(
        color: kGrey2Color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// White card wrapper matching the payments-list filter container
/// recipe (hairline border + soft shadow on the grey canvas).
class _CardContainer extends StatelessWidget {
  const _CardContainer({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
