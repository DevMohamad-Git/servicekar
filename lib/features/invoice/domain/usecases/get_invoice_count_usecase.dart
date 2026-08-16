import 'package:servicar/core/utils/either.dart';

import '../failures/invoice_failure.dart';
import '../repositories/invoice_repository.dart';

/// Return the total number of persisted invoices across all customers.
///
/// Pure read-only count backing the dashboard's "فاکتورهای ثبت‌شده" KPI.
/// Zero rows is a successful `0` — never an [InvoiceNotFoundFailure].
///
/// Unlike the per-customer reads, there is no input to validate, so the
/// use case is a straight delegation to the repository's single
/// constant-time count.
class GetInvoiceCountUseCase {
  const GetInvoiceCountUseCase(this._repository);

  final InvoiceRepository _repository;

  Future<Either<InvoiceFailure, int>> call() => _repository.getInvoiceCount();
}
