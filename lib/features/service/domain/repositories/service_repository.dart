import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';

import '../failures/service_failure.dart';

/// Contract every Service repository implementation must satisfy.
///
/// Implementations live in `features/service/data/repositories/`. Domain
/// code only ever sees this interface — never the implementation, which
/// lets us swap local/remote or mock the contract in tests without
/// touching business logic.
///
/// Methods return [Future] of [Either] so callers handle failure without
/// `try/catch`. A success of "nothing meaningful" is modelled with
/// [Unit] rather than `void`.
///
/// Mirror of [CustomerRepository] in the customer feature — see that
/// file for the cross-feature rationale on
/// `Either<Failure, T>` and `Unit`.
abstract class ServiceRepository {
  /// Persist a brand-new service. Returns [ServiceCustomerMissingFailure]
  /// when the FK does not resolve to a live customer row, [ServiceValidationFailure]
  /// when input is invalid, [ServiceStorageFailure] on I/O error.
  Future<Either<ServiceFailure, ServiceEntity>> createService(
    ServiceEntity service,
  );

  /// Persist updates to an existing service by [ServiceEntity.id].
  /// Returns [ServiceNotFoundFailure] on a missing id.
  Future<Either<ServiceFailure, ServiceEntity>> updateService(
    ServiceEntity service,
  );

  /// Remove the service with the given [id]. A successful delete yields
  /// [Unit.instance] on the success side.
  Future<Either<ServiceFailure, Unit>> deleteService(String id);

  /// Look up a single service by id. Returns [ServiceNotFoundFailure]
  /// on no match.
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(String id);

  /// Return every service attached to the customer with [customerUuid],
  /// ordered by [ServiceEntity.startedAt] descending (nulls last).
  /// Empty list on no matches — does not raise [ServiceNotFoundFailure].
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String customerUuid,
  );

  /// Total number of persisted services across all customers.
  /// Zero rows is a successful `0` — never a failure. Feeds the
  /// dashboard's "registered services" KPI via a single
  /// constant-time count rather than hydrating every entity.
  Future<Either<ServiceFailure, int>> getServiceCount();
}
