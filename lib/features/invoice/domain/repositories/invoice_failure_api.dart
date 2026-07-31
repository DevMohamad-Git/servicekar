/// Minimal failure surface for the Invoice contract.
///
/// This file is the *base* of the `InvoiceFailure` sealed hierarchy.
/// The full CRUD expansion ([InvoiceValidationFailure],
/// [InvoiceCustomerMissingFailure]) lives in
/// `lib/features/invoice/domain/failures/invoice_failure.dart` and
/// re-exports the three base types below.
///
/// Keeping the base types here lets the `InvoiceRepository`
/// contract reference them directly without pulling in the
/// failures folder.
library;

import 'package:servicar/core/utils/either.dart';

/// Base type for every failure raised by the Invoice feature.
///
/// `sealed` so the analyzer enforces exhaustive switches at the
/// call site. Domain layer is pure Dart — no Freezed/Riverpod/Isar
/// imports here.
///
/// `InvoiceFailure` is intentionally NOT itself instantiable; one of
/// the concrete subtypes below (or in
/// `features/invoice/domain/failures/`) is always returned.
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

/// Compile-time hint — the sealed [InvoiceFailure] type is the
/// carry-channel for the [Either] returned by every repository
/// method. Re-exported here to keep tests / use cases importing a
/// single source file.
typedef InvoiceEither<T> = Either<InvoiceFailure, T>;
