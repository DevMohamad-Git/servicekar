/// Pure-Dart domain "Service" — a unit of work performed FOR a customer.
///
/// Linked to [CustomerEntity] via the [customerUuid] field. The
/// linking strategy is a plain `String` foreign key (no `IsarLink`,
/// no nested object) for two reasons:
///
///   * Avoids the `IsarLink` + `Isar.autoIncrement` + `replace: true`
///     detachment bug documented on `CustomerIsar`. When a customer's
///     record is re-imported, Isar reissues the internal int [Id];
///     every `IsarLink<ServiceIsar>` would silently detach, leaving
///     orphan services. A `String customerUuid` survives the swap
///     trivially.
///   * Keeps Isar queries simple: per-customer services are a
///     single filtered `where().customerUuidEqualTo(...)` query,
///     which Isar turns into a constant-time index hit.
///
/// Linked to `CustomerEntity` (required). A Service that survives a
/// Customer deletion is an orphan — the repository layer is
/// responsible for cascading deletes manually because we are not
/// using `IsarLink`.
class ServiceEntity {
  const ServiceEntity({
    required this.id,
    required this.customerUuid,
    required this.title,
    this.description,
    this.status = ServiceStatus.pending,
    this.price = 0.0,
    this.tags = const <String>[],
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Stable identifier. UUID v4 is the recommended default; the data
  /// layer generates it when creating a new record.
  final String id;

  /// FK to [CustomerEntity.id]. Required: every Service belongs to
  /// exactly one Customer. Indexed in the Isar collection for cheap
  /// per-customer lookup.
  final String customerUuid;

  /// Short, human-readable title (e.g. "Oil change", "Tire rotation").
  /// Indexed at the storage layer so the search bar can filter
  /// across the customer's service history.
  final String title;

  /// Optional free-form description / scope notes.
  final String? description;

  /// Lifecycle state. Stored as the `String` form of [ServiceStatus];
  /// the enum is the *contract* the domain speaks, the String is
  /// what the schema persists. Migration to a typed Isar enum is
  /// intentionally out of scope for this task.
  final ServiceStatus status;

  /// Agreed / final price in the local currency. The repository
  /// layer will recompute the customer's debt as
  /// `sum(invoice.totalAmount) - sum(payment.amount)`; the price
  /// field on a Service is captured for invoicing convenience and
  /// historical recall, not for live debt math.
  final double price;

  /// Operator-defined tags (e.g. `warranty`, `recall`).
  final List<String> tags;

  /// When work actually started (null until status leaves "pending").
  final DateTime? startedAt;

  /// When work finished (null until status leaves "pending" /
  /// "in_progress" / equivalent).
  final DateTime? completedAt;

  /// First persisted timestamp; null until persisted.
  final DateTime? createdAt;

  /// Last update timestamp; null until persisted.
  final DateTime? updatedAt;

  ServiceEntity copyWith({
    String? id,
    String? customerUuid,
    String? title,
    Object? description = _sentinel,
    ServiceStatus? status,
    double? price,
    List<String>? tags,
    Object? startedAt = _sentinel,
    Object? completedAt = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      customerUuid: customerUuid ?? this.customerUuid,
      title: title ?? this.title,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      status: status ?? this.status,
      price: price ?? this.price,
      tags: tags ?? this.tags,
      startedAt: identical(startedAt, _sentinel)
          ? this.startedAt
          : startedAt as DateTime?,
      completedAt: identical(completedAt, _sentinel)
          ? this.completedAt
          : completedAt as DateTime?,
      createdAt: identical(createdAt, _sentinel)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _sentinel)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceEntity &&
        other.id == id &&
        other.customerUuid == customerUuid &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.price == price &&
        _listEq(other.tags, tags) &&
        other.startedAt == startedAt &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        customerUuid,
        title,
        description,
        status,
        price,
        Object.hashAll(tags),
        startedAt,
        completedAt,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'ServiceEntity(id: $id, customerUuid: $customerUuid, '
      'title: $title, status: $status, price: $price)';
}

/// Lifecycle states for a [ServiceEntity]. Stored in Isar as a
/// `String` to keep the migration toolchain simple (typed enum
/// enums in Isar v3 have rough edges around serialization).
enum ServiceStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  /// Wire format used by the Isar collection.
  String get wire => name;

  /// Reverse lookup of [wire]. Defaults to [pending] when the
  /// stored value is unrecognised so we never throw on a single
  /// malformed row.
  static ServiceStatus fromWire(String? raw) {
    if (raw == null) return pending;
    for (final candidate in ServiceStatus.values) {
      if (candidate.wire == raw) return candidate;
    }
    return pending;
  }
}

const Object _sentinel = Object();

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
