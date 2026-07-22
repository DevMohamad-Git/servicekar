import 'package:servicar/core/utils/either.dart';

import '../entities/customer_entity.dart';
import '../failures/customer_failure.dart';
import '../repositories/customer_repository.dart';

/// Stream-ish / fan-out version: return every customer known to the
/// repository in one shot. Pagination belongs in the repository itself.
class GetCustomersUseCase {
  const GetCustomersUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<CustomerFailure, List<CustomerEntity>>> call() =>
      _repository.getCustomers();
}
