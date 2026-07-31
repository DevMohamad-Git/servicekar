import 'package:servicar/features/customer/data/models/invoice_model.dart';

/// Abstraction over local storage for invoices.
///
/// Implementations live in `data/datasources/local/`. Keeping the
/// interface here makes it trivial to swap Isar for Hive / sqflite
/// / an in-memory fake during testing without touching the
/// repository.
///
/// Symmetric with [CustomerLocalDataSource] / [ServiceLocalDataSource]
/// / [PaymentLocalDataSource] — see those for the wider rationale on
/// the local-only abstraction.
abstract class InvoiceLocalDataSource {
  /// Look up a single invoice by id. Returns `null` on no match.
  ///
  /// Used both by the repository's `_readBack` after a write and
  /// by `GetInvoiceByIdUseCase`.
  Future<InvoiceModel?> getById(String id);

  /// Return every invoice attached to [customerUuid], ordered by
  /// `issueDate` desc. Determines the head of the customer
  /// "open invoices" list and feeds balance summation.
  Future<List<InvoiceModel>> getByCustomer(String customerUuid);

  /// Sum of [InvoiceModel.totalAmount] for [customerUuid]. Returns
  /// `0.0` on no rows. Used by [CalculateCustomerBalanceUseCase]
  /// to derive `invoicesTotal` without hydrating the whole
  /// collection.
  Future<double> getTotalByCustomer(String customerUuid);

  /// Insert or update [model]. The Isar
  /// `@Index(unique: true, replace: true)` on `InvoiceIsar.uuid`
  /// collapses re-saves into in-place updates.
  Future<void> save(InvoiceModel model);

  /// Remove the record with [id]. No-op if it does not exist.
  Future<void> delete(String id);
}
