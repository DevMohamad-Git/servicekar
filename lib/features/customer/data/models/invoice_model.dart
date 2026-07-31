/// Storage-layer representation of an Invoice (and its line items).
///
/// Mirrors `InvoiceEntity` / `InvoiceLineItemEntity` field-for-field
/// so the mapper stays trivial. Lives at the data-layer boundary —
/// never import from domain or presentation.
///
/// See `invoice_entity.dart` for the linking strategy
/// (String-FK `customerUuid`) and the Status-as-String wire mapping.
class InvoiceModel {
  const InvoiceModel({
    required this.id,
    required this.customerUuid,
    required this.invoiceNumber,
    required this.issueDate,
    this.dueDate,
    this.status = 'draft',
    this.lineItems = const <InvoiceLineItemModel>[],
    this.totalAmount = 0.0,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerUuid;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime? dueDate;

  /// Wire string for [InvoiceEntity.status]. String typedef so the
  /// Model knows nothing about the domain enum.
  final String status;

  final List<InvoiceLineItemModel> lineItems;
  final double totalAmount;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceModel &&
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
}

/// Storage-layer line item. Mirrors [InvoiceLineItemEntity]. Lives
/// inside the parent `InvoiceModel.lineItems` list and round-trips
/// through an `@embedded` Isar object — see `invoice_isar.dart`.
class InvoiceLineItemModel {
  const InvoiceLineItemModel({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.serviceUuid,
  });

  final String description;
  final double quantity;
  final double unitPrice;
  final double total;
  final String? serviceUuid;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceLineItemModel &&
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
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
