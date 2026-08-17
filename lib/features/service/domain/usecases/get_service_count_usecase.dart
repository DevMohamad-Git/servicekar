import 'package:servicar/core/utils/either.dart';

import '../failures/service_failure.dart';
import '../repositories/service_repository.dart';

/// Return the total number of persisted services across all customers.
///
/// Pure read-only count backing the dashboard's "سرویس‌های ثبت‌شده" KPI.
/// Zero rows is a successful `0` — never a [ServiceNotFoundFailure].
///
/// A service is intentionally counted independently from invoices: a
/// service may exist without any invoice, so this count is never derived
/// from the invoice collection.
///
/// Unlike the per-customer reads, there is no input to validate, so the
/// use case is a straight delegation to the repository's single
/// constant-time count.
class GetServiceCountUseCase {
  const GetServiceCountUseCase(this._repository);

  final ServiceRepository _repository;

  Future<Either<ServiceFailure, int>> call() => _repository.getServiceCount();
}
