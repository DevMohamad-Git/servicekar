import 'package:servicar/core/utils/either.dart';

import '../entities/customer_entity.dart';
import '../failures/customer_failure.dart';
import '../repositories/customer_repository.dart';

/// Lookup a single [CustomerEntity] by id. Returns
/// [CustomerNotFoundFailure] when the record is absent.
class GetCustomerByIdUseCase {
  const GetCustomerByIdUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<CustomerFailure, CustomerEntity>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(
        const Left(
          CustomerValidationFailure(
            field: 'id',
            message: 'Customer id is required.',
          ),
        ),
      );
    }
    return _repository.getCustomerById(id);
  }
}
