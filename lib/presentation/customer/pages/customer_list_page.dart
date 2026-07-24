import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/routes/app_router.dart';
import '../../../features/customer/domain/failures/customer_failure.dart';
import '../../../injection/feature_injection/customer_providers.dart';
import '../widgets/customer_card_widget.dart';
import '../widgets/customer_search_bar_widget.dart';
import '../widgets/empty_customer_state_widget.dart';

/// Live-persistent customer list page.
///
/// Each customer record has a live card in the list. The list itself
/// uses [WidgetsBindingObserver] to refetch the live provider state
/// whenever the app returns from the background — that's how this
/// page preserves "live persistence" without explicit pull-to-refresh.
@RoutePage()
class CustomerListPage extends ConsumerStatefulWidget {
  const CustomerListPage({super.key});

  @override
  ConsumerState<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends ConsumerState<CustomerListPage>
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
      // Live Persistence: refresh list state from data layer whenever
      // the app returns to the foreground.
      ref.read(customerListControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.customers),
        actions: [
          IconButton(
            tooltip: context.l10n.refresh,
            onPressed: () =>
                ref.read(customerListControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(const CreateCustomerRoute()),
        tooltip: context.l10n.addCustomer,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CustomerSearchBarWidget(
            onChanged: (_) {
              // TODO: wire to SearchCustomersUseCase once the controller
              // exposes a debounced query parameter.
            },
          ),
          Expanded(
            child: switch (state) {
              AsyncData(:final value) when value.isEmpty =>
                EmptyCustomerStateWidget(
                  onCreatePressed: () =>
                      context.router.push(const CreateCustomerRoute()),
                ),
              AsyncData(:final value) => ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final c = value[index];
                    return CustomerCardWidget(
                      customer: c,
                      onTap: () => context.router.push(
                        CustomerDetailsRoute(customerId: c.id),
                      ),
                    );
                  },
                ),
              AsyncError(:final error) => Center(
                  child: Text(
                    error is CustomerFailure
                        ? error.message
                        : error.toString(),
                  ),
                ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}
