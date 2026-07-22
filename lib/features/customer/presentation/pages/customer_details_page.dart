import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/failures/customer_failure.dart';
import '../providers/customer_details_controller.dart';
import '../widgets/customer_balance_widget.dart';

/// Placeholder details page. Receives the customer id via constructor
/// (auto_route will pass it once registered) and surfaces a stub layout.
class CustomerDetailsPage extends HookConsumerWidget {
  const CustomerDetailsPage({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDetailsControllerProvider(customerId));

    return Scaffold(
      appBar: AppBar(
        // TODO: AppLocalizations.of(context).customersDetailsTitle
        title: const Text('Customer details'),
      ),
      body: switch (state) {
        AsyncData(:final value) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.fullName,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(value.phoneNumber,
                    style: Theme.of(context).textTheme.bodyLarge),
                if (value.email != null) Text(value.email!),
                if (value.address != null) Text(value.address!),
                const SizedBox(height: 16),
                CustomerBalanceWidget(balance: value.balance),
              ],
            ),
          ),
        AsyncError(:final error) => Center(
          child: Text(
            error is CustomerFailure ? error.message : error.toString(),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
