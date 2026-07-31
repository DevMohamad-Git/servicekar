import 'package:servicar/features/customer/domain/entities/service_entity.dart';

/// Parameter model for [RegisterServiceUseCase.call].
///
/// Bundles every operator-supplied field required to register a service
/// for an existing customer. Centralising the parameter shape keeps the
/// use-case signature stable as we add fields (status defaults, tags,
/// startedAt, …) — adding one does not require touching every call site.
///
/// The service `id` is required here because the data layer's UUID is
/// generated upstream. Today's id generator lives in the presentation
/// layer (`'srv_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'`
/// mirrors the customer pattern); the use case accepts it verbatim so
/// we can swap to UUID v4 later without changing the use case.
class RegisterServiceParams {
  const RegisterServiceParams({
    required this.id,
    required this.customerUuid,
    required this.title,
    this.description,
    this.status = ServiceStatus.pending,
    this.price = 0.0,
    this.tags = const <String>[],
    this.startedAt,
  });

  /// Business-stable identifier (UUID v4 recommended).
  final String id;

  /// FK to [CustomerEntity.id]. Required: every Service belongs to a
  /// Customer. The use case verifies the FK resolves at call time.
  final String customerUuid;

  /// Display title (e.g. "Oil change"). Required; use case rejects empty.
  final String title;

  /// Optional free-form description / scope notes.
  final String? description;

  /// Lifecycle state. Defaults to [ServiceStatus.pending].
  final ServiceStatus status;

  /// Agreed price. Must be ≥ 0; zero allowed (warranty / free service).
  final double price;

  /// Operator-defined tags.
  final List<String> tags;

  /// Optional work-started timestamp. Null until status leaves "pending".
  /// Future timestamps produce a *warning*, not a hard failure, per the
  /// business rules documented on [RegisterServiceUseCase].
  final DateTime? startedAt;
}
