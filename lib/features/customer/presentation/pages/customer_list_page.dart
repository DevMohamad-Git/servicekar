import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/failures/customer_failure.dart';
import '../providers/customer_list_controller.dart';
import '../widgets/customer_card_widget.dart';
import '../widgets/customer_search_bar_widget.dart';
import '../widgets/empty_customer_state_widget.dart';

/// Placeholder list/landing page. UI deliberately kept minimal — the
/// goal here is wiring, not design. Real screens land in a follow-up.
class CustomerListPage extends HookConsumerWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        // TODO: AppLocalizations.of(context).customersListTitle
        title: const Text('Customers'),
        actions: [
          IconButton(
            tooltip: 'Refresh', // TODO: l10n
            onPressed: () =>
                ref.read(customerListControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                const EmptyCustomerStateWidget(),
              AsyncData(:final value) => ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final c = value[index];
                    return CustomerCardWidget(customer: c);
                  },
                ),
              AsyncError(:final error) => Center(
                  // The controller throws the original `CustomerFailure`,
                  // so cast + read the human-readable message. Fall back to
                  // a generic string for anything else that slipped in.
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
