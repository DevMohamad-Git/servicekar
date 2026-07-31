import 'package:isar_community/isar.dart';

import 'package:servicar/features/customer/data/mappers/invoice_isar_mapper.dart';
import 'package:servicar/features/customer/data/models/invoice_isar.dart';
import 'package:servicar/features/customer/data/models/invoice_model.dart';

import 'invoice_local_datasource.dart';

/// Isar-backed implementation of [InvoiceLocalDataSource].
///
/// Mirrors `payment_local_datasource_impl.dart` /
/// `service_local_datasource_impl.dart` exactly: every
/// `_isar.invoiceIsars.…` call lives here and nowhere else.
///
/// ─── ID semantics inside the data layer ─────────────────────────────
///   * Lookups by `id` go through `getByUuid` / `deleteByUuid`: the
///     unique + `replace: true` index on `InvoiceIsar.uuid` turns
///     those into constant-time index hits and lets `deleteByUuid`
///     future-proof against silent link breaks.
///   * Writes go through `putByUuid` so re-saving an invoice with
///     an unchanged business key correctly UPDATES the existing
///     row instead of inserting a duplicate.
///   * The Isar-internal numeric [Id] never escapes this file — the
///     mapper drops it on the way back to [InvoiceModel].
///
/// ─── Aggregation note ────────────────────────────────────────────
/// `getTotalByCustomer` deliberately avoids Isar's typed double-
/// sum aggregation. The list of invoices per customer is bounded
/// (tens, not millions) so a Dart-side `reduce` after `findAll()` is
/// faster than the overhead of a separate Isar query and is easier
/// to test in an in-memory harness. If profiling shows otherwise
/// for very busy customers, the same method shape can later swap
/// to `QueryDoubleSumProperty`.
class InvoiceLocalDataSourceImpl implements InvoiceLocalDataSource {
  const InvoiceLocalDataSourceImpl(this._isar);

  final Isar _isar;

  IsarCollection<InvoiceIsar> get _invoices => _isar.invoiceIsars;

  @override
  Future<InvoiceModel?> getById(String id) async {
    final found = await _invoices.getByUuid(id);
    return found?.toModel();
  }

  @override
  Future<List<InvoiceModel>> getByCustomer(String customerUuid) async {
    final rows = await _invoices
        .where()
        .customerUuidEqualTo(customerUuid)
        .sortByIssueDateDesc()
        .findAll();
    return rows.map((i) => i.toModel()).toList(growable: false);
  }

  @override
  Future<double> getTotalByCustomer(String customerUuid) async {
    final rows = await _invoices
        .where()
        .customerUuidEqualTo(customerUuid)
        .findAll();
    var total = 0.0;
    for (final r in rows) {
      total += r.totalAmount;
    }
    return total;
  }

  @override
  Future<void> save(InvoiceModel model) async {
    await _isar.writeTxn(() async {
      // `putByUuid` honours the
      // `@Index(unique: true, replace: true)` on
      // `InvoiceIsar.uuid`: re-inserting a row whose uuid is
      // already present overwrites that row instead of creating a
      // duplicate. The internal `InvoiceIsar.id`
      // (`Isar.autoIncrement` sentinel from the mapper) is
      // overridden by Isar on insert.
      await _invoices.putByUuid(model.toIsar());
    });
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      // Idempotent: returns `false` if no row matches. Mirrors the
      // service / payment deletes verbatim so we keep one
      // "deleteByUuid" idiom across the data layer.
      await _invoices.deleteByUuid(id);
    });
  }
}
