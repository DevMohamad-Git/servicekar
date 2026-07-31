import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/payment_entity.dart';
import '../../../invoice/domain/repositories/invoice_repository.dart';
import '../failures/payment_failure.dart';
import '../repositories/payment_repository.dart';

/// Return every [PaymentEntity] tied to the invoice [invoiceUuid],
/// ordered chronologically (most recent first) via the repository.
///
/// Empty list on no matches — does NOT raise
/// [PaymentNotFoundFailure] (matches the customer / service
/// pattern: an unseen invoice has zero payments, the
/// "missing-list" condition).
///
/// Note: the invoice itself need not exist for this to succeed;
/// the use case is a passthrough over the payments whose
/// `invoiceUuid` matches. The Invoice-row presence is a separate
/// concern handled by the balance derivation and the future full
/// Invoice feature.
class GetInvoicePaymentsUseCase {
  const GetInvoicePaymentsUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<PaymentFailure, List<PaymentEntity>>> call(String invoiceUuid) {
    if (invoiceUuid.trim().isEmpty) {
      return Future.value(
        const Left(
          PaymentValidationFailure(
            field: 'invoiceUuid',
            message: 'Invoice id is required.',
          ),
        ),
      );
    }
    return _repository.getPaymentsByInvoice(invoiceUuid);
  }
}
