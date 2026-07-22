import 'package:servicar/core/utils/either.dart';

import '../entities/customer_entity.dart';
import '../failures/customer_failure.dart';
import '../repositories/customer_repository.dart';

/// Replace an existing customer record by [CustomerEntity.id]. The same
/// validation policy as [CreateCustomerUseCase] is applied so we never
/// persist a half-valid row.
class UpdateCustomerUseCase {
  const UpdateCustomerUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<CustomerFailure, CustomerEntity>> call(
    CustomerEntity customer,
  ) async {
    if (customer.id.trim().isEmpty) {
      return const Left(
        CustomerValidationFailure(
          field: 'id',
          message: 'Customer id is required for updates.',
        ),
      );
    }
    if (customer.fullName.trim().isEmpty) {
      return const Left(
        CustomerValidationFailure(
          field: 'fullName',
          message: 'Full name is required.',
        ),
      );
    }
    if (customer.phoneNumber.trim().isEmpty) {
      return const Left(
        CustomerValidationFailure(
          field: 'phoneNumber',
          message: 'Phone number is required.',
        ),
      );
    }

    return _repository.updateCustomer(customer);
  }
}
