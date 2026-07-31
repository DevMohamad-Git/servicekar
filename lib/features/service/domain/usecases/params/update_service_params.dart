import 'package:servicar/features/customer/domain/entities/service_entity.dart';

/// Parameter model for [UpdateServiceUseCase.call].
///
/// Carries the full updated entity snapshot so the use case can replay
/// every editable field. The matching `id` is required because it's the
/// repository's lookup key. Same validation rules as
/// [RegisterServiceParams]; future-dated `startedAt` again produces a
/// non-fatal warning rather than blocking the write.
class UpdateServiceParams {
  const UpdateServiceParams({
    required this.id,
    required this.customerUuid,
    required this.title,
    required this.status,
    required this.price,
    this.description,
    this.tags = const <String>[],
    this.startedAt,
    this.completedAt,
  });

  /// Business-stable identifier. Required — the repository key.
  final String id;

  /// FK to [CustomerEntity.id]. The use case does NOT re-verify the
  /// customer exists here (the original register already did); update
  /// accepts the existing FK verbatim so renaming / re-parenting flows
  /// stay in register / explicit re-parent use cases.
  final String customerUuid;

  /// Display title. Required; use case rejects empty.
  final String title;

  /// Lifecycle state. Caller-driven on update.
  final ServiceStatus status;

  /// Agreed price. Must be ≥ 0.
  final double price;

  /// Optional free-form description / scope notes.
  final String? description;

  /// Operator-defined tags.
  final List<String> tags;

  /// Optional work-started timestamp. Future → warning.
  final DateTime? startedAt;

  /// Optional work-finished timestamp. Set on transition to `completed`.
  final DateTime? completedAt;
}
