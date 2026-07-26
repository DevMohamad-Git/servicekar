import 'package:isar_community/isar.dart';

part 'customer_isar.g.dart';

/// Isar collection backing [CustomerModel] / [CustomerEntity].
///
/// Boundary lines — kept strict so the domain never sees Isar:
///
///   * [CustomerEntity] — domain. Pure Dart. No I/O, no `isar_community`.
///   * [CustomerModel]  — data-layer POJO. Maps to/from the entity.
///   * [CustomerIsar]   — data-layer `@collection`. The only file in
///                          the customer feature that may import
///                          `package:isar_community/isar.dart`.
///
/// Conversions are owned by the data-layer mappers:
///   * `customer_mapper.dart`      — Entity ↔ Model (Isar-free).
///   * `customer_isar_mapper.dart` — Model ↔ Isar (the bridge).
/// This file stays a flat Isar schema with no Flutter, no freezed, and
/// no domain dependency beyond the entity it shadows.
///
/// ─── Future-schema gotcha: `replace: true` + `Isar.autoIncrement` ──
///   Today the only `replace: true` index lives on [uuid]. When a
///   record with a duplicate uuid is `put`, Isar resolves the
///   conflict by **deleting the old row and inserting a new one**
///   under the same uuid but a freshly-allocated internal [Id].
///   This is safe for the customer table in isolation, but if a
///   future feature (Service / Invoice / Payment) ever wires an
///   `IsarLink<CustomerIsar>` against the internal `Id`, those
///   links will silently detach on every re-import. When that
///   day comes, switch to a manual upsert: query the existing row,
///   preserve its `Id`, mutate the in-memory copy, and `put` it
///   again — DO NOT rely on `replace: true` with a freshly-built
///   `CustomerIsar()`.
///
/// ─── ID strategy (forced by the existing domain contract + Isar's
///     rules; documented here so the next engineer does not "simplify"
///     it without understanding what it does) ────────────────────────
///   * [id]   — Isar auto-increment [Id] (`int`). Internal only.
///               Never surfaced through the domain or repository so
///               that future schema migrations (composite keys,
///               cross-feature links, sync) can reshape the physical
///               storage without disturbing [CustomerEntity.id]. Lets
///               Isar manage physical ordering and link resolution
///               cheaply.
///   * [uuid] — Stable `String` identifier that maps 1:1 to
///               [CustomerEntity.id]. Unique + `replace: true` so
///               re-importing the same customer overwrites the
///               existing row instead of creating a duplicate, and
///               so the domain "lookup by id" path stays a constant-
///               time index hit instead of a full collection scan.
///
/// Why two IDs:
///   * [CustomerEntity.id] is hard-typed as `String` (see
///     `lib/features/customer/domain/entities/customer_entity.dart`)
///     and is used as the lookup key by `GetCustomerByIdUseCase`,
///     `UpdateCustomerUseCase`, `DeleteCustomerUseCase`, and
///     `GetCustomerBalanceUseCase`. Changing it would break the
///     domain contract for every caller; the comment on that field
///     already declares "UUID v4 is the recommended default".
///   * Isar v3's primary-key type [Id] is `int` — it cannot hold a
///     `String` UUID without distorting the cardinality that
///     `Isar.open` expects.
///   * The clean fix is an internal auto-increment Id (for Isar)
///     paired with a unique-indexed `String uuid` (for the domain).
///
/// Today's UUID source is the placeholder
/// `'cus_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'`
/// generator in `lib/presentation/customer/pages/create_customer_page.dart`.
/// Migrating to a real UUID v4 is intentionally out of scope for this
/// file and requires a separate package decision in `pubspec.yaml`.
@collection
class CustomerIsar {
  /// Isar-managed primary key. Auto-increment on insert. Internal
  /// scaffolding — do NOT expose this through the domain layer.
  Id id = Isar.autoIncrement;

  /// Business-stable identifier. Maps 1:1 to [CustomerEntity.id].
  ///
  /// Indexed unique (`replace: true`) so:
  ///   * domain lookups by id hit the index in O(log n);
  ///   * re-importing a record with the same uuid overwrites the
  ///     existing row instead of creating a duplicate.
  @Index(unique: true, replace: true)
  late String uuid;

  /// Display name. Indexed so the search bar's `contains` filter —
  /// `SearchCustomersUseCase` falls back to `GetCustomersUseCase` on
  /// empty queries and otherwise scans across `fullName` /
  /// `phoneNumber` / `email` / `notes` — can use Isar's indexed-
  /// string filters (`fullNameContains(...)`) without a full
  /// collection scan.
  ///
  /// `caseSensitive: false` because Latin-letter names are user-
  /// typed and must match regardless of casing. Persian text has no
  /// case distinction so this flag is a no-op for fa content but
  /// valuable for any Latin-script customers in the DB.
  @Index(caseSensitive: false)
  late String fullName;

  /// Primary phone number. Indexed for the search bar's `contains`
  /// filter on digits. (`caseSensitive` is irrelevant for digits but
  /// left implicit-false for consistency with [fullName].)
  @Index()
  late String phoneNumber;

  String? email;
  String? address;
  String? notes;

  /// Outstanding balance in local currency. Positive = customer
  /// owes the business.
  late double balance;

  /// Operator-defined tags for grouping / filtering. Stored as a
  /// native Isar list — no extra annotations needed.
  late List<String> tags;

  /// First persisted timestamp. Nullable to mirror [CustomerEntity]
  /// and [CustomerModel]; a freshly-built `CustomerIsar` can therefore
  /// carry `null` until the mapper hydrates it on a successful save.
  DateTime? createdAt;

  /// Last update timestamp. Nullable for the same reason as
  /// [createdAt].
  DateTime? updatedAt;
}
