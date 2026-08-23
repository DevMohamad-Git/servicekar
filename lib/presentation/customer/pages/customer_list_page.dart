import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/constants/general_constants.dart';
import '../../../core/utils/money_formatter.dart';
import '../widgets/customer_card_widget.dart';
import '../widgets/customer_list_state_widgets.dart';
import '../widgets/customer_page_header.dart';
import '../widgets/customer_search_bar_widget.dart';
import '../widgets/empty_customer_state_widget.dart';

/// Temporary page title kept in one place so it can be changed later.
const String customerListPageTitle = 'مشتریان';
const String customerListPageSubtitle = 'مدیریت حساب‌ها';

/// Presentation states used to preview every customer-list UI state.
enum CustomerListDisplayState { data, empty, loading, error }

/// UI-first customer list page.
///
/// The default view is backed by mock data so the page can be reviewed
/// without a database, repository, or use case. The visible body follows the
/// selected filter pill; [displayState] can force one state for previewing.
@RoutePage()
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key, this.displayState});

  /// Optional forced state used to preview a single UI state. When null, the
  /// visible state is driven by the selected filter pill.
  final CustomerListDisplayState? displayState;

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  int _selectedFilterIndex = 0;

  /// The corner "+" FAB belongs to the "همه" list only; the other filters
  /// have their own states, so the FAB is hidden for them.
  bool get _shouldShowFab {
    final forced = widget.displayState;
    if (forced != null) return forced == CustomerListDisplayState.data;
    return _selectedFilterIndex == 0;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomerPageHeader(
        title: customerListPageTitle,
        subtitle: customerListPageSubtitle,
        titleIcon: Icons.groups_rounded,
        onBack: () => context.router.maybePop(),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const CustomerSearchBarWidget(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _CustomerFilterBar(
                selectedIndex: _selectedFilterIndex,
                onSelected: (index) =>
                    setState(() => _selectedFilterIndex = index),
              ),
            ),
            // The body (list / loading / empty / error states) sits on the
            // app's neutral grey surface so the white customer cards read
            // as distinct elevated surfaces — tonal contrast defines where
            // each card starts and ends, instead of relying on faint
            // shadows on a white page.
            Expanded(
              child: ColoredBox(
                color: kBackgroundColor,
                child: _buildState(context),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _shouldShowFab
          ? FloatingActionButton(
              heroTag: GeneralConstants.kAddFabHeroTag,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              tooltip: context.l10n.registerCustomer,
              onPressed: () => _openCreateCustomer(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildState(BuildContext context) {
    final forced = widget.displayState;
    if (forced != null) {
      return _buildDisplayState(context, forced);
    }

    // Only "همه" shows the customer list; debtors show the error state,
    // invoices show the empty state, and not-yet-invoiced shows loading.
    return switch (_selectedFilterIndex) {
      0 => _buildDataState(context),
      1 => CustomerListErrorStateWidget(onRetry: _handleRetry),
      2 => EmptyCustomerStateWidget(
        onCreatePressed: () => _openCreateCustomer(context),
      ),
      3 => const CustomerListLoadingStateWidget(),
      _ => _buildDataState(context),
    };
  }

  Widget _buildDisplayState(
    BuildContext context,
    CustomerListDisplayState state,
  ) {
    return switch (state) {
      CustomerListDisplayState.data => _buildDataState(context),
      CustomerListDisplayState.empty => EmptyCustomerStateWidget(
        onCreatePressed: () => _openCreateCustomer(context),
      ),
      CustomerListDisplayState.loading =>
        const CustomerListLoadingStateWidget(),
      CustomerListDisplayState.error => CustomerListErrorStateWidget(
        onRetry: _handleRetry,
      ),
    };
  }

  Widget _buildDataState(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Text(
            '${formatPersianNumber(_mockCustomers.length)} مشتری',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: _mockCustomers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final customer = _mockCustomers[index];
              return CustomerCardWidget(
                customer: customer,
                onTap: () => _handleCustomerTap(customer),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openCreateCustomer(BuildContext context) {
    // Reuse the existing customer-registration route; the form is outside
    // this UI-only task.
    context.router.push(CreateCustomerRoute());
  }

  void _handleCustomerTap(CustomerCardData customer) {
    context.router.push(CustomerDetailsRoute(customerId: customer.id));
  }

  void _handleRetry() {
    // TODO: Connect retry to the data source when the UI leaves mock mode.
  }
}
/// Filter pills shown above the body. Tapping a pill reports the new index
/// to the page, which decides which state to show beneath it.
class _CustomerFilterBar extends StatelessWidget {
  const _CustomerFilterBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static final List<_CustomerFilterOption> _filters = [
    _CustomerFilterOption(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'همه',
      colorOf: (scheme) => scheme.primary,
    ),
    _CustomerFilterOption(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'بدهکاران',
      colorOf: (scheme) => scheme.error,
    ),
    _CustomerFilterOption(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'فاکتورها',
      colorOf: (_) => kSuccessColor,
    ),
    _CustomerFilterOption(
      icon: Icons.receipt_outlined,
      selectedIcon: Icons.receipt,
      label: 'فاکتور نشده‌ها',
      colorOf: (_) => kGrey2Color,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _FilterPill(
              icon: _filters[i].icon,
              selectedIcon: _filters[i].selectedIcon,
              label: _filters[i].label,
              color: _filters[i].colorOf(scheme),
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

/// Static description of one filter pill: its glyphs (outlined when idle,
/// filled when selected), label, and how the accent colour is derived from
/// the active [ColorScheme].
class _CustomerFilterOption {
  const _CustomerFilterOption({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.colorOf,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color Function(ColorScheme scheme) colorOf;
}

/// How long a pill takes to morph between idle and selected, so the size
/// jump reads as a smooth grow instead of a layout snap.
const Duration _kPillAnimationDuration = Duration(milliseconds: 200);

class _FilterPill extends StatelessWidget {
  const _FilterPill({
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
      // The selected pill gets a touch more padding so the whole tag
      // reads visibly larger, not just its glyphs.
      padding: EdgeInsets.symmetric(
        horizontal: selected ? 13 : 12,
        vertical: selected ? 8 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: selected ? 0.16 : 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: selected ? 0.6 : 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // begin == end so the pill never animates on first build;
              // only a later selection flip retargets the tween and
              // eases the icon between 16 and 18.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: selected ? 18 : 16,
                  end: selected ? 18 : 16,
                ),
                duration: _kPillAnimationDuration,
                curve: Curves.easeOut,
                builder: (context, size, _) => Icon(
                  selected ? selectedIcon : icon,
                  size: size,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: _kPillAnimationDuration,
                curve: Curves.easeOut,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: color,
                  // Selected pill is a full step larger (14 → 16, the
                  // project's labelLarge size) so the active filter reads
                  // at a glance; the weight stays SemiBold in both states.
                  fontSize: selected ? 16 : null,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Presentation-only records used to make the customer card states visible.
/// Names, phones and balances mirror the reference mockup.
const List<CustomerCardData> _mockCustomers = <CustomerCardData>[
  CustomerCardData(
    id: 'customer-1',
    name: 'علی رضایی',
    phoneNumber: '09121234567',
    status: CustomerCardStatus.debtor,
    balance: 2500000,
  ),
  CustomerCardData(
    id: 'customer-2',
    name: 'محمد احمدی',
    phoneNumber: '09359876543',
    status: CustomerCardStatus.settled,
  ),
  CustomerCardData(
    id: 'customer-3',
    name: 'سارا محمدی',
    phoneNumber: '09198765432',
    status: CustomerCardStatus.debtor,
    balance: 1200000,
  ),
  CustomerCardData(
    id: 'customer-4',
    name: 'حسین یوسفی',
    phoneNumber: '09012345678',
    status: CustomerCardStatus.creditor,
    balance: 350000,
  ),
  CustomerCardData(
    id: 'customer-5',
    name: 'مرضیه حسینی',
    phoneNumber: '09301112233',
    status: CustomerCardStatus.settled,
  ),
];
