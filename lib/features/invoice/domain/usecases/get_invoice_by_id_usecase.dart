import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/invoice_entity.dart';
import '../failures/invoice_failure.dart';
import '../repositories/invoice_repository.dart';

/// Lookup a single [InvoiceEntity] by id. Returns
/// [InvoiceNotFoundFailure] when the record is absent.
///
/// Symmetric with `GetServiceByIdUseCase` / `GetPaymentByIdUseCase`
/// — the use case contains the *only* defensive validation (id is
/// non-empty). Everything else delegates to the repository.
class GetInvoiceByIdUseCase {
  const GetInvoiceByIdUseCase(this._repository);

  final InvoiceRepository _repository;

  Future<Either<InvoiceFailure, InvoiceEntity>> call(String id) {
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
    return _repository.getById(id);
  }
}
