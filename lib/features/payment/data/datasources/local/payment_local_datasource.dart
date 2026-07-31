import 'package:servicar/features/customer/data/models/payment_model.dart';

/// Abstraction over local storage for payments.
///
/// Implementations live in `data/datasources/local/`. Keeping the
/// interface here makes it trivial to swap Isar for Hive / sqflite
/// / an in-memory fake during testing without touching the
/// repository.
///
/// Symmetric with [CustomerLocalDataSource] / [ServiceLocalDataSource]
/// — see those files for the wider rationale on the local-only
/// abstraction.
abstract class PaymentLocalDataSource {
  /// Return the payment with [id], or `null` if absent.
  Future<PaymentModel?> getById(String id);

  /// Return every payment attached to [customerUuid] regardless of
  /// whether the payment is invoice-tied. Used by the balance
  /// derivation to feed `sum(payment.amount)` per customer.
  Future<List<PaymentModel>> getByCustomer(String customerUuid);

  /// Return every payment attached to [invoiceUuid] — i.e. payments
  /// whose `invoiceUuid == invoiceUuid`. Payments with a `null`
  /// `invoiceUuid` (on-account advances) are NOT included.
  Future<List<PaymentModel>> getByInvoice(String invoiceUuid);

  /// Insert or update [model]. The Isar
  /// `@Index(unique: true, replace: true)` on `PaymentIsar.uuid`
  /// collapses re-saves into in-place updates.
  Future<void> save(PaymentModel model);

  /// Remove the record with [id]. No-op if it does not exist.
  Future<void> delete(String id);
}
