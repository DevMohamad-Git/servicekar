import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';

import '../failures/service_failure.dart';
import '../repositories/service_repository.dart';

/// Lookup a single [ServiceEntity] by id. Returns
/// [ServiceNotFoundFailure] when the record is absent.
///
/// Symmetric with [GetCustomerByIdUseCase] in the customer feature:
///   * `id` must be non-empty (defensive trim-check even though the
///     repository accepts any string).
///   * Everything else delegates to the repository; no extra validation
///     is added at the use-case layer because there is no input that
///     could become invalid once on the wire.
class GetServiceByIdUseCase {
  const GetServiceByIdUseCase(this._repository);

  final ServiceRepository _repository;

  Future<Either<ServiceFailure, ServiceEntity>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(
        const Left(
          ServiceValidationFailure(
            field: 'id',
            message: 'Service id is required.',
          ),
        ),
      );
    }
    return _repository.getServiceById(id);
  }
}
