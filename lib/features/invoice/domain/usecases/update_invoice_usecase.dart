import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/invoice_entity.dart';
import '../failures/invoice_failure.dart';
import '../repositories/invoice_repository.dart';
import '../value_models/invoice_operation_outcome.dart';
import 'params/update_invoice_params.dart';

/// Replace an existing invoice record by [InvoiceEntity.id].
///
/// Validation mirrors [RegisterInvoiceUseCase]:
///   * `id` required (otherwise nothing to look up).
///   * `invoiceNumber` non-empty after trimming.
///   * `totalAmount` must be ≥ 0 (zero allowed).
///   * future-dated `issueDate` becomes a *warning*, not a failure.
///
/// Customer-existence is NOT re-verified here — the original
/// register already gated on that. Update accepts the existing FK
/// verbatim so renaming / re-parenting flows remain in dedicated
/// use cases (not on this one). If a future caller truly wants
/// re-parent verification, that moves into an explicit
/// `ReassignInvoiceUseCase`.
class UpdateInvoiceUseCase {
  const UpdateInvoiceUseCase(this._repository);

  final InvoiceRepository _repository;

  Future<Either<InvoiceFailure, InvoiceOperationOutcome>> call(
    UpdateInvoiceParams params,
  ) async {
    if (params.id.trim().isEmpty) {
      return const Left(
        InvoiceValidationFailure(
          field: 'id',
          message: 'Invoice id is required for updates.',
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
    if (params.invoiceNumber.trim().isEmpty) {
      return const Left(
        InvoiceValidationFailure(
          field: 'invoiceNumber',
          message: 'Invoice number is required.',
        ),
      );
    }
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
      createdAt: null,
      updatedAt: null,
    );

    final result = await _repository.updateInvoice(entity);
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
