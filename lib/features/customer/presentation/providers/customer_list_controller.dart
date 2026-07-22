import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/customer_entity.dart';
import 'customer_use_case_providers.dart';

/// Async state for the customer list page.
///
/// Drives `ref.watch(customerListControllerProvider)` in
/// `CustomerListPage`; UI does not access the repository directly.
class CustomerListController extends AsyncNotifier<List<CustomerEntity>> {
  @override
  Future<List<CustomerEntity>> build() async {
    final useCase = ref.watch(getCustomersUseCaseProvider);
    final result = await useCase();
    // Throwing the [CustomerFailure] lets the page render an [AsyncError]
    // carrying the original failure; the presentation layer translates
    // it to a localized message via `AppLocalizations`.
    return result.fold(
      (failure) => throw failure,
      (customers) => customers,
    );
  }

  /// Pull-to-refresh / retry hook.
  Future<void> refresh() => ref.refresh(customerListControllerProvider.future);
}

final customerListControllerProvider =
    AsyncNotifierProvider<CustomerListController, List<CustomerEntity>>(
  CustomerListController.new,
);
