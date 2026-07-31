import '../models/invoice_isar.dart';
import '../models/invoice_model.dart';

/// Single source of truth for the **Invoice Model ↔ Isar** contract.
///
/// Mirrors `customer_isar_mapper.dart`: two private functions own the
/// conversion; two extensions expose them. The internal Isar `Id`
/// is `Isar.autoIncrement` on the way in and deliberately dropped
/// on the way back — domain uses `uuid`.
///
/// The line-item list round-trip deserves its own pair of helpers
/// (below) because the storage shape (`InvoiceLineItemIsar`) is an
/// `@embedded` object while the data-layer shape
/// (`InvoiceLineItemModel`) is a plain POJO.
InvoiceIsar _modelToIsar(InvoiceModel m) => InvoiceIsar()
      // `id` left at the `Isar.autoIncrement` initializer on purpose.
      ..uuid = m.id
      ..customerUuid = m.customerUuid
      ..invoiceNumber = m.invoiceNumber
      ..issueDate = m.issueDate
      ..dueDate = m.dueDate
      ..status = m.status
      ..lineItems = List<InvoiceLineItemIsar>.of(
        m.lineItems.map(_lineItemModelToIsar),
      )
      ..totalAmount = m.totalAmount
      ..notes = m.notes
      ..createdAt = m.createdAt
      ..updatedAt = m.updatedAt;

InvoiceModel _isarToModel(InvoiceIsar i) => InvoiceModel(
      // Internal `Id` deliberately dropped — domain uses `uuid`.
      id: i.uuid,
      customerUuid: i.customerUuid,
      invoiceNumber: i.invoiceNumber,
      issueDate: i.issueDate,
      dueDate: i.dueDate,
      status: i.status,
      // Defensive copy: Isar's list-of-embedded properties are
      // live "views" backed by the underlying storage.
      lineItems: List<InvoiceLineItemModel>.unmodifiable(
        i.lineItems.map(_lineItemIsarToModel),
      ),
      totalAmount: i.totalAmount,
      notes: i.notes,
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    );

InvoiceLineItemIsar _lineItemModelToIsar(InvoiceLineItemModel m) =>
    InvoiceLineItemIsar()
      ..description = m.description
      ..quantity = m.quantity
      ..unitPrice = m.unitPrice
      ..total = m.total
      ..serviceUuid = m.serviceUuid;

InvoiceLineItemModel _lineItemIsarToModel(InvoiceLineItemIsar i) =>
    InvoiceLineItemModel(
      description: i.description,
      quantity: i.quantity,
      unitPrice: i.unitPrice,
      total: i.total,
      serviceUuid: i.serviceUuid,
    );

/// Storage POJO → Isar collection. Use at write boundaries.
extension InvoiceModelToIsar on InvoiceModel {
  InvoiceIsar toIsar() => _modelToIsar(this);
}

/// Isar collection → storage POJO. Use at read boundaries.
extension InvoiceIsarToModel on InvoiceIsar {
  InvoiceModel toModel() => _isarToModel(this);
}
