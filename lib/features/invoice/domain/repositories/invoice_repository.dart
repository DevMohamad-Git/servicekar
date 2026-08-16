import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';

import '../failures/invoice_failure.dart';

// Re-export the failure hierarchy so existing consumers that
// imported `InvoiceFailure` / `InvoiceNotFoundFailure` /
// `InvoiceStorageFailure` from this file (a transitive of the
// Phase-4 contract) keep working without a churn-bearing refactor.
// Adding the validation / customer-missing subtypes to the export
// list opens them up to the same consumers — which is fine because
// they live in `failures/invoice_failure.dart` and belong to the
// same sealed hierarchy.
export '../failures/invoice_failure.dart'
    show
        InvoiceFailure,
        InvoiceNotFoundFailure,
        InvoiceStorageFailure,
        InvoiceValidationFailure,
        InvoiceCustomerMissingFailure;

/// Contract every Invoice repository implementation must satisfy.
///
/// Implementations live in `features/invoice/data/repositories/`.
/// Domain code only ever sees this interface — never the
/// implementation, which lets us swap local/remote or mock the
/// contract in tests without touching business logic.
///
/// Methods return `Future<Either<InvoiceFailure, T>>` to mirror
/// the pattern of [CustomerRepository] / [PaymentRepository] /
/// [ServiceRepository].
///
/// ─── History note ─────────────────────────────────────────────────
/// The Phase-4 read-only slice of this contract shipped with
/// only `getById` / `getByCustomer` / `getTotalByCustomer`. The
/// full CRUD surface (`createInvoice` / `updateInvoice` /
/// `deleteInvoice`) was added when the offline-first Invoice
/// feature finally replaced the stub. The base failure surface
/// (NotFound + Storage) was moved to
/// `lib/features/invoice/domain/failures/invoice_failure.dart` at
/// the same time; this file now imports them.
abstract class InvoiceRepository {
  /// Persist a brand-new invoice. Returns
  /// [InvoiceCustomerMissingFailure] when the FK does not resolve,
  /// [InvoiceValidationFailure] when input was rejected by the use
  /// case, [InvoiceStorageFailure] on I/O.
  Future<Either<InvoiceFailure, InvoiceEntity>> createInvoice(
    InvoiceEntity invoice,
  );

  /// Persist updates to an existing invoice by [InvoiceEntity.id].
  /// Returns [InvoiceNotFoundFailure] on a missing id.
  Future<Either<InvoiceFailure, InvoiceEntity>> updateInvoice(
    InvoiceEntity invoice,
  );

  /// Remove the invoice with the given [id]. A successful delete
  /// yields [Unit.instance] on the success side.
  Future<Either<InvoiceFailure, Unit>> deleteInvoice(String id);

  /// Look up a single invoice by id. Returns [InvoiceNotFoundFailure]
  /// on no match.
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id);

  /// Return every invoice belonging to the customer with
  /// [customerUuid], ordered by [InvoiceEntity.issueDate]
  /// descending. Empty list on no matches — does NOT raise a
  /// not-found failure.
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String customerUuid,
  );

  /// Sum of [InvoiceEntity.totalAmount] for the customer's open
  /// invoices. Returns `0.0` on no rows. Used by the balance
  /// derivation to avoid hydrating every InvoiceEntity on the
  /// hot path.
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String customerUuid,
  );

  /// Total number of persisted invoices across all customers.
  /// Zero rows is a successful `0` — never a failure. Feeds the
  /// dashboard's "registered invoices" KPI via a single
  /// constant-time count rather than hydrating every entity.
  Future<Either<InvoiceFailure, int>> getInvoiceCount();
}
