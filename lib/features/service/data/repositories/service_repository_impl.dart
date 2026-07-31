import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/mappers/service_mapper.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';

import '../../domain/failures/service_failure.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/local/service_local_datasource.dart';

/// Offline-first implementation of [ServiceRepository]. Talks to the
/// local Isar-backed datasource only; remote sync will be layered on
/// top later without changing the contract above.
///
/// Methods return an `Either<ServiceFailure, T>` and short-circuit with
/// a [ServiceStorageFailure] when the underlying datasource throws.
///
/// Riverpod binding for this repository lives in
/// `lib/injection/feature_injection/service_providers.dart` — the
/// same partition the customer feature uses for the analogous
/// providers.
///
/// ─── Zero Isar queries in here ──────────────────────────────────────
/// Every `_isar.…` call lives in the datasource; this file only
/// orchestrates Domain ↔ Model conversion (`entity.toModel()` →
/// datasource → `model.toEntity()` re-hydration). That keeps the
/// "Repository must not contain Isar queries" rule from the brief.
class ServiceRepositoryImpl implements ServiceRepository {
  const ServiceRepositoryImpl({required ServiceLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final ServiceLocalDataSource _localDataSource;

  @override
  Future<Either<ServiceFailure, ServiceEntity>> createService(
    ServiceEntity service,
  ) async {
    try {
      final model = service.toModel();
      await _localDataSource.save(model);
      return Right(await _readBack(model.id) ?? service);
    } catch (e) {
      return Left(
        ServiceStorageFailure(
          operation: 'createService',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<ServiceFailure, ServiceEntity>> updateService(
    ServiceEntity service,
  ) async {
    try {
      await _localDataSource.save(service.toModel());
      return Right(await _readBack(service.id) ?? service);
    } catch (e) {
      return Left(
        ServiceStorageFailure(
          operation: 'updateService',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<ServiceFailure, Unit>> deleteService(String id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(Unit.instance);
    } catch (e) {
      return Left(
        ServiceStorageFailure(
          operation: 'deleteService',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(
    String id,
  ) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return Left(ServiceNotFoundFailure(id: id));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        ServiceStorageFailure(
          operation: 'getServiceById',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String customerUuid,
  ) async {
    try {
      final models = await _localDataSource.getByCustomer(customerUuid);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } catch (e) {
      return Left(
        ServiceStorageFailure(
          operation: 'getServicesByCustomer',
          message: e.toString(),
        ),
      );
    }
  }

  /// Re-hydrates the persisted entity. Used so the success path can
  /// return the most current row (timestamps adjusted by the storage
  /// layer, internal Id resolved) rather than the pre-save snapshot.
  /// Mirrors the customer repository's `_readBack`.
  Future<ServiceEntity?> _readBack(String id) async {
    final model = await _localDataSource.getById(id);
    return model?.toEntity();
  }
}
