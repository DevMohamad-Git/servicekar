import 'package:flutter/material.dart';

import '../../../features/customer/domain/entities/customer_entity.dart';

/// Compact summary tile for a single customer record.
///
/// Lives in `lib/presentation/customer/widgets/` per Lalafen's
/// layout — a feature's UI surfaces (pages, widgets) are siblings of
/// data/domain under `features/...`, never nested inside it.
class CustomerCardWidget extends StatelessWidget {
  const CustomerCardWidget({
    super.key,
    required this.customer,
    this.onTap,
  });

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
        trailing: Text(
          // TODO: AppLocalizations.of(context).customersCardBalance
          customer.balance.toStringAsFixed(2),
        ),
        onTap: onTap,
      ),
    );
  }
}
