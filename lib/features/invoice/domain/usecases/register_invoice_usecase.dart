import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/customer_entity.dart';
import '../../../customer/domain/entities/invoice_entity.dart';
import '../../../customer/domain/failures/customer_failure.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../failures/invoice_failure.dart';
import '../repositories/invoice_repository.dart';
import '../value_models/invoice_operation_outcome.dart';
import 'params/register_invoice_params.dart';

/// Persist a brand-new [InvoiceEntity] for an existing customer.
///
/// ─── Business rules (enforced here, NOT in widgets) ─────────────────
/// 1. **Customer must exist.** The use case asks [CustomerRepository]
///    for the referenced row before delegating to [InvoiceRepository].
///    A missing customer returns [InvoiceCustomerMissingFailure] —
///    never [InvoiceValidationFailure], because the input itself
///    is syntactically valid; the *referenced* row is the problem.
/// 2. **`invoiceNumber` cannot be empty.** Trimmed-check. Empty /
///    whitespace rejected with [InvoiceValidationFailure].
/// 3. **`totalAmount` cannot be negative.** Strict `< 0` rejection;
///    `0.0` is accepted (zero-value invoice per the brief).
/// 4. **`issueDate` must be valid (non-null).** Reaches here as a
///    required field on [RegisterInvoiceParams]; nullability is
///    caught at compile time.
/// 5. **Future `issueDate` produces a WARNING, not a failure.** The
///    service is still persisted; the warning rides along inside
///    [InvoiceOperationOutcome.warnings] so the presentation layer
///    can surface a confirm-before-save dialog without blocking.
///
/// Why an [InvoiceOperationOutcome] rather than `InvoiceEntity`:
/// the brief explicitly says warnings are non-fatal. Returning a
/// wrapper gives callers a single value to check —
/// `Right(outcome)` — instead of a branch on `Left` vs
/// `Right-with-warning-attached`.
class RegisterInvoiceUseCase {
  const RegisterInvoiceUseCase({
    required InvoiceRepository invoiceRepository,
    required CustomerRepository customerRepository,
  }) : _invoiceRepository = invoiceRepository,
       _customerRepository = customerRepository;

  final InvoiceRepository _invoiceRepository;
  final CustomerRepository _customerRepository;

  Future<Either<InvoiceFailure, InvoiceOperationOutcome>> call(
    RegisterInvoiceParams params,
  ) async {
    // ── (a) Cheap field validation — fail fast ────────────────
    if (params.id.trim().isEmpty) {
      return const Left(
        InvoiceValidationFailure(
          field: 'id',
          message: 'Invoice id is required.',
        ),
      );
    }
    if (params.customerUuid.trim().isEmpty) {
      return const Left(
        InvoiceValidationFailure(
          field: 'customerUuid',
          message: 'Customer id is required.',
        ),
      );
    }
    // ── (2) invoiceNumber must be non-empty ─────────────────
    if (params.invoiceNumber.trim().isEmpty) {
      return const Left(
        InvoiceValidationFailure(
          field: 'invoiceNumber',
          message: 'Invoice number is required.',
        ),
      );
    }
    // ── (3) totalAmount must be ≥ 0 (zero is allowed) ───────
    if (params.totalAmount.isNaN) {
      return const Left(
        InvoiceValidationFailure(
          field: 'totalAmount',
          message: 'Total amount must be a finite number.',
        ),
      );
    }
    if (params.totalAmount < 0.0) {
      return const Left(
        InvoiceValidationFailure(
          field: 'totalAmount',
          message: 'Total amount cannot be negative.',
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
        InvoiceCustomerMissingFailure(
          customerUuid: params.customerUuid,
          reason: reason,
        ),
      );
    }

    // Build the entity — keep the caller-generated uuid so the
    // data layer's `replace: true` upsert mirrors the customer
    // pattern.
    final now = DateTime.now();
    final entity = InvoiceEntity(
      id: params.id,
      customerUuid: params.customerUuid,
      invoiceNumber: params.invoiceNumber.trim(),
      issueDate: params.issueDate,
      dueDate: params.dueDate,
      status: params.status,
      lineItems: List<InvoiceLineItemEntity>.unmodifiable(params.lineItems),
      totalAmount: params.totalAmount,
      notes: params.notes,
      // createdAt / updatedAt remain null at this layer — the
      // repository's `_readBack` round-trip would lose them anyway
      // because today's data layer doesn't auto-stamp. Matches the
      // customer / service pattern.
      createdAt: null,
      updatedAt: null,
    );

    // Delegate to the repository; capture the storage Either so we
    // can attach the (5) future-issueDate warning before returning.
    final result = await _invoiceRepository.createInvoice(entity);
    return result.fold(
      (failure) => Left<InvoiceFailure, InvoiceOperationOutcome>(failure),
      (invoice) => Right<InvoiceFailure, InvoiceOperationOutcome>(
        InvoiceOperationOutcome.withDetectedWarnings(
          invoice: invoice,
          now: now,
        ),
      ),
    );
  }
}
