import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Placeholder edit page. Mirrors [CreateCustomerPage] but pre-fills
/// fields from an existing record fetched via the details controller.
class EditCustomerPage extends HookConsumerWidget {
  const EditCustomerPage({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        // TODO: AppLocalizations.of(context).customersEditTitle
        title: const Text('Edit customer'),
      ),
      body: const Center(
        child: Text(
          // TODO: implement Edit form pre-filled with current customer
          'Edit form goes here.',
        ),
      ),
    );
  }
}
