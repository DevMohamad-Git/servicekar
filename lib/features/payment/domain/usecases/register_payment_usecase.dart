import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/customer_entity.dart';
import '../../../customer/domain/entities/payment_entity.dart';
import '../../../customer/domain/failures/customer_failure.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../invoice/domain/repositories/invoice_repository.dart';
import '../failures/payment_failure.dart';
import '../repositories/payment_repository.dart';
import 'params/register_payment_params.dart';

/// Persist a brand-new [PaymentEntity] for an existing customer.
///
/// ─── Business rules (enforced here, NOT in widgets) ─────────────
/// 1. **Customer must exist.** The use case asks
///    [CustomerRepository] for the referenced row before
///    delegating to [PaymentRepository]. A missing customer
///    returns [PaymentCustomerMissingFailure] — never
///    [PaymentValidationFailure], because the input itself is
///    syntactically valid; the *referenced* row is the problem.
/// 2. **Invoice (when supplied) must exist.** Optional FK by
///    design — on-account prepayments keep `invoiceUuid == null`.
///    When *non-null*, the use case asks [InvoiceRepository] for
///    the row; missing → [PaymentInvoiceMissingFailure].
/// 3. **`amount` must be ≥ 0.** Strict `< 0` rejection; `0.0`
///    accepted (complimentary / write-off case). Overpayment is
///    allowed — the balance derivation will surface it as
///    `creditor`, the write itself is not rejected.
/// 4. **`paidAt` must be valid.** Non-null AND
///    `!paidAt.isAfter(now)` — the timestamp may be in the past
///    (normal backfill case) or exactly-now (clock skew tolerance
///    of zero). Strict future dates are rejected with
///    [PaymentValidationFailure].
/// 5. **`method` is constrained to [PaymentMethod.values].** The
///    enum is closed — the parameter is typed `PaymentMethod`
///    directly so the use case cannot be called with an unknown
///    wire value at compile time.
///
/// Validation order: cheap field checks first (return early),
/// then FK existence checks, then delegation. This keeps the
/// "storage didn't even get called" contract snappy on the
/// happy path.
class RegisterPaymentUseCase {
  const RegisterPaymentUseCase({
    required PaymentRepository paymentRepository,
    required CustomerRepository customerRepository,
    required InvoiceRepository invoiceRepository,
  }) : _paymentRepository = paymentRepository,
       _customerRepository = customerRepository,
       _invoiceRepository = invoiceRepository;

  final PaymentRepository _paymentRepository;
  final CustomerRepository _customerRepository;
  final InvoiceRepository _invoiceRepository;

  Future<Either<PaymentFailure, PaymentEntity>> call(
    RegisterPaymentParams params,
  ) async {
    // ── (a) Cheap field validation — fail fast ────────────────
    if (params.id.trim().isEmpty) {
      return const Left(
        PaymentValidationFailure(
          field: 'id',
          message: 'Payment id is required.',
        ),
      );
    }
    if (params.customerUuid.trim().isEmpty) {
      return const Left(
        PaymentValidationFailure(
          field: 'customerUuid',
          message: 'Customer id is required.',
        ),
      );
    }
    if (params.amount.isNaN) {
      // Defensive: Isar stores `late double` so we should never
      // see NaN; reject with field=amount to match the failure
      // shape used by the other validators.
      return const Left(
        PaymentValidationFailure(
          field: 'amount',
          message: 'Payment amount must be a finite number.',
        ),
      );
    }
    // ── (3) amount ≥ 0 (zero is allowed for write-off) ──────
    if (params.amount < 0.0) {
      return const Left(
        PaymentValidationFailure(
          field: 'amount',
          message: 'Payment amount cannot be negative.',
        ),
      );
    }
    // ── (4) paidAt is present + not in the future ───────────
    if (params.paidAt.isAfter(DateTime.now())) {
      return const Left(
        PaymentValidationFailure(
          field: 'paidAt',
          message: 'Payment date cannot be in the future.',
        ),
      );
    }
    if (params.invoiceUuid != null && (params.invoiceUuid!.isEmpty)) {
      // Treat empty string as "explicitly missing rather than
      // accidental null" — fail loud instead of silently
      // re-interpreting the null option.
      return const Left(
        PaymentValidationFailure(
          field: 'invoiceUuid',
          message:
              'Invoice id is required when invoiceUuid is supplied '
              '(empty string is not accepted).',
        ),
      );
    }

    // ── (1) Customer must exist ──────────────────────────────
    final customerCheck = await _customerRepository.getCustomerById(
      params.customerUuid,
    );
    if (customerCheck.isLeft) {
      final failure =
          (customerCheck as Left<CustomerFailure, CustomerEntity>).value;
      final reason = failure is CustomerNotFoundFailure
          ? 'notFound'
          : 'lookupFailed';
      return Left(
        PaymentCustomerMissingFailure(
          customerUuid: params.customerUuid,
          reason: reason,
        ),
      );
    }

    // ── (2) Invoice must exist (when supplied) ──────────────
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

    // Build the entity. `createdAt` / `updatedAt` stay null at
    // this boundary — the repository's `_readBack` round-trip
    // drops them anyway because today's data layer doesn't
    // auto-stamp. Matching the customer / service pattern.
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

    final result = await _paymentRepository.createPayment(entity);
    return result.fold(
      (failure) => Left<PaymentFailure, PaymentEntity>(failure),
      (payment) => Right<PaymentFailure, PaymentEntity>(payment),
    );
  }
}
