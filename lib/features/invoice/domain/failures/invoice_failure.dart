/// Base type for every failure raised by the Invoice feature.
///
/// `sealed` so the analyzer enforces exhaustive switches at the
/// call site. Domain layer is pure Dart — no Freezed/Riverpod/Isar
/// imports here.
///
/// `InvoiceFailure` is intentionally NOT itself instantiable; one
/// of the concrete subtypes below is always returned.
sealed class InvoiceFailure {
  const InvoiceFailure();

  /// Human-readable message for logging / debug UIs. Localized
  /// messages are produced by the presentation layer via
  /// `AppLocalizations`.
  String get message;
}

/// Requested invoice does not exist (lookup by id returned null).
final class InvoiceNotFoundFailure extends InvoiceFailure {
  const InvoiceNotFoundFailure({required this.id});

  final String id;

  @override
  String get message => 'Invoice not found: $id';
}

/// Underlying storage (Isar) reported an error during read /
/// write / delete. The [operation] describes what was attempted
/// for observability.
final class InvoiceStorageFailure extends InvoiceFailure {
  const InvoiceStorageFailure({required this.operation, required this.message});

  final String operation;

  @override
  final String message;
}

/// Input validation failed before reaching the repository. The
/// [field] identifies the offending input, [message] is
/// operator-facing.
final class InvoiceValidationFailure extends InvoiceFailure {
  const InvoiceValidationFailure({required this.field, required this.message});

  final String field;

  @override
  final String message;
}

/// The FK to the parent customer is missing or unreadable.
///
/// Distinct from [InvoiceValidationFailure] because the input
/// itself could be syntactically valid — the *referenced* row does
/// not exist. Symmetric with the service feature's
/// `ServiceCustomerMissingFailure` and the payment feature's
/// `PaymentCustomerMissingFailure`.
final class InvoiceCustomerMissingFailure extends InvoiceFailure {
  const InvoiceCustomerMissingFailure({
    required this.customerUuid,
    required this.reason,
  });

  final String customerUuid;

  /// "notFound"     — no customer row with this uuid.
  /// "lookupFailed" — the customer repository exploded while
  ///                  reading.
  final String reason;

  @override
  String get message =>
      'Customer $customerUuid is required to register an invoice: '
      '$reason';
}
