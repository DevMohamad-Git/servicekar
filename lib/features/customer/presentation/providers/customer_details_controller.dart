import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/customer_entity.dart';
import 'customer_use_case_providers.dart';

/// Family-keyed state holding a single [CustomerEntity]. UI reads
/// `customerDetailsControllerProvider(id)`.
///
/// In Riverpod 3.x, family `AsyncNotifierProvider`s take a constructor
/// that receives the family argument directly (no separate
/// `FamilyAsyncNotifier` base class).
class CustomerDetailsController extends AsyncNotifier<CustomerEntity> {
  CustomerDetailsController(this.customerId);

  final String customerId;

  @override
  Future<CustomerEntity> build() async {
    final useCase = ref.watch(getCustomerByIdUseCaseProvider);
    final result = await useCase(customerId);
    // Throwing the [CustomerFailure] surfaces it as `AsyncError` so the
    // page renders an error state carrying the original failure.
    return result.fold(
      (failure) => throw failure,
      (customer) => customer,
    );
  }
}

final customerDetailsControllerProvider =
    AsyncNotifierProvider.family<CustomerDetailsController, CustomerEntity,
        String>(
  CustomerDetailsController.new,
);
