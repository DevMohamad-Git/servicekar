import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../injection/global_providers.dart';
import '../logic/customer_use_case_providers.dart';

/// Create customer page (Live Persistence form).
///
/// Form fields survive pushes/pops because each `TextField` uses a
/// widget-local `PageStorageKey`. State submitted through
/// `createCustomerControllerProvider`; on success the live
/// `customerListControllerProvider` is invalidated so the list page
/// (whenever the user returns to it) sees the new record immediately.
@RoutePage()
class CreateCustomerPage extends ConsumerStatefulWidget {
  const CreateCustomerPage({super.key});

  @override
  ConsumerState<CreateCustomerPage> createState() =>
      _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName =
      TextEditingController(text: '');
  late final TextEditingController _phone =
      TextEditingController(text: '');
  late final TextEditingController _email =
      TextEditingController(text: '');
  late final TextEditingController _address =
      TextEditingController(text: '');
  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  String _generateId() =>
      'cus_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final helper = ref.read(appHelperProvider);
    final failure = await ref
        .read(createCustomerControllerProvider.notifier)
        .submit(
          id: _generateId(),
          fullName: _fullName.text.trim(),
          phoneNumber: _phone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (failure == null) {
      if (!context.mounted) return;
      helper.displayToast(context, message: context.l10n.customerCreated);
      context.router.maybePop();
    } else {
      if (!context.mounted) return;
      helper.displayToast(context, message: failure, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.newCustomer)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const PageStorageKey('create_fullName'),
                controller: _fullName,
                decoration: InputDecoration(labelText: context.l10n.fullName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? context.l10n.required
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const PageStorageKey('create_phone'),
                controller: _phone,
                decoration:
                    InputDecoration(labelText: context.l10n.phoneNumber),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? context.l10n.required
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const PageStorageKey('create_email'),
                controller: _email,
                decoration: InputDecoration(labelText: context.l10n.email),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const PageStorageKey('create_address'),
                controller: _address,
                decoration: InputDecoration(labelText: context.l10n.address),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : () => _submit(context),
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.create),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
