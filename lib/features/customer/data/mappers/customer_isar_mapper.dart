import '../models/customer_isar.dart';
import '../models/customer_model.dart';

/// Single source of truth for the **Model ↔ Isar** contract.
///
/// Why a separate file from `customer_mapper.dart`:
///   * Keeps the Entity ↔ Model mapper completely Isar-free — any
///     surface that imports the entity mapper never transitively
///     pulls `package:isar_community/isar.dart`.
///   * Mirrors the one-mapper-per-boundary layout: one mapper per
///     layer transition keeps each file's responsibility narrow
///     and the dependencies in each `import` block honest.
///
/// Boundary lines (kept strict so the domain never sees Isar):
///   * [CustomerEntity] — domain. Pure Dart. No I/O, no
///     `isar_community` import.
///   * [CustomerModel]  — data-layer POJO. Maps to/from the entity
///     via `customer_mapper.dart`.
///   * [CustomerIsar]   — data-layer `@collection`. The only file in
///     this feature that imports `package:isar_community/isar.dart`.
///
/// This file is the *only* place where the storage POJO and the Isar
/// collection meet. Add a field to either side, regenerate the Isar
/// schema with `dart run build_runner build`, and the analyzer will
/// point you straight here.
///
/// ID round-trip rules (mirrors `CustomerIsar`'s ID strategy):
///   * Model → Isar: the business key [CustomerModel.id] becomes
///     `CustomerIsar.uuid`. The internal `CustomerIsar.id` is *not*
///     set by the mapper — its `Isar.autoIncrement` sentinel stays
///     in place so Isar allocates a fresh primary key on insert.
///   * Isar → Model: `CustomerIsar.uuid` becomes [CustomerModel.id].
///     The internal `CustomerIsar.id` is *deliberately discarded*
///     — domain code never sees it.
///
/// ─── Balance (deprecated column) ───────────────────────────────────
/// CustomerIsar.balance is preserved on the schema for backwards
/// compatibility with pre-migration DBs. This mapper no longer
/// reads or writes it: the cached field has no write path, so
/// keeping it flowing would mask the architectural problem rather
/// than solve it. The column's bytes linger on disk until a future
/// manual migration drops it; that work is intentionally out of
/// scope for this task.
CustomerIsar _modelToIsar(CustomerModel m) => CustomerIsar()
  // `id` left at its `Isar.autoIncrement` initializer on purpose
  // — see the ID round-trip rules above.
  ..uuid = m.id
  ..fullName = m.fullName
  ..phoneNumber = m.phoneNumber
  ..email = m.email
  ..address = m.address
  ..notes = m.notes
  ..profileImagePath = m.profileImagePath
  ..nationalId = m.nationalId
  ..birthday = m.birthday
  ..gender = m.gender
  // Defensive copy so the consumer cannot mutate the underlying
  // Isar list through the Model once we hand it back.
  ..tags = List<String>.of(m.tags)
  ..createdAt = m.createdAt
  ..updatedAt = m.updatedAt;

CustomerModel _isarToModel(CustomerIsar i) => CustomerModel(
  // Internal `Id` deliberately dropped — domain uses `uuid`.
  id: i.uuid,
  fullName: i.fullName,
  phoneNumber: i.phoneNumber,
  email: i.email,
  address: i.address,
  notes: i.notes,
  profileImagePath: i.profileImagePath,
  nationalId: i.nationalId,
  birthday: i.birthday,
  gender: i.gender,
  // Defensive copy: Isar's list properties are live "views"
  // backed by the underlying storage. Hand a fresh `List<String>`
  // to the Model so subsequent Model copies cannot mutate the
  // DB through `i.tags`.
  tags: List<String>.of(i.tags),
  createdAt: i.createdAt,
  updatedAt: i.updatedAt,
);

/// Storage POJO → Isar collection. Use at write boundaries when
/// persisting / upserting a customer.
///
/// The returned [CustomerIsar] has `id == Isar.autoIncrement`;
/// Isar assigns the real primary key on `put`.
///
/// Note: `CustomerIsar.balance` is intentionally not assigned here.
/// The deprecated column is left at its default value on the row.
extension CustomerModelToIsar on CustomerModel {
  CustomerIsar toIsar() => _modelToIsar(this);
}

/// Isar collection → storage POJO. Use at read boundaries when
/// hydrating an entity from the database.
///
/// The internal Isar `id` is intentionally lost in translation; only
/// [CustomerIsar.uuid] flows out, and it lands in [CustomerModel.id].
///
/// Note: `CustomerIsar.balance` is intentionally discarded here.
/// Whatever value the on-disk row carries is ignored and is *not*
/// exposed through the data layer.
extension CustomerIsarToModel on CustomerIsar {
  CustomerModel toModel() => _isarToModel(this);
}
