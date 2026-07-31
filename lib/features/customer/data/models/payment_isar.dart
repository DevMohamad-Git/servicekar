import 'package:isar_community/isar.dart';

part 'payment_isar.g.dart';

/// Isar collection backing [PaymentModel] / [PaymentEntity].
///
/// Same boundary-line discipline as
/// `customer_isar.dart` / `service_isar.dart` / `invoice_isar.dart`:
///
///   * [PaymentEntity]  — domain. Pure Dart.
///   * [PaymentModel]   — data-layer POJO.
///   * [PaymentIsar]    — data-layer `@collection`.
///
/// Conversions are owned by the data-layer mappers:
///   * `payment_mapper.dart`       — Entity ↔ Model (Isar-free).
///   * `payment_isar_mapper.dart`  — Model ↔ Isar (the bridge).
///
/// ─── Linking strategy ─────────────────────────────────────────────
/// Plain String FKs to Customer (required) and Invoice (optional).
/// See `customer_isar.dart` for the global rationale on String FKs
/// vs `IsarLink`.
///
/// Indexes registered below:
///   * `uuid`         — unique, replace: true.
///   * `customerUuid` — non-unique, per-customer payment history.
///   * `invoiceUuid`  — **non-unique**, nullable column is fine for
///                      an index (Isar treats `null` as a single
///                      key-space entry). Per-invoice payment
///                      listings become a constant-time index hit.
///   * `paidAt`       — non-unique, sort-by-recency.
///
/// ─── Wire storage for [method] ─────────────────────────────────────
/// Same String-of-enum strategy as [ServiceIsar.status]. Mapper
/// translates.
///
/// ─── Cascading delete / orphan policy ─────────────────────────────
/// Same caveat as the other linked collections: the FK is a plain
/// `String`, so Isar does not auto-cascade. Repository layer
/// responsibility:
///   * Refusing to persist a Payment whose `customerUuid` has no
///     matching Customer row.
///   * For invoices with FKs: refusing to persist a Payment whose
///     `invoiceUuid` is non-null but doesn't match an Invoice row.
///   * Cascading delete for the parent rows.
@collection
class PaymentIsar {
  /// Isar-managed primary key. Auto-increment on insert. Internal
  /// scaffolding.
  Id id = Isar.autoIncrement;

  /// Business-stable identifier. Maps 1:1 to [PaymentEntity.id].
  @Index(unique: true, replace: true)
  late String uuid;

  /// FK to [CustomerIsar.uuid]. Indexed.
  @Index()
  late String customerUuid;

  /// Optional FK to [InvoiceIsar.uuid]. Indexed (nullable, but no
  /// uniqueness — one Invoice can be paid in multiple Payments).
  @Index()
  String? invoiceUuid;

  /// Non-negative cash received. Range-filtered via Isar double
  /// filters at read time; not a separate index (ad-hoc queries
  /// only).
  late double amount;

  /// When the payment was received. Indexed for sort-by-recency
  /// and "payments between A and B" range filters.
  @Index()
  late DateTime paidAt;

  /// Wire string for [PaymentMethod]. See class header.
  late String method;

  String? note;
  DateTime? createdAt;
  DateTime? updatedAt;
}
