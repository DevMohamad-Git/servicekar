import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';

import '../failures/service_failure.dart';
import '../repositories/service_repository.dart';
import '../value_models/service_operation_outcome.dart';
import 'params/register_service_params.dart';

/// Persist a brand-new [ServiceEntity] for an existing customer.
///
/// ─── Business rules (enforced here, NOT in the widget) ───────────────
/// 1. **Customer must exist.** The use case asks [CustomerRepository]
///    for the referenced row before delegating to [ServiceRepository].
///    A missing customer returns [ServiceCustomerMissingFailure] —
///    never [ServiceValidationFailure], because the input itself is
///    syntactically valid; the *referenced* row is the problem.
/// 2. **Title cannot be empty.** Trimmed-check. Empty / whitespace
///    rejected with [ServiceValidationFailure].
/// 3. **Amount cannot be negative.** Strict `< 0` rejection; `0.0` is
///    accepted (warranty / free service cases per the task brief).
/// 4. **Future `startedAt` produces a warning, not a failure.** The
///    service is still persisted; the warning rides along inside
///    [ServiceOperationOutcome.warnings] so the presentation layer can
///    surface a confirm-before-save dialog without blocking.
///
/// Why a [ServiceOperationOutcome] rather than `ServiceEntity`:
/// the brief says warnings are non-fatal. Returning a wrapper gives
/// callers a single value to check — `Right(outcome)` — instead of a
/// branch on `Left` vs `Right-with-warning-attached`.
class RegisterServiceUseCase {
  const RegisterServiceUseCase({
    required ServiceRepository serviceRepository,
    required CustomerRepository customerRepository,
  }) : _serviceRepository = serviceRepository,
       _customerRepository = customerRepository;

  final ServiceRepository _serviceRepository;
  final CustomerRepository _customerRepository;

  Future<Either<ServiceFailure, ServiceOperationOutcome>> call(
    RegisterServiceParams params,
  ) async {
    if (params.id.trim().isEmpty) {
      return const Left(
        ServiceValidationFailure(
          field: 'id',
          message: 'Service id is required.',
        ),
      );
    }
    // ── (2) Title must be non-empty ─────────────────────────────────────
    if (params.title.trim().isEmpty) {
      return const Left(
        ServiceValidationFailure(field: 'title', message: 'Title is required.'),
      );
    }
    if (params.customerUuid.trim().isEmpty) {
      return const Left(
        ServiceValidationFailure(
          field: 'customerUuid',
          message: 'Customer id is required.',
        ),
      );
    }
    // ── (3) Price must be ≥ 0 (zero is allowed) ─────────────────────────
    if (params.price < 0.0) {
      return const Left(
        ServiceValidationFailure(
          field: 'price',
          message: 'Price cannot be negative.',
        ),
      );
    }

    // ── (1) Customer must exist ─────────────────────────────────────────
    final customerCheck = await _customerRepository.getCustomerById(
      params.customerUuid,
    );
    if (customerCheck.isLeft) {
      final failure =
          (customerCheck as Left<CustomerFailure, CustomerEntity>).value;
      final reason = failure is CustomerNotFoundFailure
          ? 'notFound'
          : 'lookupFailed';
      return Left(
        ServiceCustomerMissingFailure(
          customerUuid: params.customerUuid,
          reason: reason,
        ),
      );
    }

    // Build the entity — keep the caller-generated uuid so the data
    // layer's `replace: true` upsert mirrors the customer pattern.
    final now = DateTime.now();
    final entity = ServiceEntity(
      id: params.id,
      customerUuid: params.customerUuid,
      title: params.title.trim(),
      description: params.description,
      status: params.status,
      // (3) Zero price is intentionally preserved here.
      price: params.price,
      tags: List<String>.unmodifiable(params.tags),
      startedAt: params.startedAt,
      // createdAt / updatedAt remain null at this layer — the
      // repository's `_readBack` round-trip would lose them anyway
      // because today's data layer doesn't auto-stamp. This matches
      // the customer feature's same scoped pattern.
      createdAt: null,
      updatedAt: null,
    );

    // Delegate to the repository; capture the storage Either so we can
    // attach the (4) warning before returning. The warning detection
    // lives on [ServiceOperationOutcome.withDetectedWarnings] so the
    // register and update use cases share one source of truth.
    final result = await _serviceRepository.createService(entity);
    return result.fold(
      (failure) => Left<ServiceFailure, ServiceOperationOutcome>(failure),
      (service) => Right<ServiceFailure, ServiceOperationOutcome>(
        ServiceOperationOutcome.withDetectedWarnings(
          service: service,
          now: now,
        ),
      ),
    );
  }
}
