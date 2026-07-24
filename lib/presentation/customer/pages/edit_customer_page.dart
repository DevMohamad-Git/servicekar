import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../injection/global_providers.dart';
import '../../../injection/feature_injection/customer_providers.dart';

/// Edit customer page (Live Persistence form).
///
/// Sources initial form values from the live
/// `customerDetailsControllerProvider(id)`, so the page always shows
/// the freshest data. Submits via `updateCustomerControllerProvider`
/// which invalidates the list + details providers on success.
@RoutePage()
class EditCustomerPage extends ConsumerStatefulWidget {
  const EditCustomerPage({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends ConsumerState<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _fullName;
  TextEditingController? _phone;
  TextEditingController? _email;
  TextEditingController? _address;
  bool _hydrated = false;
  bool _submitting = false;

  @override
  void dispose() {
    _fullName?.dispose();
    _phone?.dispose();
    _email?.dispose();
    _address?.dispose();
    super.dispose();
  }

  void _hydrate(Map<String, dynamic> value) {
    if (_hydrated) return;
    _fullName = TextEditingController(text: value['fullName'] as String? ?? '');
    _phone = TextEditingController(text: value['phone'] as String? ?? '');
    _email = TextEditingController(text: value['email'] as String? ?? '');
    _address = TextEditingController(text: value['address'] as String? ?? '');
    _hydrated = true;
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final helper = ref.read(appHelperProvider);
    final current = ref
        .read(customerDetailsControllerProvider(widget.customerId))
        .value;
    if (current == null) return;
    final failure = await ref
        .read(updateCustomerControllerProvider.notifier)
        .submit(
          current.copyWith(
            fullName: _fullName!.text.trim(),
            phoneNumber: _phone!.text.trim(),
            email: _email!.text.trim().isEmpty ? null : _email!.text.trim(),
            address:
                _address!.text.trim().isEmpty ? null : _address!.text.trim(),
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (failure == null) {
      if (!context.mounted) return;
      helper.displayToast(context, message: context.l10n.customerUpdated);
      Navigator.of(context).pop();
    } else {
      if (!context.mounted) return;
      helper.displayToast(context, message: failure, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      customerDetailsControllerProvider(widget.customerId),
    );
    return state.when(
      data: (customer) {
        _hydrate({
          'fullName': customer.fullName,
          'phone': customer.phoneNumber,
          'email': customer.email,
          'address': customer.address,
        });
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.editCustomer)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _fullName,
                    decoration: InputDecoration(
                        labelText: context.l10n.fullName),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.required
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    decoration: InputDecoration(
                        labelText: context.l10n.phoneNumber),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.required
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration:
                        InputDecoration(labelText: context.l10n.email),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    decoration:
                        InputDecoration(labelText: context.l10n.address),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        _submitting ? null : () => _submit(context),
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.save),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, _) =>
          Center(child: Text(error.toString())),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
