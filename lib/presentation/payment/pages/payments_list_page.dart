import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../config/l10n/arb/app_localizations.dart';
import '../../../config/l10n/l10n.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/constants/general_constants.dart';
import '../../../core/utils/jalali_date.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../features/customer/domain/entities/payment_entity.dart';
import '../../customer/widgets/customer_card_widget.dart';
import '../../customer/widgets/customer_page_header.dart';
import '../../service/logic/service_entry_state.dart';

/// UI-first payments list page.
///
/// Mirrors the customer-list page architecture: the body is backed by
/// mock payment rows so the page can be reviewed without a database,
/// and the corner "+" FAB opens the existing payment-entry form. The
/// filter pills really narrow the mock list by payment method.
@RoutePage()
class PaymentsListPage extends StatefulWidget {
  const PaymentsListPage({super.key});

  @override
  State<PaymentsListPage> createState() => _PaymentsListPageState();
}

class _PaymentsListPageState extends State<PaymentsListPage> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomerPageHeader(
        title: l10n.payments,
        subtitle: l10n.paymentsSubtitle,
        onBack: () => context.router.maybePop(),
      ),
      body: Container(
        width: double.infinity,
        color: kBackgroundColor,
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── (a) Count + total-received box ────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: _SummaryCard(
                  count: _filteredPayments.length,
                  total: _filteredTotal,
                ),
              ),
              const SizedBox(height: 12),

              // ─── (b) Filter container ──────────────────────────
              // An independent white card with its own radius, border
              // and shadow — visually separate from the list below.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kGrey4Color.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _PaymentFilterBar(
                    selectedIndex: _selectedFilterIndex,
                    onSelected: (index) =>
                        setState(() => _selectedFilterIndex = index),
                  ),
                ),
              ),

              // ─── (c) Payment cards ──────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey<int>(_selectedFilterIndex),
                    child: _buildList(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: GeneralConstants.kAddFabHeroTag,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        // Rounded-square add button, pinned to the end side (left in
        // RTL) like the reference design.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: context.l10n.registerPayment,
        onPressed: () => context.router.push(PaymentEntryRoute()),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Mock rows narrowed by the selected filter pill.
  List<MockPayment> get _filteredPayments => switch (_selectedFilterIndex) {
    1 => _mockPayments.where((p) => p.method == PaymentMethod.cash).toList(),
    2 => _mockPayments.where((p) => p.method == PaymentMethod.card).toList(),
    _ => _mockPayments,
  };

  double get _filteredTotal =>
      _filteredPayments.fold<double>(0, (sum, p) => sum + p.amount);

  Widget _buildList(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final filtered = _filteredPayments;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          l10n.emptyState,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Individual white payment cards on the neutral grey canvas —
    // the same treatment as the customer-list page, with soft gaps
    // between cards instead of a grouped container.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final payment = filtered[index];
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
          child: _PaymentRow(payment: payment),
        );
      },
    );
  }
}

/// Soft accent colors for the row avatars — the same dashboard KPI
/// palette the customer-selection section uses, so no new hue enters
/// the app.
const List<Color> _kAvatarAccents = [
  Color(0xFF2563EB),
  Color(0xFF00838F),
  Color(0xFF8B5CF6),
  Color(0xFFD97706),
  Color(0xFF16A34A),
  Color(0xFFDB2777),
];

/// (a) Two-pane summary card from the reference design: the received
/// total (wallet badge + green amount + toman) on the start side, the
/// in-month payment count on the end side, separated by a thin divider
/// — the same two-pane recipe as `CustomerAccountSummaryWidget`.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count, required this.total});

  final int count;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Received-total pane (start side — right in RTL) ──
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 24,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalReceived,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          formatPersianMoney(total),
                          maxLines: 1,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: kSuccessColor,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.3,
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
                ),
              ],
            ),
          ),
          // Thin vertical separator between the two panes.
          Container(
            width: 1,
            height: 52,
            color: kGrey3Color.withValues(alpha: 0.55),
          ),
          const SizedBox(width: 14),
          // ── In-month count pane (end side — left in RTL) ──
          // A slightly smaller, centered block: title above, the bare
          // count, then the month caption beneath.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.numberOfPayments,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPersianNumber(count),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.withinThisMonth,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Deterministic accent for a customer name, stable across rebuilds.
Color _accentFor(String name) =>
    _kAvatarAccents[name.trim().hashCode % _kAvatarAccents.length];

/// One presentation-only mock payment row.
class MockPayment {
  const MockPayment({
    required this.customer,
    required this.amount,
    required this.method,
    required this.paidAt,
  });

  final MockCustomer customer;

  /// Received amount in Toman (always positive).
  final double amount;
  final PaymentMethod method;
  final DateTime paidAt;
}

/// Mock received payments referencing the shared mock-customer list.
final List<MockPayment> _mockPayments = <MockPayment>[
  MockPayment(
    customer: mockCustomers[0],
    amount: 1500000,
    method: PaymentMethod.cash,
    paidAt: DateTime.now(),
  ),
  MockPayment(
    customer: mockCustomers[1],
    amount: 800000,
    method: PaymentMethod.card,
    paidAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  MockPayment(
    customer: mockCustomers[2],
    amount: 2400000,
    method: PaymentMethod.card,
    paidAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  MockPayment(
    customer: mockCustomers[5],
    amount: 500000,
    method: PaymentMethod.cash,
    paidAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
  MockPayment(
    customer: mockCustomers[4],
    amount: 1200000,
    method: PaymentMethod.cash,
    paidAt: DateTime.now().subtract(const Duration(days: 9)),
  ),
];

/// One tappable payment row inside the grouped list container —
/// navigates to the paying customer's profile page.
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final MockPayment payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    // Standalone white card on the grey canvas — the same recipe as
    // `CustomerCardWidget`: hairline border + soft shadow, brand-tinted
    // ripple, rounded 16 corners.
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
          onTap: () => context.router.push(
            CustomerDetailsRoute(customerId: payment.customer.id),
          ),
          borderRadius: BorderRadius.circular(16),
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                CustomerAvatar(
                  color: _accentFor(payment.customer.name),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        payment.customer.name,
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
                            _methodIcon(payment.method),
                            size: 14,
                            // Method glyph carries its semantic colour —
                            // green for cash, brand blue for card.
                            color: _methodColor(payment.method, scheme),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${_methodLabel(l10n, payment.method)}'
                              ' · ${toJalali(payment.paidAt).format()}',
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
                // Income halo pill — the green 12%-tint convention; the
                // received amount is the row's loudest datum.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kSuccessColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      formatPersianMoney(payment.amount),
                      maxLines: 1,
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: kSuccessColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_left, size: 20, color: kGrey3Color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _methodIcon(PaymentMethod method) => switch (method) {
    PaymentMethod.card => Icons.credit_card_rounded,
    _ => Icons.payments_rounded,
  };

  /// Method glyph colour — green for cash, brand blue for card, per the
  /// reference design's coloured meta icons.
  static Color _methodColor(PaymentMethod method, ColorScheme scheme) =>
      switch (method) {
        PaymentMethod.card => scheme.primary,
        _ => kSuccessColor,
      };

  static String _methodLabel(AppLocalizations l10n, PaymentMethod method) =>
      switch (method) {
        PaymentMethod.card => l10n.paymentMethodCard,
        PaymentMethod.cash => l10n.paymentMethodCash,
        _ => l10n.emptyState,
      };
}

/// Filter pills shown above the list — the same visual pattern as the
/// customer list's `_FilterPill`, narrowed to the two real mock methods.
class _PaymentFilterBar extends StatelessWidget {
  const _PaymentFilterBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static final List<_PaymentFilterOption> _filters = [
    _PaymentFilterOption(
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments_rounded,
      label: (l10n) => l10n.allPayments,
      colorOf: (scheme) => scheme.primary,
    ),
    _PaymentFilterOption(
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments_rounded,
      label: (l10n) => l10n.paymentMethodCash,
      colorOf: (_) => kSuccessColor,
    ),
    _PaymentFilterOption(
      icon: Icons.credit_card_outlined,
      selectedIcon: Icons.credit_card_rounded,
      label: (l10n) => l10n.paymentMethodCard,
      colorOf: (scheme) => scheme.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 0; i < _filters.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _FilterCard(
              icon: _filters[i].icon,
              selectedIcon: _filters[i].selectedIcon,
              label: _filters[i].label(context.l10n),
              color: _filters[i].colorOf(scheme),
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _PaymentFilterOption {
  const _PaymentFilterOption({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.colorOf,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) label;
  final Color Function(ColorScheme scheme) colorOf;
}

/// How long a pill takes to morph between idle and selected.
const Duration _kPillAnimationDuration = Duration(milliseconds: 200);

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: _kPillAnimationDuration,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? color : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 17,
                  color: selected ? Colors.white : color,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: _kPillAnimationDuration,
                    curve: Curves.easeOut,
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: selected ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    child: Text(label),
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
