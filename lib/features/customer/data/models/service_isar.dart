import 'package:isar_community/isar.dart';

part 'service_isar.g.dart';

/// Isar collection backing [ServiceModel] / [ServiceEntity].
///
/// Boundary lines (mirrors `customer_isar.dart`):
///
///   * [ServiceEntity]  — domain. Pure Dart. No I/O, no `isar_community`.
///   * [ServiceModel]   — data-layer POJO. Maps to/from the entity.
///   * [ServiceIsar]    — data-layer `@collection`. The only file in
///                          this feature, for this entity, that may
///                          import `package:isar_community/isar.dart`.
///
/// Conversions are owned by the data-layer mappers:
///   * `service_mapper.dart`       — Entity ↔ Model (Isar-free).
///   * `service_isar_mapper.dart`  — Model ↔ Isar (the bridge).
///
/// ─── Linking strategy ─────────────────────────────────────────────
/// `customerUuid` is a *plain String FK*, deliberately NOT
/// `IsarLink<CustomerIsar>`. Reasons:
///
///   1. `CustomerIsar.uuid` is `replace: true` + `Isar.autoIncrement`.
///      Re-importing a customer reallocates the internal int Id; an
///      `IsarLink` keyed on that int Id would silently detach.
///   2. String FKs survive the swap trivially and let per-customer
///      queries stay `where().customerUuidEqualTo(...)` — a single
///      constant-time index hit.
///
/// Indexes registered below:
///   * `uuid`         — unique, replace: true (mirrors CustomerIsar).
///   * `customerUuid` — non-unique, for per-customer history lookups.
///   * `status`       — non-unique, for filtering the history by phase.
///   * `startedAt`    — non-unique, for "history sorted by recency".
///
/// ─── Wire storage for [status] ─────────────────────────────────────
/// The domain enum [ServiceStatus] round-trips through its
/// `name` (a String). The mapper at `service_isar_mapper.dart`
/// owns that translation; this file just keeps a `String` column.
///
/// The link back to the customer is *not* enforced by Isar. The
/// repository layer is responsible for:
///   * Cascading delete when a Customer is removed (delete every
///     service with `customerUuid == X`).
///   * Refusing to persist a Service whose `customerUuid` has no
///     matching Customer row.
@collection
class ServiceIsar {
  /// Isar-managed primary key. Auto-increment on insert. Internal
  /// scaffolding — do NOT expose this through the domain layer.
  Id id = Isar.autoIncrement;

  /// Business-stable identifier. Maps 1:1 to [ServiceEntity.id].
  /// Indexed unique (`replace: true`) — see [CustomerIsar.uuid]
  /// for the rationale.
  @Index(unique: true, replace: true)
  late String uuid;

  /// FK to [CustomerIsar.uuid]. Indexed for per-customer lookup.
  @Index()
  late String customerUuid;

  /// Display title (e.g. "Oil change"). Indexed for search.
  @Index(caseSensitive: false)
  late String title;

  String? description;

  /// Wire string for [ServiceStatus]. See class header.
  @Index()
  late String status;

  /// Agreed / final price. See class header for the "not the live
  /// debt" note.
  late double price;

  /// Operator-defined tags for grouping / filtering.
  late List<String> tags;

  /// Indexed so "history sorted by recency" queries (`sort by
  /// startedAtDesc`) hit the index. Nullable so a not-yet-started
  /// service persists cleanly.
  @Index()
  DateTime? startedAt;

  DateTime? completedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
}
