/// Base type for every failure raised by the Customer feature.
///
/// `sealed` so the analyzer enforces exhaustive switches at the call site.
/// Domain layer is pure Dart — no Freezed/Riverpod/Isar imports here.
///
/// `CustomerFailure` is intentionally NOT itself instantiable; one of the
/// three concrete subtypes below is always returned.
sealed class CustomerFailure {
  const CustomerFailure();

  /// Human-readable message for logging / debug UIs. Localized messages
  /// are produced by the presentation layer via `AppLocalizations`.
  String get message;
}

/// Requested customer does not exist (lookup by id returned null).
final class CustomerNotFoundFailure extends CustomerFailure {
  const CustomerNotFoundFailure({required this.id});

  final String id;

  @override
  String get message => 'Customer not found: $id';
}

/// Input validation failed before reaching the repository.
/// The [field] identifies the offending input, [message] is operator-facing.
final class CustomerValidationFailure extends CustomerFailure {
  const CustomerValidationFailure({
    required this.field,
    required this.message,
  });

  final String field;

  @override
  final String message;
}

/// Underlying storage (Isar) reported an error during read/write/delete.
/// The [operation] describes what was attempted for observability.
final class CustomerStorageFailure extends CustomerFailure {
  const CustomerStorageFailure({
    required this.operation,
    required this.message,
  });

  final String operation;

  @override
  final String message;
}
