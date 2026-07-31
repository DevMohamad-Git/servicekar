/// Re-export of the domain entity so this file is the single
/// touchpoint for callers that use the outcome wrapper. The actual
/// [InvoiceEntity] class lives in the customer feature's domain for
/// now (the schema foundation shipped invoice-side classes there);
/// future refactors may move it into `features/invoice/domain/entities/`
/// without changing this re-export.
import '../../../customer/domain/entities/invoice_entity.dart';

export '../../../customer/domain/entities/invoice_entity.dart';

/// Pure-Dart value model that wraps a *successful* invoice write
/// with any non-fatal validation warnings the use case emitted.
///
/// Distinct from an `InvoiceFailure` because the write itself
/// completed — only a soft signal was attached. The presentation
/// layer reads [warnings] and surfaces them (e.g. "issueDate is in
/// the future — confirm before issuing?") without blocking the
/// operation.
///
/// Why not an `InvoiceValidationFailure`:
///   * "Future issueDate" is documented as *warning behaviour, not
///     hard failure* in the task brief.
///   * Returning the warning as a `Left(...)` would force every
///     caller to special-case the message; the cleaner shape is
///     "operation succeeded + here are the soft notes for the
///     operator".
///
/// Used by [RegisterInvoiceUseCase] and [UpdateInvoiceUseCase] — both
/// can emit an "issueDate is in the future" warning. Read use cases
/// and [DeleteInvoiceUseCase] do not need this wrapper.
class InvoiceOperationOutcome {
  const InvoiceOperationOutcome({
    required this.invoice,
    this.warnings = const <InvoiceValidationWarning>[],
  });

  /// The just-persisted invoice entity, as read back from storage.
  final InvoiceEntity invoice;

  /// Soft non-fatal notes the use case attached. Empty when none
  /// fired. Never null — callers can treat `warnings.isEmpty` as
  /// "nothing to show".
  final List<InvoiceValidationWarning> warnings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceOperationOutcome &&
          other.invoice == invoice &&
          _listEq(other.warnings, warnings));

  @override
  int get hashCode => Object.hash(invoice, Object.hashAll(warnings));

  @override
  String toString() =>
      'InvoiceOperationOutcome(invoice: $invoice, '
      'warnings: ${warnings.length})';

  /// Pure factory: inspects [invoice.issueDate] against [now],
  /// attaches an "issueDate is in the future" soft warning when
  /// applicable, and wraps the entity. Used by both
  /// [RegisterInvoiceUseCase] and [UpdateInvoiceUseCase] so the
  /// warning logic lives in one place.
  ///
  /// Uses the **persisted** entity's `issueDate` rather than the
  /// caller-supplied param so any future storage-side stamp of
  /// timestamps still feeds the same warning verdict.
  static InvoiceOperationOutcome withDetectedWarnings({
    required InvoiceEntity invoice,
    required DateTime now,
  }) {
    final issueDate = invoice.issueDate;
    if (issueDate != null && issueDate.isAfter(now)) {
      return InvoiceOperationOutcome(
        invoice: invoice,
        warnings: const [
          InvoiceValidationWarning(
            field: 'issueDate',
            message:
                'issueDate is in the future — confirm before issuing.',
          ),
        ],
      );
    }
    return InvoiceOperationOutcome(invoice: invoice);
  }
}

/// Operator-facing soft warning. Distinct from
/// `InvoiceValidationFailure` because warnings *do not block the
/// write*; failures *do*.
class InvoiceValidationWarning {
  const InvoiceValidationWarning({required this.field, required this.message});

  /// Which field produced the warning (`issueDate`, `totalAmount`, …).
  final String field;

  /// Operator-facing message. Localizable at the presentation layer.
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceValidationWarning &&
          other.field == field &&
          other.message == message);

  @override
  int get hashCode => Object.hash(field, message);

  @override
  String toString() =>
      'InvoiceValidationWarning(field: $field, message: $message)';
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
