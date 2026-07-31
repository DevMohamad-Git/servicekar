import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';

/// Parameter model for [UpdateInvoiceUseCase.call].
///
/// Carries the full updated invoice snapshot so the use case can
/// replay every editable field. The matching `id` is required
/// because it's the repository's lookup key. Same validation rules
/// as [RegisterInvoiceParams]; future-dated `issueDate` again
/// produces a non-fatal warning rather than blocking the write.
///
/// Mirrors `UpdateServiceParams` — see that file for the wider
/// parameter-bundle pattern.
class UpdateInvoiceParams {
  const UpdateInvoiceParams({
    required this.id,
    required this.customerUuid,
    required this.invoiceNumber,
    required this.issueDate,
    this.dueDate,
    this.status = InvoiceStatus.draft,
    this.lineItems = const <InvoiceLineItemEntity>[],
    this.totalAmount = 0.0,
    this.notes,
  });

  /// Business-stable identifier. Required — the repository key.
  final String id;

  /// FK to [CustomerEntity.id]. The use case does NOT re-verify
  /// the customer exists here (the original register already
  /// did); update accepts the existing FK verbatim so renaming /
  /// re-parenting flows stay in register / explicit re-parent
  /// use cases. If a future caller truly wants re-parent
  /// verification, that moves into a dedicated
  /// `ReassignInvoiceUseCase`.
  final String customerUuid;

  /// Operator-facing invoice number. Use case rejects empty /
  /// whitespace values.
  final String invoiceNumber;

  /// Revised `issueDate`. Required. Future → warning.
  final DateTime issueDate;

  /// Optional payment-due date. `null` for "no deadline".
  final DateTime? dueDate;

  /// Revised lifecycle state. Caller-driven.
  final InvoiceStatus status;

  /// Revised line-item list.
  final List<InvoiceLineItemEntity> lineItems;

  /// Revised `totalAmount`. Must be ≥ 0; `0.0` allowed.
  final double totalAmount;

  /// Optional operator notes attached to the whole invoice.
  final String? notes;
}
