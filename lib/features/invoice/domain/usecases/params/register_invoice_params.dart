import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';

/// Parameter model for [RegisterInvoiceUseCase.call].
///
/// Bundles every operator-supplied field required to register an
/// invoice for an existing customer. Centralises the parameter
/// shape so the use-case signature stays stable as fields are
/// added (status defaults, dueDate, line-items, …).
///
/// Mirrors `RegisterServiceParams` / `RegisterPaymentParams` —
/// see those for the wider parameter-bundle pattern.
class RegisterInvoiceParams {
  const RegisterInvoiceParams({
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

  /// Business-stable identifier. UUID v4 is the recommended
  /// default; the data layer round-trips it through
  /// `InvoiceIsar.uuid`'s unique + `replace: true` index.
  final String id;

  /// FK to a [CustomerEntity.id]. Required: every Invoice belongs
  /// to a Customer. The use case verifies the FK resolves at call
  /// time via [CustomerRepository].
  final String customerUuid;

  /// Operator-facing invoice number (e.g. `"INV-2026-0042"`). The
  /// use case rejects empty / whitespace values.
  final String invoiceNumber;

  /// When the invoice was issued. Required. The use case emits a
  /// *warning* (not failure) when this is in the future — see
  /// `InvoiceOperationOutcome.withDetectedWarnings`.
  final DateTime issueDate;

  /// Optional payment-due date. `null` for "no hard deadline".
  final DateTime? dueDate;

  /// Lifecycle state. Defaults to draft.
  final InvoiceStatus status;

  /// Line items that compose the invoice's total. The use case
  /// preserves them verbatim; total recomputation lives on the
  /// caller (or on the data layer's `total Amount` caching).
  final List<InvoiceLineItemEntity> lineItems;

  /// Cached `sum(lineItem.total)` for the invoice at write time.
  /// Must be ≥ 0 per the brief; `0.0` is allowed (zero-invoice).
  final double totalAmount;

  /// Optional operator notes attached to the whole invoice.
  final String? notes;
}
