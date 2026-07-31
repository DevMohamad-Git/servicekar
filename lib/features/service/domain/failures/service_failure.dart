/// Base type for every failure raised by the Service feature.
///
/// `sealed` so the analyzer enforces exhaustive switches at the call site.
/// Domain layer is pure Dart — no Freezed/Riverpod/Isar imports here.
///
/// `ServiceFailure` is intentionally NOT itself instantiable; one of the
/// concrete subtypes below is always returned.
sealed class ServiceFailure {
  const ServiceFailure();

  /// Human-readable message for logging / debug UIs. Localized messages
  /// are produced by the presentation layer via `AppLocalizations`.
  String get message;
}

/// Requested service does not exist (lookup by id returned null).
final class ServiceNotFoundFailure extends ServiceFailure {
  const ServiceNotFoundFailure({required this.id});

  final String id;

  @override
  String get message => 'Service not found: $id';
}

/// Input validation failed before reaching the repository.
/// The [field] identifies the offending input, [message] is operator-facing.
final class ServiceValidationFailure extends ServiceFailure {
  const ServiceValidationFailure({required this.field, required this.message});

  final String field;

  @override
  final String message;
}

/// The linked customer (parent FK) is missing or unreadable.
/// Distinct from [ServiceValidationFailure] because the input itself was
/// syntactically correct — the *referenced* row does not exist.
final class ServiceCustomerMissingFailure extends ServiceFailure {
  const ServiceCustomerMissingFailure({
    required this.customerUuid,
    required this.reason,
  });

  final String customerUuid;

  /// "notFound" — no customer row with this uuid.
  /// "lookupFailed" — the customer repository exploded while reading.
  final String reason;

  @override
  String get message =>
      'Customer $customerUuid is required to register the service: '
      '$reason';
}

/// Underlying storage (Isar) reported an error during read/write/delete.
/// The [operation] describes what was attempted for observability.
final class ServiceStorageFailure extends ServiceFailure {
  const ServiceStorageFailure({required this.operation, required this.message});

  final String operation;

  @override
  final String message;
}
