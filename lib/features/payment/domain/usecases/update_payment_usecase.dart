import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/payment_entity.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../invoice/domain/repositories/invoice_repository.dart';
import '../failures/payment_failure.dart';
import '../repositories/payment_repository.dart';
import 'params/update_payment_params.dart';

/// Replace an existing payment record by [PaymentEntity.id].
///
/// Validation mirrors [RegisterPaymentUseCase]:
///   * `id` required (otherwise nothing to look up).
///   * `amount` must be `≥ 0` (zero allowed).
///   * `paidAt` must be present and not in the future.
///   * When `invoiceUuid` is non-null, the referenced invoice
///     must exist; null is still allowed (re-detaching a payment
///     from its invoice).
///
/// Customer-existence is NOT re-verified here — the original
/// register already gated on that. Update accepts the existing FK
/// verbatim so renaming / re-categorization flows stay in
/// register / explicit re-assign use cases. If a future caller
/// truly wants re-parent verification, that moves into a
/// dedicated `ReassignPaymentUseCase`.
class UpdatePaymentUseCase {
  const UpdatePaymentUseCase({
    required PaymentRepository paymentRepository,
    required CustomerRepository customerRepository,
    required InvoiceRepository invoiceRepository,
  }) : _paymentRepository = paymentRepository,
       _customerRepository = customerRepository,
       _invoiceRepository = invoiceRepository;

  final PaymentRepository _paymentRepository;

  // Kept on the constructor so the wiring is symmetric with
  // RegisterPaymentUseCase; not used in the gate today because
  // update trusts the FK set at register time.
  // ignore: unused_field
  final CustomerRepository _customerRepository;
  final InvoiceRepository _invoiceRepository;

  Future<Either<PaymentFailure, PaymentEntity>> call(
    UpdatePaymentParams params,
  ) async {
    if (params.id.trim().isEmpty) {
      return const Left(
        PaymentValidationFailure(
          field: 'id',
          message: 'Payment id is required for updates.',
        ),
      );
    }
    if (params.amount.isNaN) {
      return const Left(
        PaymentValidationFailure(
          field: 'amount',
          message: 'Payment amount must be a finite number.',
        ),
      );
    }
    if (params.amount < 0.0) {
      return const Left(
        PaymentValidationFailure(
          field: 'amount',
          message: 'Payment amount cannot be negative.',
        ),
      );
    }
    if (params.paidAt.isAfter(DateTime.now())) {
      return const Left(
        PaymentValidationFailure(
          field: 'paidAt',
          message: 'Payment date cannot be in the future.',
        ),
      );
    }
    if (params.invoiceUuid != null && params.invoiceUuid!.isEmpty) {
      return const Left(
        PaymentValidationFailure(
          field: 'invoiceUuid',
          message:
              'Invoice id is required when invoiceUuid is supplied '
              '(empty string is not accepted).',
        ),
      );
    }

    // Optional invoice-presence re-validation on update. Mirrors
    // the "customer-presence is NOT re-verified" policy from the
    // service-update use case: at register-time we verified the
    // FK, so update trusts it. BUT for invoiceUuid the rule is
    // tighter because today the parent-collection FK enforcement
    // is unbaked — we re-verify on every mutation to keep dangling
    // pointers out of the DB.
    if (params.invoiceUuid != null) {
      final invoiceCheck = await _invoiceRepository.getById(
        params.invoiceUuid!,
      );
      if (invoiceCheck.isLeft) {
        final failure =
            (invoiceCheck as Left<InvoiceFailure, InvoiceEntity>).value;
        final reason = failure is InvoiceNotFoundFailure
            ? 'notFound'
            : 'lookupFailed';
        return Left(
          PaymentInvoiceMissingFailure(
            invoiceUuid: params.invoiceUuid!,
            reason: reason,
          ),
        );
      }
    }

    final entity = PaymentEntity(
      id: params.id,
      customerUuid: params.customerUuid,
      invoiceUuid: params.invoiceUuid,
      amount: params.amount,
      paidAt: params.paidAt,
      method: params.method,
      note: params.note,
      createdAt: null,
      updatedAt: null,
    );

    final result = await _paymentRepository.updatePayment(entity);
    return result.fold(
      (failure) => Left<PaymentFailure, PaymentEntity>(failure),
      (payment) => Right<PaymentFailure, PaymentEntity>(payment),
    );
  }
}
