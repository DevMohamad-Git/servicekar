import 'package:servicar/core/utils/either.dart';

import '../failures/customer_failure.dart';
import '../repositories/customer_repository.dart';

/// Read-only projection returning only the customer's current balance.
/// Useful for dashboards / list tiles that should not pay the cost of
/// hydrating the full [CustomerEntity].
class GetCustomerBalanceUseCase {
  const GetCustomerBalanceUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<CustomerFailure, double>> call(String id) {
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
    return _repository.getCustomerBalance(id);
  }
}
