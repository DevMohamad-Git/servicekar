import 'package:servicar/core/utils/either.dart';

import '../entities/customer_entity.dart';
import '../failures/customer_failure.dart';
import '../repositories/customer_repository.dart';

/// Run a fuzzy/full-text search over customer fields. Empty queries
/// fall back to "give me everyone" via [GetCustomersUseCase] so the
/// search bar never produces an empty page unexpectedly.
class SearchCustomersUseCase {
  const SearchCustomersUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<CustomerFailure, List<CustomerEntity>>> call(
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _repository.getCustomers();
    }
    return _repository.searchCustomers(trimmed);
  }
}
