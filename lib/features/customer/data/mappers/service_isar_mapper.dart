import '../models/service_isar.dart';
import '../models/service_model.dart';

/// Single source of truth for the **Service Model ↔ Isar** contract.
///
/// Mirrors the layout of `customer_isar_mapper.dart`:
///   - Two private functions own the conversion (model→isar, isar→model).
///   - Two thin extensions expose them at the field-level boundary.
///   - The internal Isar `Id` is `Isar.autoIncrement` on the way in and
///     deliberately dropped on the way back — domain uses `uuid`.
ServiceIsar _modelToIsar(ServiceModel m) => ServiceIsar()
      // `id` left at the `Isar.autoIncrement` initializer on purpose.
      ..uuid = m.id
      ..customerUuid = m.customerUuid
      ..title = m.title
      ..description = m.description
      ..status = m.status
      ..price = m.price
      // Defensive copy so the consumer cannot mutate the underlying
      // Isar list through the Model once we hand it back.
      ..tags = List<String>.of(m.tags)
      ..startedAt = m.startedAt
      ..completedAt = m.completedAt
      ..createdAt = m.createdAt
      ..updatedAt = m.updatedAt;

ServiceModel _isarToModel(ServiceIsar i) => ServiceModel(
      // Internal `Id` deliberately dropped — domain uses `uuid`.
      id: i.uuid,
      customerUuid: i.customerUuid,
      title: i.title,
      description: i.description,
      status: i.status,
      price: i.price,
      // Defensive copy: Isar's list properties are live "views"
      // backed by the underlying storage.
      tags: List<String>.of(i.tags),
      startedAt: i.startedAt,
      completedAt: i.completedAt,
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    );

/// Storage POJO → Isar collection. Use at write boundaries.
extension ServiceModelToIsar on ServiceModel {
  ServiceIsar toIsar() => _modelToIsar(this);
}

/// Isar collection → storage POJO. Use at read boundaries.
extension ServiceIsarToModel on ServiceIsar {
  ServiceModel toModel() => _isarToModel(this);
}
