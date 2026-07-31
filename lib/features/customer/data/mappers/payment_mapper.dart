import '../../domain/entities/payment_entity.dart';
import '../models/payment_model.dart';

// Single source of truth for the Payment Model ↔ Entity contract.
//
// The `invoiceUuid` field is nullable (on-account payments), so
// the mapper is a plain pass-through — both Model and Entity use
// `String?` and `null` is unambiguous at this boundary. The
// `identical(sentinel) ? : as T?` dance lives ONLY in
// [PaymentEntity.copyWith] so a caller can distinguish
// "preserve" from "clear" on a nullable FK; the mapper never has
// to make that distinction.
//
PaymentEntity _modelToEntity(PaymentModel m) => PaymentEntity(
      id: m.id,
      customerUuid: m.customerUuid,
      invoiceUuid: m.invoiceUuid,
      amount: m.amount,
      paidAt: m.paidAt,
      method: PaymentMethod.fromWire(m.method),
      note: m.note,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );

PaymentModel _entityToModel(PaymentEntity e) => PaymentModel(
      id: e.id,
      customerUuid: e.customerUuid,
      invoiceUuid: e.invoiceUuid,
      amount: e.amount,
      paidAt: e.paidAt,
      method: e.method.wire,
      note: e.note,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );

/// Storage Model → domain Entity.
extension PaymentModelX on PaymentModel {
  PaymentEntity toEntity() => _modelToEntity(this);
}

/// Domain Entity → storage Model.
extension PaymentEntityX on PaymentEntity {
  PaymentModel toModel() => _entityToModel(this);
}
