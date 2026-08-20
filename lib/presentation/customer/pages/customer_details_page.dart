import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/core.dart';
import '../../../features/customer/domain/entities/invoice_entity.dart';
import '../../../features/customer/domain/entities/payment_entity.dart';
import '../../../features/customer/domain/entities/service_entity.dart';
import '../../../injection/global_providers.dart';
import '../widgets/customer_account_summary_widget.dart';
import '../widgets/customer_history_empty_state.dart';
import '../widgets/customer_history_items.dart';
import '../widgets/customer_info_card_widget.dart';
import '../widgets/customer_page_header.dart';
import '../widgets/customer_quick_actions_widget.dart';

/// Customer profile page — the single shared destination for every
/// customer, keyed by [customerId].
///
/// ─── UI-first stage ──────────────────────────────────────────────
/// This page currently renders *mock* data so the reference mockup can
/// be reviewed before the data layer is wired. The data-layer
/// controllers (`customerDetailsControllerProvider`,
/// `customerBalanceControllerProvider`, the services / invoices /
/// payments controllers) are intentionally NOT read here yet. The
/// page keeps [customerId] on the widget contract so the future
/// switch from mock data to Riverpod is mechanical: replace the mock
/// builders with `ref.watch(...)` lookups keyed by [customerId].
///
/// ─── Composition ─────────────────────────────────────────────────
/// All visuals are reused from `lib/presentation/customer/widgets/`:
///   * [CustomerInfoCardWidget]      — avatar, name, phone, address, edit.
///   * [CustomerAccountSummaryWidget]— status + balance + last update.
///   * [CustomerQuickActionsWidget]  — issue invoice / register service /
///                                     register payment / call.
///   * [ServiceHistoryCard] / [InvoiceHistoryCard] / [PaymentHistoryCard]
///     and [CustomerHistoryEmptyState] — the per-tab history lists.
@RoutePage()
class CustomerDetailsPage extends ConsumerStatefulWidget {
  const CustomerDetailsPage({super.key, required this.customerId});

  /// Stable identifier of the customer being shown. Mock data does not
  /// vary per id today, but every mock row is already stamped with it
  /// so the data-layer hand-off is a drop-in change.
  final String customerId;

  @override
  ConsumerState<CustomerDetailsPage> createState() =>
      _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// Mock phone number shared by the info card and the «تماس» quick action
  /// until the data layer supplies the real customer.
  static const String _mockPhoneNumber = '09121234567';

  /// Bridge to the Android `ACTION_DIAL` handler in `MainActivity.kt`.
  static const MethodChannel _dialerChannel = MethodChannel('servicar/dialer');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Mock data (UI-first; replaced by the data layer later) ──────

  List<ServiceHistoryItem> get _mockServices => [
    ServiceHistoryItem(
      service: ServiceEntity(
        id: 'mock-svc-1',
        customerUuid: widget.customerId,
        title: 'تعمیر پکیج دیواری',
        description: 'تعویض پمپ آب',
        status: ServiceStatus.completed,
        price: 2500000,
        completedAt: DateTime(2026, 8, 8),
      ),
      dateLabel: '۲۰ مرداد ۱۴۰۵',
    ),
    ServiceHistoryItem(
      service: ServiceEntity(
        id: 'mock-svc-2',
        customerUuid: widget.customerId,
        title: 'سرویس و شارژ کولر گازی',
        description: 'شستشو و شارژ گاز',
        status: ServiceStatus.completed,
        price: 1200000,
        completedAt: DateTime(2026, 6, 30),
      ),
      dateLabel: '۱۰ تیر ۱۴۰۵',
    ),
    ServiceHistoryItem(
      service: ServiceEntity(
        id: 'mock-svc-3',
        customerUuid: widget.customerId,
        title: 'رفع نشتی لوله آب',
        description: 'تعویض اتصالات و واشر',
        status: ServiceStatus.completed,
        price: 800000,
        completedAt: DateTime(2026, 6, 15),
      ),
      dateLabel: '۲۵ خرداد ۱۴۰۵',
    ),
  ];

  List<InvoiceHistoryItem> get _mockInvoices => [
    InvoiceHistoryItem(
      invoice: InvoiceEntity(
        id: 'mock-inv-1',
        customerUuid: widget.customerId,
        invoiceNumber: 'INV-1405-0042',
        issueDate: DateTime(2026, 8, 8),
        status: InvoiceStatus.issued,
        totalAmount: 2500000,
      ),
      dateLabel: '۲۰ مرداد ۱۴۰۵',
    ),
    InvoiceHistoryItem(
      invoice: InvoiceEntity(
        id: 'mock-inv-2',
        customerUuid: widget.customerId,
        invoiceNumber: 'INV-1405-0038',
        issueDate: DateTime(2026, 6, 30),
        status: InvoiceStatus.paid,
        totalAmount: 1200000,
      ),
      dateLabel: '۱۰ تیر ۱۴۰۵',
    ),
  ];

  List<PaymentHistoryItem> get _mockPayments => [
    PaymentHistoryItem(
      payment: PaymentEntity(
        id: 'mock-pay-1',
        customerUuid: widget.customerId,
        amount: 1200000,
        paidAt: DateTime(2026, 7, 1),
        method: PaymentMethod.card,
      ),
      dateLabel: '۱ تیر ۱۴۰۵',
    ),
    PaymentHistoryItem(
      payment: PaymentEntity(
        id: 'mock-pay-2',
        customerUuid: widget.customerId,
        amount: 800000,
        paidAt: DateTime(2026, 6, 24),
        method: PaymentMethod.cash,
      ),
      dateLabel: '۲۴ خرداد ۱۴۰۵',
    ),
  ];

  // ─── Actions ─────────────────────────────────────────────────────

  /// Placeholder for every action whose real route/flow has not shipped
  /// yet (quick actions, "view all", history rows, delete). Reuses the
  /// existing `comingSoon` surface; no new business logic here.
  void _showComingSoon() {
    ref
        .read(appHelperProvider)
        .displayToast(context, message: context.l10n.comingSoon);
  }

  /// Opens the device dialer with the customer's number pre-filled (Android
  /// `ACTION_DIAL`) so the user only has to press the call button. Shows a
  /// fallback toast when no dialer can be opened.
  Future<void> _callCustomer() async {
    try {
      await _dialerChannel.invokeMethod<void>('openDialer', <String, Object?>{
        'number': _mockPhoneNumber,
      });
    } on PlatformException catch (error) {
      AppLogger.error('Failed to open dialer', error: error);
      if (mounted) {
        ref
            .read(appHelperProvider)
            .displayToast(
              context,
              message: 'امکان باز کردن شماره‌گیر وجود ندارد',
              isError: true,
            );
      }
    } on MissingPluginException {
      AppLogger.error('Dialer platform channel is not registered');
      if (mounted) {
        _showComingSoon();
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deleteCustomerDialogTitle),
        content: Text(ctx.l10n.deleteCustomerDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // Data layer is intentionally not connected in this UI-first stage.
    _showComingSoon();
  }

  // ─── History tab content ─────────────────────────────────────────

  List<Widget> _serviceCards() {
    final items = _mockServices;
    return [
      for (var i = 0; i < items.length; i++) ...[
        ServiceHistoryCard(item: items[i], onTap: _showComingSoon),
        if (i < items.length - 1) const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _invoiceCards() {
    final items = _mockInvoices;
    return [
      for (var i = 0; i < items.length; i++) ...[
        InvoiceHistoryCard(item: items[i], onTap: _showComingSoon),
        if (i < items.length - 1) const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _paymentCards() {
    final items = _mockPayments;
    return [
      for (var i = 0; i < items.length; i++) ...[
        PaymentHistoryCard(item: items[i], onTap: _showComingSoon),
        if (i < items.length - 1) const SizedBox(height: 10),
      ],
    ];
  }

  /// One inline icon+label tab, scaled down by [FittedBox] so long
  /// Persian labels never overflow a narrow, equal-width tab.
  Widget _historyTab(IconData icon, String label) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _historyHeader(String title) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: kTextPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _showComingSoon,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.viewAll,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.chevron_left, size: 18, color: scheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyList({
    required String headerTitle,
    required List<Widget> cards,
    required IconData emptyIcon,
    required String emptyMessage,
    required String emptyActionLabel,
  }) {
    return ListView(
      primary: false,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _historyHeader(headerTitle),
        const SizedBox(height: 12),
        if (cards.isEmpty)
          CustomerHistoryEmptyState(
            icon: emptyIcon,
            message: emptyMessage,
            actionLabel: emptyActionLabel,
            onAction: _showComingSoon,
          )
        else
          ...cards,
      ],
    );
  }

  // ─── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomerPageHeader(
        title: context.l10n.customerProfile,
        onBack: () => context.router.maybePop(),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(context.l10n.deleteCustomer),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        // Same soft gradient + hairline border as the
                        // quick-action tiles, so the profile card reads as a
                        // distinct elevated surface on the white page.
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF1F3F6), Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kGrey4Color.withValues(alpha: 0.9),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomerInfoCardWidget(
                            fullName: 'محمد رضایی',
                            phoneNumber: _mockPhoneNumber,
                            address:
                                'تهران، شهرک غرب، خیابان ایران زمین، پلاک ۱۲',
                            onEdit: () => context.router.push(
                              EditCustomerRoute(customerId: widget.customerId),
                            ),
                          ),
                          CustomerAccountSummaryWidget(
                            status: CustomerAccountStatus.debtor,
                            amount: 2500000,
                            lastUpdated: 'امروز، ۹:۱۵',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomerQuickActionsWidget(
                      onIssueInvoice: _showComingSoon,
                      onRegisterService: _showComingSoon,
                      onRegisterPayment: _showComingSoon,
                      onCall: _callCustomer,
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: scheme.primary,
                    unselectedLabelColor: scheme.onSurfaceVariant,
                    indicatorColor: scheme.primary,
                    indicatorWeight: 2.5,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      _historyTab(Icons.build_outlined, context.l10n.services),
                      _historyTab(
                        Icons.receipt_long_outlined,
                        context.l10n.invoices,
                      ),
                      _historyTab(
                        Icons.account_balance_wallet_outlined,
                        context.l10n.payments,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _historyList(
                        headerTitle: context.l10n.serviceHistory,
                        cards: _serviceCards(),
                        emptyIcon: Icons.build_outlined,
                        emptyMessage: context.l10n.emptyServices,
                        emptyActionLabel: context.l10n.registerService,
                      ),
                      _historyList(
                        headerTitle: context.l10n.invoiceHistory,
                        cards: _invoiceCards(),
                        emptyIcon: Icons.receipt_long_outlined,
                        emptyMessage: context.l10n.emptyInvoices,
                        emptyActionLabel: context.l10n.registerInvoice,
                      ),
                      _historyList(
                        headerTitle: context.l10n.paymentHistory,
                        cards: _paymentCards(),
                        emptyIcon: Icons.account_balance_wallet_outlined,
                        emptyMessage: context.l10n.emptyPayments,
                        emptyActionLabel: context.l10n.registerPayment,
                      ),
                    ],
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
