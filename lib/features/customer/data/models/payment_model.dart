/// Storage-layer representation of a Payment.
///
/// Mirrors `PaymentEntity` field-for-field so the mapper stays trivial.
/// Lives at the data-layer boundary — never import this from domain or
/// presentation code.
///
/// See `payment_entity.dart` for the linking strategy
/// (nullable String-FK `invoiceUuid`) and the Method-as-String wire
/// mapping.
class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.customerUuid,
    required this.amount,
    required this.paidAt,
    this.invoiceUuid,
    this.method = 'cash',
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerUuid;
  final String? invoiceUuid;
  final double amount;
  final DateTime paidAt;

  /// Wire string for [PaymentEntity.method]. String typedef keeps
  /// the Model free of domain-enum imports.
  final String method;

  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel &&
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
}
