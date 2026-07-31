import 'package:isar_community/isar.dart';

part 'invoice_isar.g.dart';

/// Isar collection backing [InvoiceModel] / [InvoiceEntity].
///
/// Mirrors the boundary lines of `customer_isar.dart` / `service_isar.dart`:
///
///   * [InvoiceEntity]           — domain. Pure Dart.
///   * [InvoiceModel]            — data-layer POJO.
///   * [InvoiceIsar]             — data-layer `@collection`.
///   * [InvoiceLineItemModel]    — POJO for line items.
///   * [InvoiceLineItemIsar]     — `@embedded` line-item row.
///
/// Conversions are owned by the data-layer mappers:
///   * `invoice_mapper.dart`       — Entity ↔ Model (Isar-free).
///   * `invoice_isar_mapper.dart`  — Model ↔ Isar (the bridge).
///
/// ─── Linking strategy ─────────────────────────────────────────────
/// Same String-FK pattern as [ServiceIsar.customerUuid]. See that
/// file for the rationale (avoiding the `IsarLink` +
/// `replace: true` detachment bug on `CustomerIsar`).
///
/// Indexes registered below:
///   * `uuid`                  — unique, replace: true.
///   * `customerUuid`          — non-unique, per-customer history.
///   * `issueDate`             — non-unique, sort-by-recency.
///   * `status`                — non-unique, filter-by-state.
///   * composite (uuid)
///     `customerUuid + invoiceNumber` is enforced at the repository
///     layer; Isar v3 composite uniqueness over multiple properties
///     is fine but rarely needed when the surrogate `uuid` is
///     already unique. We keep the field unique at semantics level
///     (not index) so a future schema migration can flip it on.
///
/// ─── Line items as `@embedded` ─────────────────────────────────────
/// Parallel lists (`List<String> description`, `List<double> qty`,
/// …) were considered and rejected: if any one parallel index
/// desyncs from its siblings, the row is silently corrupted.
/// `@embedded` classes get their own nested schema (managed by Isar
/// at serialization time) that always preserves the *one-line =
/// one-object* invariant. They are still cheap — they have no
/// `Id`, no index, no link — just an inline typed record.
///
/// ─── Wire storage for [status] ─────────────────────────────────────
/// Same String-of-enum strategy as [ServiceIsar.status]. Mapper
/// translates.
///
/// ─── Cascading delete / orphan policy ─────────────────────────────
/// Same caveat as [ServiceIsar]: the FK is a plain `String` so Isar
/// does not auto-cascade. The repository layer is responsible for:
///   * Refusing to persist an Invoice whose `customerUuid` has no
///     matching Customer row.
///   * Deleting every `InvoiceIsar` whose `customerUuid` matches a
///     deleted Customer.
@collection
class InvoiceIsar {
  /// Isar-managed primary key. Auto-increment on insert. Internal
  /// scaffolding.
  Id id = Isar.autoIncrement;

  /// Business-stable identifier. Maps 1:1 to [InvoiceEntity.id].
  @Index(unique: true, replace: true)
  late String uuid;

  /// FK to [CustomerIsar.uuid]. Indexed.
  @Index()
  late String customerUuid;

  /// Operator-facing invoice number. NOT a unique index in this
  /// collection (cross-customer uniqueness is enforced at the
  /// business-rule layer, not the schema). Indexed for search.
  @Index(caseSensitive: false)
  late String invoiceNumber;

  /// Invoice issue date. Indexed for "by month / by year" lookups
  /// and for "latest first" sorting.
  @Index()
  late DateTime issueDate;

  DateTime? dueDate;

  /// Wire string for [InvoiceStatus]. Indexed so dashboards can
  /// count rows by status without a full scan.
  @Index()
  late String status;

  /// Line items stored as inline `@embedded` records. See the
  /// class header for the rationale.
  late List<InvoiceLineItemIsar> lineItems;

  /// Cached `sum(lineItem.total)`. See [InvoiceEntity.totalAmount].
  late double totalAmount;

  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;
}

/// Isar `@embedded` line item — inline, no Id, no index, no link.
///
/// Lives inside [InvoiceIsar.lineItems]. Round-trips through the
/// mapper (Model ↔ Isar) with a free-of-domain-imports contract.
@embedded
class InvoiceLineItemIsar {
  String description = '';
  double quantity = 0.0;
  double unitPrice = 0.0;
  double total = 0.0;
  String? serviceUuid;
}
