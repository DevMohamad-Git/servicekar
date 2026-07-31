import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/invoice_entity.dart';
import '../failures/invoice_failure.dart';
import '../repositories/invoice_repository.dart';

/// Return every [InvoiceEntity] belonging to the customer
/// [customerUuid].
///
/// Empty list is returned as a "successful empty" — NOT an
/// [InvoiceNotFoundFailure]. This matches every other "list
/// per-customer" use case so the presentation layer can render an
/// empty-state widget without a special error branch.
///
/// The `customerUuid` is required; an empty string is treated as
/// an [InvoiceValidationFailure] for symmetry with the customer /
/// service uuid validators.
class GetCustomerInvoicesUseCase {
  const GetCustomerInvoicesUseCase(this._repository);

  final InvoiceRepository _repository;

  Future<Either<InvoiceFailure, List<InvoiceEntity>>> call(
    String customerUuid,
  ) {
    if (customerUuid.trim().isEmpty) {
      return Future.value(
        const Left(
          InvoiceValidationFailure(
            field: 'customerUuid',
            message: 'Customer id is required.',
          ),
        ),
      );
    }
    return _repository.getByCustomer(customerUuid);
  }
}
