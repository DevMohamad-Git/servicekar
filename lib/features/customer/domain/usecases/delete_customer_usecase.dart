import 'package:servicar/core/utils/either.dart';

import '../failures/customer_failure.dart';
import '../repositories/customer_repository.dart';

/// Permanently remove a customer. The implementation may soft-delete
/// instead, but the contract exposes pure deletion from the caller's POV.
class DeleteCustomerUseCase {
  const DeleteCustomerUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<CustomerFailure, Unit>> call(String id) {
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
    return _repository.deleteCustomer(id);
  }
}
