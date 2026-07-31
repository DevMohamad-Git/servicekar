/// Pure-Dart domain "Payment" — money received against a customer's
/// account. Linked to [CustomerEntity] via [customerUuid]; linked to
/// [InvoiceEntity] via [invoiceUuid] *optionally* so that "on-account"
/// / "advance" payments (cash in before any specific invoice is
/// issued) do not require forging a dummy invoice.
///
/// Same String-FK linking strategy as
/// [ServiceEntity]/[InvoiceEntity]. See those for the
/// IsarLink-vs-String rationale.
///
/// Debt-sign convention ──────────────────────────────────────────────
/// [amount] is always a non-negative real number. Sign is *not* used
/// to distinguish inflow vs refund — refunds will be modelled as a
/// separate `RefundEntity` (or a future flag on Payment) so the debt
/// derivation arithmetic stays clean: `sum(payment.amount)` always
/// reduces the customer's debt, regardless of direction-of-cash.
///
/// Payment-vs-invoice wiring ──────────────────────────────────────────
/// `invoiceUuid == null` means the payment is *not* tied to a
/// specific invoice:
///   * On-account advance: customer prepays against future work.
///   * Standing deposit: customer leaves a running balance.
/// `invoiceUuid != null` means the payment settles a specific
/// invoice (or part of it). The repository layer is responsible for
/// enforcing `sum(payments.where(invoiceUuid == invoiceId).amount)
/// <= invoice.totalAmount` if so desired; that's a business rule
/// out of scope for the schema foundation.
class PaymentEntity {
  const PaymentEntity({
    required this.id,
    required this.customerUuid,
    required this.amount,
    required this.paidAt,
    this.invoiceUuid,
    this.method = PaymentMethod.cash,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  /// Stable identifier. UUID v4 is the recommended default; the data
  /// layer generates it when creating a new record.
  final String id;

  /// FK to [CustomerEntity.id]. Required, indexed.
  final String customerUuid;

  /// FK to [InvoiceEntity.id]. Optional — see the class header for
  /// the "on-account" rationale. Indexed so per-invoice payment
  /// listings hit the index.
  final String? invoiceUuid;

  /// Non-negative cash value received. Always positive; refunds are
  /// a future, separate concern. Indexed range queries (amount
  /// between A and B) will use the regular Isar double filter, not
  /// a separate index, because the column space is dense and the
  /// operations are ad-hoc.
  final double amount;

  /// When the payment was actually received. Indexed so per-customer
  /// and per-invoice payment histories can sort by recency without
  /// re-reading the whole collection.
  final DateTime paidAt;

  /// How the payment was received. Stored as the `String` form of
  /// [PaymentMethod] for the same wire-storage reasoning as
  /// [ServiceStatus].
  final PaymentMethod method;

  /// Optional operator note (e.g. "late, partial", "transfer ref
  /// 12345").
  final String? note;

  /// First persisted timestamp; null until persisted.
  final DateTime? createdAt;

  /// Last update timestamp; null until persisted.
  final DateTime? updatedAt;

  PaymentEntity copyWith({
    String? id,
    String? customerUuid,
    Object? invoiceUuid = _sentinel,
    double? amount,
    DateTime? paidAt,
    PaymentMethod? method,
    Object? note = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      customerUuid: customerUuid ?? this.customerUuid,
      invoiceUuid: identical(invoiceUuid, _sentinel)
          ? this.invoiceUuid
          : invoiceUuid as String?,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      method: method ?? this.method,
      note: identical(note, _sentinel) ? this.note : note as String?,
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
    return other is PaymentEntity &&
        other.id == id &&
        other.customerUuid == customerUuid &&
        other.invoiceUuid == invoiceUuid &&
        other.amount == amount &&
        other.paidAt == paidAt &&
        other.method == method &&
        other.note == note &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        customerUuid,
        invoiceUuid,
        amount,
        paidAt,
        method,
        note,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'PaymentEntity(id: $id, customerUuid: $customerUuid, '
      'invoiceUuid: $invoiceUuid, amount: $amount, method: $method)';
}

/// How a [PaymentEntity] was received. Wire-storage as `String` —
/// see [ServiceStatus] for the rationale.
enum PaymentMethod {
  cash,
  card,
  transfer,
  cheque,
  other;

  String get wire => name;

  static PaymentMethod fromWire(String? raw) {
    if (raw == null) return cash;
    for (final candidate in PaymentMethod.values) {
      if (candidate.wire == raw) return candidate;
    }
    return cash;
  }
}

const Object _sentinel = Object();
