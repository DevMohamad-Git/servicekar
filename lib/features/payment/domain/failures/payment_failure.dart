/// Base type for every failure raised by the Payment feature.
///
/// `sealed` so the analyzer enforces exhaustive switches at the
/// call site. Domain layer is pure Dart — no Freezed/Riverpod/Isar
/// imports here.
sealed class PaymentFailure {
  const PaymentFailure();

  /// Human-readable message for logging / debug UIs. Localized
  /// messages are produced by the presentation layer via
  /// `AppLocalizations`.
  String get message;
}

/// Requested payment does not exist (lookup by id returned null).
final class PaymentNotFoundFailure extends PaymentFailure {
  const PaymentNotFoundFailure({required this.id});

  final String id;

  @override
  String get message => 'Payment not found: $id';
}

/// Input validation failed before reaching the repository. The
/// [field] identifies the offending input.
final class PaymentValidationFailure extends PaymentFailure {
  const PaymentValidationFailure({required this.field, required this.message});

  final String field;

  @override
  final String message;
}

/// The FK to the parent customer is missing or unreadable.
///
/// Distinct from [PaymentValidationFailure] because the input
/// itself could be syntactically valid — the *referenced* row does
/// not exist. Symmetric with the service feature's
/// `ServiceCustomerMissingFailure`.
final class PaymentCustomerMissingFailure extends PaymentFailure {
  const PaymentCustomerMissingFailure({
    required this.customerUuid,
    required this.reason,
  });

  final String customerUuid;

  /// "notFound"        — no customer row with this uuid.
  /// "lookupFailed"    — the customer repository exploded while
  ///                      reading.
  final String reason;

  @override
  String get message =>
      'Customer $customerUuid is required to register a payment: '
      '$reason';
}

/// The (optional) FK to the parent invoice resolves to a missing row.
///
/// Only fired when [PaymentEntity.invoiceUuid] is *supplied* — a
/// `null` invoiceUuid is a valid "on-account" payment by design.
/// Symmetric with the parent's customer-missing failure.
final class PaymentInvoiceMissingFailure extends PaymentFailure {
  const PaymentInvoiceMissingFailure({
    required this.invoiceUuid,
    required this.reason,
  });

  final String invoiceUuid;

  /// "notFound" — no invoice row with this uuid.
  /// "lookupFailed" — the invoice repository exploded while reading.
  final String reason;

  @override
  String get message =>
      'Invoice $invoiceUuid is required to register a payment: '
      '$reason';
}

/// Underlying storage (Isar) reported an error during read /
/// write / delete. The [operation] describes what was attempted
/// for observability.
final class PaymentStorageFailure extends PaymentFailure {
  const PaymentStorageFailure({required this.operation, required this.message});

  final String operation;

  @override
  final String message;
}
