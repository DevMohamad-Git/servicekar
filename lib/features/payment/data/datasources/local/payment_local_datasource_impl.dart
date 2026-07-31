import 'package:isar_community/isar.dart';

import 'package:servicar/features/customer/data/mappers/payment_isar_mapper.dart';
import 'package:servicar/features/customer/data/models/payment_isar.dart';
import 'package:servicar/features/customer/data/models/payment_model.dart';

import 'payment_local_datasource.dart';

/// Isar-backed implementation of [PaymentLocalDataSource].
///
/// ─── ID semantics inside the data layer ──────────────────────────
/// * Lookups by `id` go through `getByUuid` / `deleteByUuid`:
///   the unique + `replace: true` index on `PaymentIsar.uuid`
///   turns those into constant-time index hits; `deleteByUuid`
///   future-proofs against silent link breaks.
/// * Writes go through `putByUuid` so re-saving a payment with an
///   unchanged business key correctly UPDATES the existing row
///   instead of inserting a duplicate.
/// * The Isar-internal numeric [Id] never escapes this file — the
///   mapper drops it on the way back to [PaymentModel].
///
/// ─── Isar-query boundary ─────────────────────────────────────────
/// All `_isar.paymentIsars.…` calls live exclusively in this
/// file. No other layer (Repository, UseCase, Domain,
/// Presentation) imports `package:isar_community`. The mapper at
/// `payment_isar_mapper.dart` (owned by the customer feature's
/// data layer for now, since the schema foundation lived there)
/// owns the `PaymentModel ↔ PaymentIsar` round-trip; this file
/// is the thin "send a typed query, hand a typed result back"
/// seam.
///
/// Miirors `customer_local_datasource_impl.dart` /
/// `service_local_datasource_impl.dart` exactly; consult those for
/// the cross-collection ID strategy rationale.
class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  const PaymentLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<PaymentIsar> get _payments => _isar.paymentIsars;

  @override
  Future<PaymentModel?> getById(String id) async {
    final found = await _payments.getByUuid(id);
    return found?.toModel();
  }

  @override
  Future<List<PaymentModel>> getByCustomer(String customerUuid) async {
    // Sort by `paidAt` desc so recent receipts surface first in
    // the customer history view. Nullable timestamps are NOT
    // valid for `PaymentIsar.paidAt` (the column is `late`, not
    // `DateTime?`), so the sort is deterministic.
    final rows = await _payments
        .where()
        .customerUuidEqualTo(customerUuid)
        .sortByPaidAtDesc()
        .findAll();
    return rows.map((i) => i.toModel()).toList(growable: false);
  }

  @override
  Future<List<PaymentModel>> getByInvoice(String invoiceUuid) async {
    // Same ordering as `getByCustomer`.
    final rows = await _payments
        .where()
        .invoiceUuidEqualTo(invoiceUuid)
        .sortByPaidAtDesc()
        .findAll();
    return rows.map((i) => i.toModel()).toList(growable: false);
  }

  @override
  Future<void> save(PaymentModel model) async {
    await _isar.writeTxn(() async {
      // `putByUuid` honours the
      // `@Index(unique: true, replace: true)` on `PaymentIsar.uuid`:
      // re-inserting a row whose uuid is already present
      // overwrites that row instead of creating a duplicate.
      // The internal `PaymentIsar.id` is overridden by Isar on
      // insert.
      await _payments.putByUuid(model.toIsar());
    });
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      // Idempotent: returns `false` if no row matches.
      await _payments.deleteByUuid(id);
    });
  }
}
