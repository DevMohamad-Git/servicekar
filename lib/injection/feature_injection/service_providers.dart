import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/customer/domain/entities/service_entity.dart';
import '../../../features/service/data/datasources/local/service_local_datasource.dart';
import '../../../features/service/data/datasources/local/service_local_datasource_impl.dart';
import '../../../features/service/data/repositories/service_repository_impl.dart';
import '../../../features/service/domain/failures/service_failure.dart';
import '../../../features/service/domain/repositories/service_repository.dart';
import '../../../features/service/domain/usecases/delete_service_usecase.dart';
import '../../../features/service/domain/usecases/get_customer_services_usecase.dart';
import '../../../features/service/domain/usecases/get_service_by_id_usecase.dart';
import '../../../features/service/domain/usecases/params/register_service_params.dart';
import '../../../features/service/domain/usecases/params/update_service_params.dart';
import '../../../features/service/domain/usecases/register_service_usecase.dart';
import '../../../features/service/domain/usecases/update_service_usecase.dart';
import '../../../features/service/domain/value_models/service_operation_outcome.dart';
import '../global_providers.dart';
import 'customer_providers.dart';

/// Service feature — Riverpod bindings
/// ===================================
/// Codegen (`@Riverpod(keepAlive: true)`) cannot run in the sandbox
/// (no `pub.dev` access), so this file uses the manual Riverpod 3.x
/// API. The repositories, datasources, and every use-case provider
/// here are plain `Provider`s whose only listeners are the
/// controllers below — Riverpod disposes them only when the
/// container itself is disposed.
///
/// ─── Layer ownership ───────────────────────────────────────────────
/// This file is the SOLE owner of every Riverpod provider for the
/// service feature. The data layer's `service_local_datasource_impl.dart`
/// is now provider-free — it only contains datasource logic and the
/// mapper glue. That keeps the Clean Architecture rule that:
///
///   * **DataSource implementation**: contains only datasource logic.
///   * **Feature injection**: contains all Riverpod providers.
///
/// Putting a provider inside the data impl layer caused every
/// cross-feature wiring (repository → datasource, repository → use
/// cases) to live in the wrong place and risked duplicate
/// `ServiceLocalDataSource` bindings. Centralising here prevents
/// that drift.

/// Display-side wrapper returned by write controllers.
/// ───────────────────────────────────────────────────

/// UI-facing result of a register/update use case call. Carries the
/// underlying use-case failure on the error side, or the
/// [ServiceOperationOutcome] (which itself contains the just-persisted
/// service **plus** any soft warnings the use case attached — e.g.
/// `startedAt is in the future`) on the success side.
///
/// Distinct from a raw `Either<ServiceFailure, ServiceOperationOutcome>`
/// so UI code never has to unpack the Either chain itself; it just
/// reads `outcome.failureMessage` / `outcome.service` / `outcome.warnings`.
///
/// Why a value class rather than re-exporting `Either`: keeping the
/// Riverpod-friendly surface here lets the use-case / domain layer
/// stay free of any UI-shape concern.
class ServiceWriteOutcome {
  const ServiceWriteOutcome._({required this.failure, required this.outcome});

  /// Non-null when the write failed. Null on success.
  final ServiceFailure? failure;

  /// Non-null when the write succeeded (may still carry warnings).
  final ServiceOperationOutcome? outcome;

  bool get succeeded => outcome != null;
  bool get failed => failure != null;

  /// Convenience for callers that only want a single string to toast.
  /// Returns `null` on success so a `if (msg != null)` check is enough.
  String? get failureMessage => failure?.message;

  /// Convenience: the just-persisted entity, or `null` on failure.
  ServiceEntity? get service => outcome?.service;

  /// Convenience: soft warnings emitted by the use case (e.g. future
  /// `startedAt`). Empty list on failure or on a clean success.
  List<ServiceValidationWarning> get warnings =>
      outcome?.warnings ?? const <ServiceValidationWarning>[];

  factory ServiceWriteOutcome.ok(ServiceOperationOutcome outcome) =>
      ServiceWriteOutcome._(failure: null, outcome: outcome);

  factory ServiceWriteOutcome.err(ServiceFailure failure) =>
      ServiceWriteOutcome._(failure: failure, outcome: null);
}

// ─── Data seam ────────────────────────────────────────────────────────
// The single canonical `ServiceLocalDataSource` provider. Reads the
// global [isarInstanceProvider] (overridden at bootstrap by
// `configureDependencies()`) so the datasource never knows about its
// own lifecycle — that's purely a wiring concern.
final serviceLocalDataSourceProvider = Provider<ServiceLocalDataSource>(
  (ref) => ServiceLocalDataSourceImpl(ref.watch(isarInstanceProvider)),
);

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepositoryImpl(
    localDataSource: ref.watch(serviceLocalDataSourceProvider),
  ),
);

// ─── Use cases ────────────────────────────────────────────────────────
final registerServiceUseCaseProvider = Provider<RegisterServiceUseCase>(
  (ref) => RegisterServiceUseCase(
    serviceRepository: ref.watch(serviceRepositoryProvider),
    // Cross-feature dep: the service feature asks the customer
    // feature whether the FK resolves to a live row. We pull the
    // existing `customerRepositoryProvider` rather than re-wiring
    // the customer repository here so the customer feature remains
    // the single source of truth on customer existence.
    customerRepository: ref.watch(customerRepositoryProvider),
  ),
);

final updateServiceUseCaseProvider = Provider<UpdateServiceUseCase>(
  (ref) => UpdateServiceUseCase(ref.watch(serviceRepositoryProvider)),
);

final deleteServiceUseCaseProvider = Provider<DeleteServiceUseCase>(
  (ref) => DeleteServiceUseCase(ref.watch(serviceRepositoryProvider)),
);

final getServiceByIdUseCaseProvider = Provider<GetServiceByIdUseCase>(
  (ref) => GetServiceByIdUseCase(ref.watch(serviceRepositoryProvider)),
);

final getCustomerServicesUseCaseProvider = Provider<GetCustomerServicesUseCase>(
  (ref) => GetCustomerServicesUseCase(ref.watch(serviceRepositoryProvider)),
);

// ─── Controllers ──────────────────────────────────────────────────────

/// Async state for a single customer's service list. UI watches
/// `ref.watch(customerServicesControllerProvider(customerUuid))`.
/// Mirrors the customer feature's [CustomerDetailsController] pattern:
/// `AsyncNotifier<T>` base + the family key captured in the constructor.
class CustomerServicesController extends AsyncNotifier<List<ServiceEntity>> {
  CustomerServicesController(this.customerUuid);

  final String customerUuid;

  @override
  Future<List<ServiceEntity>> build() async {
    final useCase = ref.watch(getCustomerServicesUseCaseProvider);
    final result = await useCase(customerUuid);
    return result.fold((failure) => throw failure, (services) => services);
  }

  /// Pull-to-refresh / retry hook. Pure refetch — no mutation.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final customerServicesControllerProvider =
    AsyncNotifierProvider.family<
      CustomerServicesController,
      List<ServiceEntity>,
      String
    >(CustomerServicesController.new);

/// Family-keyed state for a single service. UI reads
/// `serviceDetailsControllerProvider(id)`. Mirrors the customer's
/// [CustomerDetailsController] constructor-pattern exactly.
class ServiceDetailsController extends AsyncNotifier<ServiceEntity> {
  ServiceDetailsController(this.serviceId);

  final String serviceId;

  @override
  Future<ServiceEntity> build() async {
    final useCase = ref.watch(getServiceByIdUseCaseProvider);
    final result = await useCase(serviceId);
    return result.fold((failure) => throw failure, (service) => service);
  }
}

final serviceDetailsControllerProvider =
    AsyncNotifierProvider.family<
      ServiceDetailsController,
      ServiceEntity,
      String
    >(ServiceDetailsController.new);

/// Controller exposing the register-service intent. Returns a
/// [ServiceWriteOutcome] so the UI gets the persisted entity **and**
/// the soft warnings on success, or a typed failure on error.
class RegisterServiceController extends Notifier<void> {
  @override
  void build() {}

  Future<ServiceWriteOutcome> submit(RegisterServiceParams params) async {
    final useCase = ref.read(registerServiceUseCaseProvider);
    final result = await useCase(params);
    final outcome = result.fold(
      (failure) => ServiceWriteOutcome.err(failure),
      (success) => ServiceWriteOutcome.ok(success),
    );
    if (outcome.succeeded) {
      // Live persistence: the list-scoped controller for this customer
      // and the per-id details controller both need to refetch so the
      // UI shows the new row immediately on the next read.
      ref.invalidate(customerServicesControllerProvider(params.customerUuid));
      final svc = outcome.service;
      if (svc != null) {
        ref.invalidate(serviceDetailsControllerProvider(svc.id));
      }
    }
    return outcome;
  }
}

final registerServiceControllerProvider =
    NotifierProvider<RegisterServiceController, void>(
      RegisterServiceController.new,
    );

/// Controller exposing the update-service intent. Returns a
/// [ServiceWriteOutcome] for parity with [RegisterServiceController].
class UpdateServiceController extends Notifier<void> {
  @override
  void build() {}

  Future<ServiceWriteOutcome> submit(UpdateServiceParams params) async {
    final useCase = ref.read(updateServiceUseCaseProvider);
    final result = await useCase(params);
    final outcome = result.fold(
      (failure) => ServiceWriteOutcome.err(failure),
      (success) => ServiceWriteOutcome.ok(success),
    );
    if (outcome.succeeded) {
      ref.invalidate(customerServicesControllerProvider(params.customerUuid));
      ref.invalidate(serviceDetailsControllerProvider(params.id));
    }
    return outcome;
  }
}

final updateServiceControllerProvider =
    NotifierProvider<UpdateServiceController, void>(
      UpdateServiceController.new,
    );

/// Controller exposing the delete-service intent. Returns `null`
/// on success or a failure message string on failure (mirrors the
/// customer feature's `DeleteCustomerController`).
class DeleteServiceController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(String id) async {
    final useCase = ref.read(deleteServiceUseCaseProvider);
    final result = await useCase(id);
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final deleteServiceControllerProvider =
    NotifierProvider<DeleteServiceController, void>(
      DeleteServiceController.new,
    );
