/// Pure-Dart domain "Invoice" — a billable document issued to a
/// customer, with a fixed list of [InvoiceLineItemEntity] entries.
///
/// Linked to [CustomerEntity] via [customerUuid] using the same
/// String-FK strategy documented on [ServiceEntity]. See that file
/// for the rationale on String FKs vs `IsarLink`.
///
/// Debt derivation note ─────────────────────────────────────────────
/// An invoice is the *source of truth* on how much a customer owes:
/// the future `GetCustomerDebtUseCase` will compute
/// `sum(invoice.totalAmount) - sum(payment.amount)` grouped by
/// `customerUuid`. `InvoiceModel.totalAmount` is therefore the
/// canonical cached sum; if a caller mutates a line item, the
/// total must be recomputed by the use case / repository before
/// the row is `put`.
class InvoiceEntity {
  const InvoiceEntity({
    required this.id,
    required this.customerUuid,
    required this.invoiceNumber,
    required this.issueDate,
    this.dueDate,
    this.status = InvoiceStatus.draft,
    this.lineItems = const <InvoiceLineItemEntity>[],
    this.totalAmount = 0.0,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Stable identifier. UUID v4 is the recommended default; the data
  /// layer generates it when creating a new record.
  final String id;

  /// FK to [CustomerEntity.id]. Required, indexed.
  final String customerUuid;

  /// Operator-facing invoice number (e.g. `"INV-2026-0042"`).
  ///
  /// Stored as a String so global numbering, prefix schemes, and
  /// regionalisation stay under programmer control. Indexed unique
  /// when combined with [customerUuid] to prevent dupes from being
  /// typed twice.
  final String invoiceNumber;

  /// When the invoice was issued.
  final DateTime issueDate;

  /// Optional payment-due date (null = "no hard deadline").
  final DateTime? dueDate;

  /// Lifecycle state. Wire-storage as `String` (see
  /// [ServiceStatus] for the same reasoning).
  final InvoiceStatus status;

  /// Line items that compose the invoice's total. The list is
  /// *immutable by convention*; the use-case layer must `copyWith`
  /// the entity to add/remove items.
  final List<InvoiceLineItemEntity> lineItems;

  /// Cached `sum(lineItem.total)`. Recomputed by the use case on
  /// every mutation; persisted in the row so debt derivation can
  /// run without re-summing every line item on read.
  final double totalAmount;

  /// Optional operator notes attached to the whole invoice.
  final String? notes;

  /// First persisted timestamp; null until persisted.
  final DateTime? createdAt;

  /// Last update timestamp; null until persisted.
  final DateTime? updatedAt;

  InvoiceEntity copyWith({
    String? id,
    String? customerUuid,
    String? invoiceNumber,
    DateTime? issueDate,
    Object? dueDate = _sentinel,
    InvoiceStatus? status,
    List<InvoiceLineItemEntity>? lineItems,
    double? totalAmount,
    Object? notes = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      customerUuid: customerUuid ?? this.customerUuid,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate:
          identical(dueDate, _sentinel) ? this.dueDate : dueDate as DateTime?,
      status: status ?? this.status,
      lineItems: lineItems ?? this.lineItems,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: identical(notes, _sentinel) ? this.notes : notes as String?,
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
    return other is InvoiceEntity &&
        other.id == id &&
        other.customerUuid == customerUuid &&
        other.invoiceNumber == invoiceNumber &&
        other.issueDate == issueDate &&
        other.dueDate == dueDate &&
        other.status == status &&
        _listEq(other.lineItems, lineItems) &&
        other.totalAmount == totalAmount &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        customerUuid,
        invoiceNumber,
        issueDate,
        dueDate,
        status,
        Object.hashAll(lineItems),
        totalAmount,
        notes,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'InvoiceEntity(id: $id, customerUuid: $customerUuid, '
      'number: $invoiceNumber, amount: $totalAmount, status: $status)';
}

/// Lifecycle states for an [InvoiceEntity].
enum InvoiceStatus {
  draft,
  issued,
  paid,
  overdue,
  cancelled;

  String get wire => name;

  static InvoiceStatus fromWire(String? raw) {
    if (raw == null) return draft;
    for (final candidate in InvoiceStatus.values) {
      if (candidate.wire == raw) return candidate;
    }
    return draft;
  }
}

/// A single billable line on an Invoice. Immutable (construct +
/// copyWith). The "total" field is the recanonicalised
/// `quantity * unitPrice` snapshot taken at write time so the
/// invoice total stays stable even if upstream prices change.
class InvoiceLineItemEntity {
  const InvoiceLineItemEntity({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.serviceUuid,
  });

  /// Human-readable line label (e.g. "Oil change"). Required.
  final String description;

  /// Quantity. Stored as a double so fractional units (hours,
  /// litres) round-trip without binary→fractional conversion loss.
  final double quantity;

  /// Price-per-unit at write-time.
  final double unitPrice;

  /// Cached `quantity * unitPrice`. Recomputed by the use case on
  /// any mutation; persisted so the invoice's `totalAmount` is a
  /// simple `sum(line.total)` and never re-runs arithmetic at read
  /// time.
  final double total;

  /// Optional FK back to a [ServiceEntity.id]. Lets the invoice
  /// line point at the originating service for traceability; the
  /// service itself remains authored under the customer profile.
  final String? serviceUuid;

  InvoiceLineItemEntity copyWith({
    String? description,
    double? quantity,
    double? unitPrice,
    double? total,
    Object? serviceUuid = _sentinel,
  }) {
    return InvoiceLineItemEntity(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      serviceUuid: identical(serviceUuid, _sentinel)
          ? this.serviceUuid
          : serviceUuid as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceLineItemEntity &&
        other.description == description &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.total == total &&
        other.serviceUuid == serviceUuid;
  }

  @override
  int get hashCode => Object.hash(
        description,
        quantity,
        unitPrice,
        total,
        serviceUuid,
      );

  @override
  String toString() =>
      'InvoiceLineItemEntity(description: $description, '
      'quantity: $quantity, unitPrice: $unitPrice, total: $total)';
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
