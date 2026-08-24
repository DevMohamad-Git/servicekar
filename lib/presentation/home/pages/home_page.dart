import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/routes/app_router.dart';
import '../../../injection/feature_injection/dashboard_providers.dart';
import '../../../injection/global_providers.dart';
import '../widgets/business_overview_section.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/recent_activities_section.dart';
import '../widgets/total_debtors_card.dart';

/// ServiceKar dashboard — the root `/` route.
///
/// Replaces the former placeholder home screen. Live metrics are the
/// total debtors figure (derived from Customer + Invoice + Payment data)
/// and the "نمای کلی کسب‌وکار" KPI counts (real invoice / customer /
/// service counts from their owning repositories); the recent-activities
/// list is intentionally static mock content until the dashboard UI has
/// been validated (no Activity/Ledger collection yet).
@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Live persistence: refresh every dashboard metric when the app
      // returns to the foreground (mirrors the customer list page).
      ref.read(totalDebtorsControllerProvider.notifier).refresh();
      ref.read(invoiceCountControllerProvider.notifier).refresh();
      ref.read(customerCountControllerProvider.notifier).refresh();
      ref.read(serviceCountControllerProvider.notifier).refresh();
    }
  }

  void _showComingSoon() {
    ref
        .read(appHelperProvider)
        .displayToast(context, message: context.l10n.comingSoon);
  }

  void _openServiceEntry() {
    ref.read(appRouterProvider).push(ServiceEntryRoute());
  }

  void _openPaymentEntry() {
    ref.read(appRouterProvider).push(PaymentEntryRoute());
  }

  @override
  Widget build(BuildContext context) {
    final debtors = ref.watch(totalDebtorsControllerProvider);
    final debtorsAmount = switch (debtors) {
      AsyncData(:final value) => value,
      _ => null,
    };

    // Business Overview KPIs — three independent real counts, each
    // surfaced as its own AsyncValue so one failure never hides the
    // others.
    final invoices = ref.watch(invoiceCountControllerProvider);
    final customers = ref.watch(customerCountControllerProvider);
    final services = ref.watch(serviceCountControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DashboardHeader(),
                    const SizedBox(height: 20),
                    TotalDebtorsCard(
                      amount: debtorsAmount,
                      isLoading: debtors.isLoading,
                      hasError: debtors.hasError,
                      onViewDebtors: _showComingSoon,
                    ),
                    const SizedBox(height: 28),
                    BusinessOverviewSection(
                      invoices: invoices,
                      customers: customers,
                      services: services,
                    ),
                    const SizedBox(height: 28),
                    RecentActivitiesSection(onViewAll: _showComingSoon),
                  ],
                ),
              ),
            ),
            HomeBottomNav(
              onComingSoon: _showComingSoon,
              onRegisterService: _openServiceEntry,
              onRegisterPayment: _openPaymentEntry,
            ),
          ],
        ),
      ),
    );
  }
}
