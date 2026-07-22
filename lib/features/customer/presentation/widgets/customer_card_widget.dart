import 'package:flutter/material.dart';

import '../../domain/entities/customer_entity.dart';

/// Compact summary tile for a single customer record.
///
/// Localization keys (`customers.*`) replace the inline string literals
/// once `flutter_gen` + `AppLocalizations` are configured under
/// `lib/config/l10n/`.
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
