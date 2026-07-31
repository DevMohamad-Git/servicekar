import 'package:servicar/core/utils/either.dart';
import '../failures/service_failure.dart';
import '../repositories/service_repository.dart';
import '../value_models/service_operation_outcome.dart';
import 'params/update_service_params.dart';

/// Replace an existing service record by [ServiceEntity.id].
///
/// Validation mirrors [RegisterServiceUseCase]:
///   * `id` required (otherwise nothing to look up).
///   * `title` non-empty after trimming.
///   * `price` must be ≥ 0 (zero allowed).
///   * future-dated `startedAt` becomes a *warning*, not a failure.
///
/// Customer-existence is NOT re-verified here — the original register
/// already gated on that. Update accepts the existing FK verbatim so
/// re-parenting flows remain in dedicated use cases (not on this one).
/// If a caller truly wants re-parent verification, future work moves
/// that into an explicit `ReassignServiceUseCase`.
class UpdateServiceUseCase {
  const UpdateServiceUseCase(this._repository);

  final ServiceRepository _repository;

  Future<Either<ServiceFailure, ServiceOperationOutcome>> call(
    UpdateServiceParams params,
  ) async {
    if (params.id.trim().isEmpty) {
      return const Left(
        ServiceValidationFailure(
          field: 'id',
          message: 'Service id is required for updates.',
        ),
      );
    }
    if (params.title.trim().isEmpty) {
      return const Left(
        ServiceValidationFailure(field: 'title', message: 'Title is required.'),
      );
    }
    if (params.price < 0.0) {
      return const Left(
        ServiceValidationFailure(
          field: 'price',
          message: 'Price cannot be negative.',
        ),
      );
    }

    final now = DateTime.now();
    final entity = ServiceEntity(
      id: params.id,
      customerUuid: params.customerUuid,
      title: params.title.trim(),
      status: params.status,
      price: params.price,
      description: params.description,
      tags: List<String>.unmodifiable(params.tags),
      startedAt: params.startedAt,
      completedAt: params.completedAt,
      createdAt: null,
      updatedAt: null,
    );

    final result = await _repository.updateService(entity);
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
