import '../models/payment_isar.dart';
import '../models/payment_model.dart';

/// Single source of truth for the **Payment Model ↔ Isar** contract.
///
/// Mirrors `customer_isar_mapper.dart`: two private functions own
/// the conversion; two extensions expose them. The internal Isar
/// `Id` is `Isar.autoIncrement` on the way in and deliberately
/// dropped on the way back — domain uses `uuid`.
PaymentIsar _modelToIsar(PaymentModel m) => PaymentIsar()
      // `id` left at the `Isar.autoIncrement` initializer on purpose.
      ..uuid = m.id
      ..customerUuid = m.customerUuid
      ..invoiceUuid = m.invoiceUuid
      ..amount = m.amount
      ..paidAt = m.paidAt
      ..method = m.method
      ..note = m.note
      ..createdAt = m.createdAt
      ..updatedAt = m.updatedAt;

PaymentModel _isarToModel(PaymentIsar i) => PaymentModel(
      // Internal `Id` deliberately dropped — domain uses `uuid`.
      id: i.uuid,
      customerUuid: i.customerUuid,
      invoiceUuid: i.invoiceUuid,
      amount: i.amount,
      paidAt: i.paidAt,
      method: i.method,
      note: i.note,
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    );

/// Storage POJO → Isar collection. Use at write boundaries.
extension PaymentModelToIsar on PaymentModel {
  PaymentIsar toIsar() => _modelToIsar(this);
}

/// Isar collection → storage POJO. Use at read boundaries.
extension PaymentIsarToModel on PaymentIsar {
  PaymentModel toModel() => _isarToModel(this);
}
