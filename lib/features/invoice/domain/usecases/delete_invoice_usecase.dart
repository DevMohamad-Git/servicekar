import 'package:servicar/core/utils/either.dart';

import '../failures/invoice_failure.dart';
import '../repositories/invoice_repository.dart';

/// Permanently remove an invoice. The implementation may soft-delete
/// later, but the contract exposes pure deletion from the caller's
/// POV.
///
/// `id` is required; an empty / whitespace string is treated as
/// [InvoiceValidationFailure] for symmetry with the customer /
/// service id validators.
class DeleteInvoiceUseCase {
  const DeleteInvoiceUseCase(this._repository);

  final InvoiceRepository _repository;

  Future<Either<InvoiceFailure, Unit>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(
        const Left(
          InvoiceValidationFailure(
            field: 'id',
            message: 'Invoice id is required.',
          ),
        ),
      );
    }
    return _repository.deleteInvoice(id);
  }
}
