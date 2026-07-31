import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/customer_entity.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../domain/entities/balance_status.dart';
import '../../domain/value_models/customer_balance_result.dart';
import '../../domain/failures/balance_failure.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../invoice/domain/repositories/invoice_repository.dart';
import '../../../payment/domain/entities/payment_entity.dart';
import '../../../payment/domain/failures/payment_failure.dart';
import '../../../payment/domain/repositories/payment_repository.dart';

/// Derive a customer's financial balance by summing invoices and
/// payments, then projecting the result into a [BalanceStatus].
///
/// ─── Formula ────────────────────────────────────────────────────
///   `balance = sum(payment.amount) - sum(invoice.totalAmount)`
///
///   * balance > 0  → creditor   (paid MORE than invoiced)
///   * balance == 0 → settled    (each invoice fully covered)
///   * balance < 0  → debtor     (still owes against invoices)
///
/// ─── Flow ───────────────────────────────────────────────────────
///   customerUuid → Customer (gate)
///                → InvoiceRepository.getByCustomer  → sum totals
///                → PaymentRepository.getPaymentsByCustomer → sum totals
///                → classifier.classify(balance) → status
///                → CustomerBalanceResult
///
/// ─── Rules enforced here ────────────────────────────────────────
/// 1. **Customer must exist.** A missing customer yields
///    [BalanceCustomerUnknownFailure] so the calling UI can
///    show a "no such customer" message distinctly from a
///    transient storage failure.
/// 2. **Overpayment is NOT rejected.** Customer credit is a
///    first-class outcome — the formula can return `balance > 0`
///    without any validation step clipping it. The Status reflects
///    the direction.
/// 3. **No balance stored on Customer / Invoice / Payment.**
///    The derived value lives entirely in the returned
///    [CustomerBalanceResult]; persistent columns stay focused on
///    raw inputs.
///
/// ─── Errors on the Left side ────────────────────────────────────
///   * `BalanceCustomerUnknownFailure` — gate failure.
///   * `BalanceInvoiceLookupFailure`   — Isar threw while reading
///                                        the invoice collection.
///   * `BalancePaymentLookupFailure`   — Isar threw while reading
///                                        the payment collection.
class CalculateCustomerBalanceUseCase {
  const CalculateCustomerBalanceUseCase({
    required CustomerRepository customerRepository,
    required InvoiceRepository invoiceRepository,
    required PaymentRepository paymentRepository,
    BalanceClassifier classifier = const BalanceClassifier(),
  }) : _customerRepository = customerRepository,
       _invoiceRepository = invoiceRepository,
       _paymentRepository = paymentRepository,
       _classifier = classifier;

  final CustomerRepository _customerRepository;
  final InvoiceRepository _invoiceRepository;
  final PaymentRepository _paymentRepository;
  final BalanceClassifier _classifier;

  Future<Either<BalanceFailure, CustomerBalanceResult>> call(
    String customerUuid,
  ) async {
    if (customerUuid.trim().isEmpty) {
      return const Left(BalanceCustomerUnknownFailure(customerUuid: ''));
    }

    // ── gate: customer must exist ───────────────────────────
    final customerCheck = await _customerRepository.getCustomerById(
      customerUuid,
    );
    if (customerCheck.isLeft) {
      // We don't introspect the *underlying* customer failure —
      // the caller already has a richer message coming from the
      // customer detail screen. Balance just says "no such
      // customer" cleanly.
      return Left(BalanceCustomerUnknownFailure(customerUuid: customerUuid));
    }

    // ── invoices: read totals ───────────────────────────────
    final invoiceCheck = await _invoiceRepository.getByCustomer(customerUuid);
    if (invoiceCheck.isLeft) {
      final failure =
          (invoiceCheck as Left<InvoiceFailure, List<InvoiceEntity>>).value;
      return Left(BalanceInvoiceLookupFailure(detail: failure.message));
    }
    final invoices =
        (invoiceCheck as Right<InvoiceFailure, List<InvoiceEntity>>).value;
    // Sum of totalAmount. The model already enforces non-null,
    // but a future "draft invoice with no items" path could
    // emit 0.0 — treat as additive-zero.
    var invoicesTotal = 0.0;
    for (final inv in invoices) {
      invoicesTotal += inv.totalAmount;
    }

    // ── payments: read totals ───────────────────────────────
    final paymentCheck = await _paymentRepository.getPaymentsByCustomer(
      customerUuid,
    );
    if (paymentCheck.isLeft) {
      final failure =
          (paymentCheck as Left<PaymentFailure, List<PaymentEntity>>).value;
      return Left(BalancePaymentLookupFailure(detail: failure.message));
    }
    final payments =
        (paymentCheck as Right<PaymentFailure, List<PaymentEntity>>).value;
    var paymentsTotal = 0.0;
    for (final pmt in payments) {
      paymentsTotal += pmt.amount;
    }

    // ── classify ────────────────────────────────────────────
    final balance = paymentsTotal - invoicesTotal;
    final status = _classifier.classify(balance);

    return Right(
      CustomerBalanceResult(
        customerUuid: customerUuid,
        invoicesTotal: invoicesTotal,
        paymentsTotal: paymentsTotal,
        balance: balance,
        status: status,
        invoiceCount: invoices.length,
        paymentCount: payments.length,
      ),
    );
  }
}
