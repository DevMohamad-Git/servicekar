import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/features/balance/domain/usecases/calculate_customer_balance_usecase.dart';
import 'package:servicar/features/balance/domain/value_models/customer_balance_result.dart';

import 'customer_providers.dart';
import 'invoice_providers.dart';
import 'payment_providers.dart';

/// Balance feature — Riverpod bindings
/// =====================================
///
/// Cross-feature use case wiring:
///   * [CalculateCustomerBalanceUseCase] consumes one repository
///     each from Customer, Invoice, and Payment.
///   * No data layer here — the balance domain has no
///     `IsarCollection` of its own; the value is *purely derived*
///     by summing existing rows from the three parents. The
///     "no balance stored on Customer / Invoice / Payment" rule
///     keeps the result ephemeral: it lives only inside
///     [CustomerBalanceResult] and is re-derived on every query.
///
/// Why this is separated from `payment_providers.dart` rather
/// than nested there: a balance derivation is conceptually a
/// *cross-feature* business rule. Putting it under its own
/// provider file lets a future refactor move all balance logic
/// into a dedicated `.dart` namespace without altering the
/// Payment or Customer architecture.
final calculateCustomerBalanceUseCaseProvider =
    Provider<CalculateCustomerBalanceUseCase>(
      (ref) => CalculateCustomerBalanceUseCase(
        customerRepository: ref.watch(customerRepositoryProvider),
        invoiceRepository: ref.watch(invoiceRepositoryProvider),
        paymentRepository: ref.watch(paymentRepositoryProvider),
      ),
    );

/// Family-keyed async balance state. UI watches
/// `ref.watch(customerBalanceControllerProvider(customerUuid))`.
///
/// Mirrors the customer feature's `CustomerDetailsController`:
/// plain `AsyncNotifier<CustomerBalanceResult>` + the family key
/// captured in the constructor — no Riverpod family mixin needed
/// because `AsyncNotifierProvider.family<>` accepts a constructor
/// just as easily.
class CustomerBalanceController extends AsyncNotifier<CustomerBalanceResult> {
  CustomerBalanceController(this.customerUuid);

  final String customerUuid;

  @override
  Future<CustomerBalanceResult> build() async {
    final useCase = ref.watch(calculateCustomerBalanceUseCaseProvider);
    final result = await useCase(customerUuid);
    return result.fold((failure) => throw failure, (success) => success);
  }

  /// Pure refetch — no mutation. Used by pull-to-refresh and the
  /// "retry" affordance when the balance query has previously
  /// thrown a [BalanceFailure].
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final customerBalanceControllerProvider =
    AsyncNotifierProvider.family<
      CustomerBalanceController,
      CustomerBalanceResult,
      String
    >(CustomerBalanceController.new);
