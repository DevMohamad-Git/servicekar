import 'package:servicar/core/utils/either.dart';

import '../entities/customer_entity.dart';
import '../failures/customer_failure.dart';
import '../repositories/customer_repository.dart';

/// Persist a new [CustomerEntity]. Validates mandatory inputs before
/// delegating to the repository so we never write garbage to storage.
///
/// TODO: tighten validation (E.164 phone normalization, email regex,
///       duplicate phone detection) once the validator spec is signed off.
class CreateCustomerUseCase {
  const CreateCustomerUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<CustomerFailure, CustomerEntity>> call(
    CustomerEntity customer,
  ) async {
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

    return _repository.createCustomer(customer);
  }
}
