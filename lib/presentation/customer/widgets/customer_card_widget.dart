import 'package:flutter/material.dart';

import '../../../features/customer/domain/entities/customer_entity.dart';

/// Compact summary tile for a single customer record.
///
/// Lives in `lib/presentation/customer/widgets/` per Lalafen's
/// layout — a feature's UI surfaces (pages, widgets) are siblings of
/// data/domain under `features/...`, never nested inside it.
///
/// ─── Balance display ───────────────────────────────────────────────
/// The previously-rendered trailing balance value was sourced from
/// `customerEntity.balance`, a cached persisted field with no write
/// path. The architecture cleanup removed that field entirely — the
/// canonical balance is now derived live from `Invoice + Payment` by
/// the Balance feature. The list view would otherwise force N+1
/// customer-balance-controller reads per scroll. Per the cleanup
/// brief's "remove the obsolete cached value from that display"
/// guidance for list views, the trailing balance is no longer
/// shown here. The detail page renders the live derived balance via
/// `customerBalanceControllerProvider`.
class CustomerCardWidget extends StatelessWidget {
  const CustomerCardWidget({super.key, required this.customer, this.onTap});

  final CustomerEntity customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          // TODO: AppLocalizations.of(context).customersCardName
          customer.fullName,
        ),
        subtitle: Text(
          // TODO: AppLocalizations.of(context).customersCardPhone
          customer.phoneNumber,
        ),
        onTap: onTap,
      ),
    );
  }
}
