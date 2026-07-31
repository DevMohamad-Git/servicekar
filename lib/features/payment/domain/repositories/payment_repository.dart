import 'package:servicar/core/utils/either.dart';

import '../entities/payment_entity.dart';
import '../failures/payment_failure.dart';

/// Contract every Payment repository implementation must satisfy.
///
/// Implementations live in `features/payment/data/repositories/`.
/// Domain code only ever sees this interface — never the
/// implementation, which lets us swap local/remote or mock the
/// contract in tests without touching business logic.
///
/// Methods return `Future<Either<PaymentFailure, T>>` so callers
/// handle failure without `try/catch`. A success of "nothing
/// meaningful" is modelled with `Unit` rather than `void`.
///
/// Symmetry with [CustomerRepository] / [ServiceRepository] —
/// see those for the cross-feature rationale on Either and
/// `Unit`.
abstract class PaymentRepository {
  /// Persist a brand-new payment. Returns
  /// [PaymentCustomerMissingFailure] when the FK does not resolve,
  /// [PaymentInvoiceMissingFailure] when [PaymentEntity.invoiceUuid]
  /// is non-null but FK-resolve fails,
  /// [PaymentValidationFailure] when the use case rejected the
  /// input, [PaymentStorageFailure] on I/O.
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity payment,
  );

  /// Persist updates to an existing payment by [PaymentEntity.id].
  /// Returns [PaymentNotFoundFailure] on a missing id.
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity payment,
  );

  /// Remove the payment with the given [id]. A successful delete
  /// yields [Unit.instance] on the success side.
  Future<Either<PaymentFailure, Unit>> deletePayment(String id);

  /// Look up a single payment by id. Returns [PaymentNotFoundFailure]
  /// on no match.
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(String id);

  /// Return every payment whose `invoiceUuid == invoiceUuid`,
  /// ordered by [PaymentEntity.paidAt] descending.
  ///
  /// Empty list on no matches — does NOT raise
  /// [PaymentNotFoundFailure]. Used by the "this invoice has been
  /// paid by …" detail screen.
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String invoiceUuid,
  );

  /// Return every payment belonging to the customer with
  /// [customerUuid], regardless of whether they are tied to a
  /// specific invoice. Used by the balance derivation to sum
  /// `paymentsTotal = sum(payment.amount)` grouped by customer.
  ///
  /// Not exposed at the use-case layer — kept on the repository
  /// so the Balance feature can compose it without taking a
  /// dependency on Payment's *public* use-case surface.
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String customerUuid,
  );
}
