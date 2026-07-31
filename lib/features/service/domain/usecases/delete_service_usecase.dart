import 'package:servicar/core/utils/either.dart';

import '../failures/service_failure.dart';
import '../repositories/service_repository.dart';

/// Permanently remove a service. The implementation may soft-delete
/// instead, but the contract exposes pure deletion from the caller's
/// POV.
///
/// `id` is required; an empty / whitespace string is treated as
/// [ServiceValidationFailure] for symmetry with the customer id
/// validator ([DeleteCustomerUseCase]).
class DeleteServiceUseCase {
  const DeleteServiceUseCase(this._repository);

  final ServiceRepository _repository;

  Future<Either<ServiceFailure, Unit>> call(String id) {
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
    return _repository.deleteService(id);
  }
}
