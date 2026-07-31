import '../../domain/entities/service_entity.dart';
import '../models/service_model.dart';

// Single source of truth for the Service Model ↔ Entity contract.
//
// Same layout as `customer_mapper.dart`: one private function per
// direction + two thin extensions. Add a field to either side and the
// analyzer points you straight here. The String-of-enum translation
// lives in [ServiceStatus.wire] / [ServiceStatus.fromWire] so this
// file stays Isar-free.
//
ServiceEntity _modelToEntity(ServiceModel m) => ServiceEntity(
      id: m.id,
      customerUuid: m.customerUuid,
      title: m.title,
      description: m.description,
      status: ServiceStatus.fromWire(m.status),
      price: m.price,
      tags: List<String>.unmodifiable(m.tags),
      startedAt: m.startedAt,
      completedAt: m.completedAt,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );

ServiceModel _entityToModel(ServiceEntity e) => ServiceModel(
      id: e.id,
      customerUuid: e.customerUuid,
      title: e.title,
      description: e.description,
      status: e.status.wire,
      price: e.price,
      tags: List<String>.of(e.tags),
      startedAt: e.startedAt,
      completedAt: e.completedAt,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );

/// Storage Model → domain Entity. Use at read boundaries (data → domain).
extension ServiceModelX on ServiceModel {
  ServiceEntity toEntity() => _modelToEntity(this);
}

/// Domain Entity → storage Model. Use at write boundaries (domain → data).
extension ServiceEntityX on ServiceEntity {
  ServiceModel toModel() => _entityToModel(this);
}
