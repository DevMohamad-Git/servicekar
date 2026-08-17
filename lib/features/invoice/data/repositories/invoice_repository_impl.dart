import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/mappers/invoice_mapper.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';

import '../../domain/failures/invoice_failure.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/local/invoice_local_datasource.dart';

/// Offline-first implementation of [InvoiceRepository]. Talks to
/// the local Isar-backed datasource only; remote sync will be
/// layered on top later without changing the contract above.
///
/// Methods return an `Either<InvoiceFailure, T>` and short-circuit
/// with an [InvoiceStorageFailure] when the underlying datasource
/// throws.
///
/// Riverpod binding for this repository lives in
/// `lib/injection/feature_injection/invoice_providers.dart` — the
/// same partition the customer / service features use for the
/// analogous providers.
///
/// ─── History note ─────────────────────────────────────────────────
/// The Phase-4 read-only slice shipped only `getById` /
/// `getByCustomer` / `getTotalByCustomer`. When the offline-first
/// Invoice feature replaced the stub, the `createInvoice` /
/// `updateInvoice` / `deleteInvoice` methods landed with the same
/// `_readBack` round-trip pattern as the customer / service
/// repositories.
///
/// ─── Zero Isar queries in here ─────────────────────────────────────
/// Every `_isar.…` call lives in the datasource; this file only
/// orchestrates Domain ↔ Model conversion (`entity.toModel()` →
/// datasource → `model.toEntity()` re-hydration). That keeps the
/// "Repository must not contain Isar queries" rule from the brief.
class InvoiceRepositoryImpl implements InvoiceRepository {
  const InvoiceRepositoryImpl({
    required InvoiceLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final InvoiceLocalDataSource _localDataSource;

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> createInvoice(
    InvoiceEntity invoice,
  ) async {
    try {
      final model = invoice.toModel();
      await _localDataSource.save(model);
      return Right(await _readBack(model.id) ?? invoice);
    } catch (e) {
      return Left(
        InvoiceStorageFailure(
          operation: 'createInvoice',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> updateInvoice(
    InvoiceEntity invoice,
  ) async {
    try {
      await _localDataSource.save(invoice.toModel());
      return Right(await _readBack(invoice.id) ?? invoice);
    } catch (e) {
      return Left(
        InvoiceStorageFailure(
          operation: 'updateInvoice',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<InvoiceFailure, Unit>> deleteInvoice(String id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(Unit.instance);
    } catch (e) {
      return Left(
        InvoiceStorageFailure(
          operation: 'deleteInvoice',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return Left(InvoiceNotFoundFailure(id: id));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        InvoiceStorageFailure(operation: 'getById', message: e.toString()),
      );
    }
  }

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String customerUuid,
  ) async {
    try {
      final models = await _localDataSource.getByCustomer(customerUuid);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } catch (e) {
      return Left(
        InvoiceStorageFailure(
          operation: 'getByCustomer',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String customerUuid,
  ) async {
    try {
      final total = await _localDataSource.getTotalByCustomer(customerUuid);
      return Right(total);
    } catch (e) {
      return Left(
        InvoiceStorageFailure(
          operation: 'getTotalByCustomer',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<InvoiceFailure, int>> getInvoiceCount() async {
    try {
      return Right(await _localDataSource.countAll());
    } catch (e) {
      return Left(
        InvoiceStorageFailure(
          operation: 'getInvoiceCount',
          message: e.toString(),
        ),
      );
    }
  }

  /// Re-hydrate the persisted entity so the success path returns
  /// the most current row (timestamps adjusted by the storage
  /// layer, internal `Id` resolved) rather than the pre-save
  /// snapshot. Mirrors the customer / service `_readBack`.
  Future<InvoiceEntity?> _readBack(String id) async {
    final model = await _localDataSource.getById(id);
    return model?.toEntity();
  }
}
