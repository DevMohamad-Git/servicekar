import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/customer/data/datasources/local/customer_local_datasource_impl.dart';
import '../../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../../features/customer/domain/entities/customer_entity.dart';
import '../../../features/customer/domain/repositories/customer_repository.dart';
import '../../../features/customer/domain/usecases/create_customer_usecase.dart';
import '../../../features/customer/domain/usecases/delete_customer_usecase.dart';
import '../../../features/customer/domain/usecases/get_customer_balance_usecase.dart';
import '../../../features/customer/domain/usecases/get_customer_by_id_usecase.dart';
import '../../../features/customer/domain/usecases/get_customers_usecase.dart';
import '../../../features/customer/domain/usecases/search_customers_usecase.dart';
import '../../../features/customer/domain/usecases/update_customer_usecase.dart';

/// Live-Persistence strategy
/// =========================
/// Codegen (`@Riverpod(keepAlive: true)`) cannot run in the sandbox
/// (no `pub.dev` access), so this file uses the manual Riverpod 3.x
/// API. The cross-screen "live persistence" we still get is:
///   * The app-level `ProviderContainer` is created once in
///     `lib/main.dart` and bound to the widget tree via
///     `UncontrolledProviderScope`. That container outlives every
///     page navigation.
///   * The repository, datasources, and every use-case provider are
///     declared as plain `Provider`s whose only listener is the
///     controllers — Riverpod disposes them only when the container
///     itself is disposed (i.e. never during normal app life).
///   * Controllers that mutate state call `ref.invalidate(...)` on
///     sibling controllers so the UI sees fresh data immediately
///     without an explicit refresh.
///
/// Net effect mirrors Lalafen's `@Riverpod(keepAlive: true)` for the
/// repositories + use cases. Controllers refetch on mount, which is
/// desirable here because they hide upstream DB latency.

// ─── Data seam (extracted from data/ for parity with Lalafen's
//     `features/prompts/providers/...` partition) ──────────────────────────
final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepositoryImpl(
    localDataSource: ref.watch(customerLocalDataSourceProvider),
  ),
);

// ─── Use cases ────────────────────────────────────────────────────────────
final createCustomerUseCaseProvider = Provider<CreateCustomerUseCase>(
  (ref) => CreateCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>(
  (ref) => UpdateCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final deleteCustomerUseCaseProvider = Provider<DeleteCustomerUseCase>(
  (ref) => DeleteCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final getCustomerByIdUseCaseProvider = Provider<GetCustomerByIdUseCase>(
  (ref) => GetCustomerByIdUseCase(ref.watch(customerRepositoryProvider)),
);

final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>(
  (ref) => GetCustomersUseCase(ref.watch(customerRepositoryProvider)),
);

final searchCustomersUseCaseProvider = Provider<SearchCustomersUseCase>(
  (ref) => SearchCustomersUseCase(ref.watch(customerRepositoryProvider)),
);

final getCustomerBalanceUseCaseProvider = Provider<GetCustomerBalanceUseCase>(
  (ref) => GetCustomerBalanceUseCase(ref.watch(customerRepositoryProvider)),
);

// ─── Controllers (Live Persistence: invalidations on mutation) ────────────

/// Async state for the customer list page. UI watches
/// `ref.watch(customerListControllerProvider)`.
class CustomerListController extends AsyncNotifier<List<CustomerEntity>> {
  @override
  Future<List<CustomerEntity>> build() async {
    final useCase = ref.watch(getCustomersUseCaseProvider);
    final result = await useCase();
    // Throwing the [CustomerFailure] lets the page render an
    // [AsyncError] carrying the original failure; the presentation
    // layer translates it to a localized message.
    return result.fold(
      (failure) => throw failure,
      (customers) => customers,
    );
  }

  /// Pull-to-refresh / retry hook. Pure refetch — no mutation.
  Future<void> refresh() async {
    ref.invalidateSelf();
    // Await the next-state so callers can `await refresh()` safely.
    await future;
  }
}

final customerListControllerProvider =
    AsyncNotifierProvider<CustomerListController, List<CustomerEntity>>(
  CustomerListController.new,
);

/// Family-keyed state for a single [CustomerEntity]. UI reads
/// `customerDetailsControllerProvider(id)`.
class CustomerDetailsController extends AsyncNotifier<CustomerEntity> {
  CustomerDetailsController(this.customerId);

  final String customerId;

  @override
  Future<CustomerEntity> build() async {
    final useCase = ref.watch(getCustomerByIdUseCaseProvider);
    final result = await useCase(customerId);
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

/// Controller exposing the create-customer intent. Returns `null` on
/// success or a failure message string on failure.
class CreateCustomerController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit({
    required String id,
    required String fullName,
    required String phoneNumber,
    String? email,
    String? address,
    String? notes,
    List<String> tags = const <String>[],
  }) async {
    final useCase = ref.read(createCustomerUseCaseProvider);
    final result = await useCase(
      CustomerEntity(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        notes: notes,
        tags: tags,
      ),
    );
    if (result.isRight) {
      ref.invalidate(customerListControllerProvider);
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final createCustomerControllerProvider =
    NotifierProvider<CreateCustomerController, void>(
  CreateCustomerController.new,
);

/// Controller exposing the update-customer intent.
class UpdateCustomerController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(CustomerEntity customer) async {
    final useCase = ref.read(updateCustomerUseCaseProvider);
    final result = await useCase(customer);
    if (result.isRight) {
      ref.invalidate(customerListControllerProvider);
      ref.invalidate(customerDetailsControllerProvider(customer.id));
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final updateCustomerControllerProvider =
    NotifierProvider<UpdateCustomerController, void>(
  UpdateCustomerController.new,
);

/// Controller exposing the delete-customer intent. Returns `null`
/// on success or a failure message string on failure.
class DeleteCustomerController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(String id) async {
    final useCase = ref.read(deleteCustomerUseCaseProvider);
    final result = await useCase(id);
    if (result.isRight) {
      ref.invalidate(customerListControllerProvider);
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final deleteCustomerControllerProvider =
    NotifierProvider<DeleteCustomerController, void>(
  DeleteCustomerController.new,
);
