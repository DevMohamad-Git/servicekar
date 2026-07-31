import '../../domain/entities/invoice_entity.dart';
import '../models/invoice_model.dart';

// Single source of truth for the Invoice Model ↔ Entity contract.
//
// Same layout as the customer / service mappers. The line-item
// sub-mapper is a separate private block because the domain type
// ([InvoiceLineItemEntity]) and the storage type
// ([InvoiceLineItemModel]) are siblings, not nested — round-trip
// must rehydrate the whole list at once.
//
// List copy is defensive: `List<String>.unmodifiable(...)` on the
// way out keeps the entity immutable; `List.of(...)` on the way in
// hands the storage POJO its own mutable list.
//
InvoiceEntity _modelToEntity(InvoiceModel m) => InvoiceEntity(
      id: m.id,
      customerUuid: m.customerUuid,
      invoiceNumber: m.invoiceNumber,
      issueDate: m.issueDate,
      dueDate: m.dueDate,
      status: InvoiceStatus.fromWire(m.status),
      lineItems: List<InvoiceLineItemEntity>.unmodifiable(
        m.lineItems.map(_lineItemModelToEntity),
      ),
      totalAmount: m.totalAmount,
      notes: m.notes,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );

InvoiceModel _entityToModel(InvoiceEntity e) => InvoiceModel(
      id: e.id,
      customerUuid: e.customerUuid,
      invoiceNumber: e.invoiceNumber,
      issueDate: e.issueDate,
      dueDate: e.dueDate,
      status: e.status.wire,
      lineItems: List<InvoiceLineItemModel>.unmodifiable(
        e.lineItems.map(_lineItemEntityToModel),
      ),
      totalAmount: e.totalAmount,
      notes: e.notes,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );

InvoiceLineItemEntity _lineItemModelToEntity(InvoiceLineItemModel m) =>
    InvoiceLineItemEntity(
      description: m.description,
      quantity: m.quantity,
      unitPrice: m.unitPrice,
      total: m.total,
      serviceUuid: m.serviceUuid,
    );

InvoiceLineItemModel _lineItemEntityToModel(InvoiceLineItemEntity e) =>
    InvoiceLineItemModel(
      description: e.description,
      quantity: e.quantity,
      unitPrice: e.unitPrice,
      total: e.total,
      serviceUuid: e.serviceUuid,
    );

/// Storage Model → domain Entity.
extension InvoiceModelX on InvoiceModel {
  InvoiceEntity toEntity() => _modelToEntity(this);
}

/// Domain Entity → storage Model.
extension InvoiceEntityX on InvoiceEntity {
  InvoiceModel toModel() => _entityToModel(this);
}
