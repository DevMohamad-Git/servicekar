import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Placeholder create page. Will host the form + button row + submit
/// hook in the follow-up Create screen task. Kept here so the router
/// can be wired today.
class CreateCustomerPage extends HookConsumerWidget {
  const CreateCustomerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        // TODO: AppLocalizations.of(context).customersCreateTitle
        title: const Text('New customer'),
      ),
      body: const Center(
        child: Text(
          // TODO: implement Create form (name, phone, email, address, notes)
          'Create form goes here.',
        ),
      ),
    );
  }
}
