import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';

import '../failures/service_failure.dart';
import '../repositories/service_repository.dart';

/// Return every [ServiceEntity] belonging to the customer [customerUuid].
///
/// Empty list is returned as a "successful empty" — NOT a
/// [ServiceNotFoundFailure]. This matches the customer feature's
/// `GetCustomersUseCase` policy so the presentation layer can render
/// an empty-state widget without a special error branch.
///
/// The `customerUuid` is required; an empty string is treated as a
/// [ServiceValidationFailure] for symmetry with the customer UUID
/// validators.
class GetCustomerServicesUseCase {
  const GetCustomerServicesUseCase(this._repository);

  final ServiceRepository _repository;

  Future<Either<ServiceFailure, List<ServiceEntity>>> call(
    String customerUuid,
  ) {
    if (customerUuid.trim().isEmpty) {
      return Future.value(
        const Left(
          ServiceValidationFailure(
            field: 'customerUuid',
            message: 'Customer id is required.',
          ),
        ),
      );
    }
    return _repository.getServicesByCustomer(customerUuid);
  }
}
