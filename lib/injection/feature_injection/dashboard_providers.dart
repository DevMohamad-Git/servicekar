import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'balance_providers.dart';
import 'customer_providers.dart';
import 'invoice_providers.dart';
import 'service_providers.dart';

/// Dashboard feature — Riverpod bindings.
/// ========================================
/// The dashboard exposes two kinds of live metrics:
///
///   * "مجموع بدهکاران" — the sum of every debtor customer's outstanding
///     amount. It is *derived* — never stored — by reusing the existing
///     customer + balance use cases, so no new domain or repository
///     surface is introduced.
///   * The "نمای کلی کسب‌وکار" KPI counts (registered invoices /
///     customers / services). Each is a real count read through the
///     owning feature's repository (invoice / customer / service) — never
///     a cached or mock figure.
///
/// When the invoice / payment screens land, they should invalidate
/// [totalDebtorsControllerProvider] the same way they already invalidate
/// `customerBalanceControllerProvider`, and the count controllers below
/// the same way the owning feature's controllers are invalidated, so the
/// summaries re-derive after a write.
class TotalDebtorsController extends AsyncNotifier<double> {
  @override
  Future<double> build() async {
    final customersResult = await ref.read(getCustomersUseCaseProvider)();
    final customers = customersResult.fold(
      (failure) => throw failure,
      (list) => list,
    );

    final balanceUseCase = ref.read(calculateCustomerBalanceUseCaseProvider);
    var total = 0.0;
    for (final customer in customers) {
      final balanceResult = await balanceUseCase(customer.id);
      final balance = balanceResult.fold(
        (failure) => throw failure,
        (result) => result,
      );

      // A debtor has a negative derived balance (invoices exceed payments).
      // The amount the customer *owes* is the magnitude of that balance.
      if (balance.balance < 0) {
        total += -balance.balance;
      }
    }
    return total;
  }

  /// Pull-to-refresh / app-resume hook. Pure refetch — no mutation.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final totalDebtorsControllerProvider =
    AsyncNotifierProvider<TotalDebtorsController, double>(
      TotalDebtorsController.new,
    );

// ─── Business Overview KPI counts ──────────────────────────────────
// Three independent, real database counts for the "نمای کلی کسب‌وکار"
// section. Each controller owns exactly one count so a failure or a slow
// read in one KPI never hides the others. All three reuse the owning
// feature's existing use case → repository → datasource chain — no Isar
// access from presentation, no new collections.

/// Real count of persisted invoices (all customers).
class InvoiceCountController extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final result = await ref.read(getInvoiceCountUseCaseProvider)();
    return result.fold((failure) => throw failure, (count) => count);
  }

  /// Pull-to-refresh / app-resume hook. Pure refetch — no mutation.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final invoiceCountControllerProvider =
    AsyncNotifierProvider<InvoiceCountController, int>(
      InvoiceCountController.new,
    );

/// Real count of persisted customers. Reuses the existing
/// [GetCustomersUseCase] — `getCustomers()` already returns every row,
/// so the count is its list length.
class CustomerCountController extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final result = await ref.read(getCustomersUseCaseProvider)();
    final customers = result.fold((failure) => throw failure, (list) => list);
    return customers.length;
  }

  /// Pull-to-refresh / app-resume hook. Pure refetch — no mutation.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final customerCountControllerProvider =
    AsyncNotifierProvider<CustomerCountController, int>(
      CustomerCountController.new,
    );

/// Real count of persisted services (all customers). A service is counted
/// independently of invoices — a service may exist without an invoice.
class ServiceCountController extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final result = await ref.read(getServiceCountUseCaseProvider)();
    return result.fold((failure) => throw failure, (count) => count);
  }

  /// Pull-to-refresh / app-resume hook. Pure refetch — no mutation.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final serviceCountControllerProvider =
    AsyncNotifierProvider<ServiceCountController, int>(
      ServiceCountController.new,
    );
