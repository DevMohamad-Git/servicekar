import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/routes/app_router.dart';
import '../../../features/customer/domain/failures/customer_failure.dart';
import '../../../injection/global_providers.dart';
import '../logic/customer_use_case_providers.dart';
import '../widgets/customer_balance_widget.dart';

/// Live-persistent customer details page.
///
/// Survives push/pop (state held in the live `customerDetailsControllerProvider`)
/// and re-syncs whenever the app comes back to the foreground. Edit/Delete
/// actions go through Riverpod controllers so Live Persistence updates the
/// list too.
@RoutePage()
class CustomerDetailsPage extends ConsumerStatefulWidget {
  const CustomerDetailsPage({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CustomerDetailsPage> createState() =>
      _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage>
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
      // Live Persistence: pull latest record from data layer on resume.
      ref.invalidate(customerDetailsControllerProvider(widget.customerId));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final helper = ref.read(appHelperProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      // The dialog builder's BuildContext is `ctx` — use it for
      // l10n lookups so a future dialog-construction refactor can't
      // accidentally grab the parent's `context`.
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
    if (confirmed != true || !context.mounted) return;
    final failure = await ref
        .read(deleteCustomerControllerProvider.notifier)
        .submit(widget.customerId);
    if (!context.mounted) return;
    if (failure == null) {
      helper.displayToast(context, message: context.l10n.customerDeleted);
      Navigator.of(context).pop();
    } else {
      helper.displayToast(context, message: failure, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      customerDetailsControllerProvider(widget.customerId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.customerDetails),
        actions: [
          switch (state) {
            AsyncData() => Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.edit,
                    onPressed: () => context.router.push(
                      EditCustomerRoute(customerId: widget.customerId),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    tooltip: context.l10n.delete,
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            _ => const SizedBox.shrink(),
          },
        ],
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
