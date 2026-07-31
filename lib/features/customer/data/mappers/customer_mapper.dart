import '../../domain/entities/customer_entity.dart';
import '../models/customer_model.dart';

// Single source of truth for the Model ↔ Entity contract.
//
// Keeping the conversion in *one place* (these private functions) makes
// it impossible for the two extensions below and any future caller to
// drift: add a field to either side, regenerate the Freezed factory,
// and the analyzer points you straight here.
//
// The `balance` field used to flow Entity ↔ Model here; it now lives
// only on the deprecated `CustomerIsar.balance` column and is ignored
// by both sides of this mapper.
//
CustomerEntity _modelToEntity(CustomerModel m) => CustomerEntity(
  id: m.id,
  fullName: m.fullName,
  phoneNumber: m.phoneNumber,
  email: m.email,
  address: m.address,
  notes: m.notes,
  profileImagePath: m.profileImagePath,
  nationalId: m.nationalId,
  birthday: m.birthday,
  gender: m.gender,
  tags: List<String>.unmodifiable(m.tags),
  createdAt: m.createdAt,
  updatedAt: m.updatedAt,
);

CustomerModel _entityToModel(CustomerEntity e) => CustomerModel(
  id: e.id,
  fullName: e.fullName,
  phoneNumber: e.phoneNumber,
  email: e.email,
  address: e.address,
  notes: e.notes,
  profileImagePath: e.profileImagePath,
  nationalId: e.nationalId,
  birthday: e.birthday,
  gender: e.gender,
  tags: List<String>.of(e.tags),
  createdAt: e.createdAt,
  updatedAt: e.updatedAt,
);

/// Storage Model → domain Entity. Use at read boundaries (data → domain).
extension CustomerModelX on CustomerModel {
  CustomerEntity toEntity() => _modelToEntity(this);
}

/// Domain Entity → storage Model. Use at write boundaries (domain → data).
extension CustomerEntityX on CustomerEntity {
  CustomerModel toModel() => _entityToModel(this);
}
