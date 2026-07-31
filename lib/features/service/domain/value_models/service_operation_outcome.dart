/// Re-export of the domain entity so this file is the single touchpoint
/// for callers that use the outcome wrapper. The actual class lives in
/// the customer feature's domain for now (the schema foundation shipped
/// service-side classes there); future refactors may move it into
/// `features/service/domain/entities/` without changing this re-export.
import '../../../customer/domain/entities/service_entity.dart';

export '../../../customer/domain/entities/service_entity.dart';

/// Pure-Dart value model that wraps a *successful* service write with any
/// non-fatal validation warnings the use case emitted.
///
/// Distinct from a `ServiceFailure` because the write itself completed —
/// only a soft signal was attached. The presentation layer reads
/// [warnings] and surfaces them (e.g. "startedAt is in the future — confirm?")
/// without blocking the operation.
///
/// Why not a `ServiceValidationFailure`:
///   * "Future date" is documented as *warning behaviour, not hard failure*.
///   * Returning the warning as a `Left(...)` would force every caller to
///     special-case the message; the cleaner shape is "operation succeeded
///     + here are the soft notes for the operator".
///
/// Used by [RegisterServiceUseCase] and [UpdateServiceUseCase] — both
/// can emit a "startedAt is in the future" warning. Read use cases and
/// [DeleteServiceUseCase] do not need this wrapper.
class ServiceOperationOutcome {
  const ServiceOperationOutcome({
    required this.service,
    this.warnings = const <ServiceValidationWarning>[],
  });

  /// The just-persisted service entity, as read back from storage.
  final ServiceEntity service;

  /// Soft non-fatal notes the use case attached. Empty when none fired.
  /// Never null — callers can treat `warnings.isEmpty` as "nothing to show".
  final List<ServiceValidationWarning> warnings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceOperationOutcome &&
          other.service == service &&
          _listEq(other.warnings, warnings));

  @override
  int get hashCode => Object.hash(service, Object.hashAll(warnings));

  @override
  String toString() =>
      'ServiceOperationOutcome(service: $service, '
      'warnings: ${warnings.length})';

  /// Pure factory: inspects [service.startedAt] against [now], attaches
  /// a "startedAt is in the future" soft warning when applicable, and
  /// wraps the entity. Used by both [RegisterServiceUseCase] and
  /// [UpdateServiceUseCase] so the warning logic lives in one place.
  ///
  /// Uses the **persisted** entity's `startedAt` rather than the
  /// caller-supplied param so any future storage-side stamp of
  /// timestamps still feeds the same warning verdict.
  static ServiceOperationOutcome withDetectedWarnings({
    required ServiceEntity service,
    required DateTime now,
  }) {
    final startedAt = service.startedAt;
    if (startedAt != null && startedAt.isAfter(now)) {
      return ServiceOperationOutcome(
        service: service,
        warnings: const [
          ServiceValidationWarning(
            field: 'startedAt',
            message:
                'startedAt is in the future — confirm before opening work.',
          ),
        ],
      );
    }
    return ServiceOperationOutcome(service: service);
  }
}

/// Operator-facing soft warning. Distinct from `ServiceValidationFailure`
/// because warnings *do not block the write*; failures *do*.
class ServiceValidationWarning {
  const ServiceValidationWarning({required this.field, required this.message});

  /// Which field produced the warning (`startedAt`, `price`, …).
  final String field;

  /// Operator-facing message. Localizable at the presentation layer.
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceValidationWarning &&
          other.field == field &&
          other.message == message);

  @override
  int get hashCode => Object.hash(field, message);

  @override
  String toString() =>
      'ServiceValidationWarning(field: $field, message: $message)';
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
