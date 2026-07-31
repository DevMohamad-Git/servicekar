import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/mappers/payment_mapper.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';

import '../../domain/failures/payment_failure.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/local/payment_local_datasource.dart';

/// Offline-first implementation of [PaymentRepository]. Talks to
/// the local Isar-backed datasource only; remote sync will be
/// layered on top later without changing the contract above.
///
/// Methods return an `Either<PaymentFailure, T>` and short-circuit
/// with a [PaymentStorageFailure] when the underlying datasource
/// throws.
///
/// Riverpod binding for this repository lives in
/// `lib/injection/feature_injection/payment_providers.dart` — the
/// same partition the customer / service features use for the
/// analogous providers.
///
/// ─── Zero Isar queries in here ────────────────────────────────────
/// Every `_isar.…` call lives in the datasource; this file only
/// orchestrates Domain ↔ Model conversion (`entity.toModel()` →
/// datasource → `model.toEntity()` re-hydration). That keeps the
/// "Repository must not contain Isar queries" rule from the brief.
class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({required PaymentLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final PaymentLocalDataSource _localDataSource;

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity payment,
  ) async {
    try {
      final model = payment.toModel();
      await _localDataSource.save(model);
      return Right(await _readBack(model.id) ?? payment);
    } catch (e) {
      return Left(
        PaymentStorageFailure(
          operation: 'createPayment',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity payment,
  ) async {
    try {
      await _localDataSource.save(payment.toModel());
      return Right(await _readBack(payment.id) ?? payment);
    } catch (e) {
      return Left(
        PaymentStorageFailure(
          operation: 'updatePayment',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<PaymentFailure, Unit>> deletePayment(String id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(Unit.instance);
    } catch (e) {
      return Left(
        PaymentStorageFailure(
          operation: 'deletePayment',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return Left(PaymentNotFoundFailure(id: id));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        PaymentStorageFailure(
          operation: 'getPaymentById',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String invoiceUuid,
  ) async {
    try {
      final models = await _localDataSource.getByInvoice(invoiceUuid);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } catch (e) {
      return Left(
        PaymentStorageFailure(
          operation: 'getPaymentsByInvoice',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String customerUuid,
  ) async {
    try {
      final models = await _localDataSource.getByCustomer(customerUuid);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } catch (e) {
      return Left(
        PaymentStorageFailure(
          operation: 'getPaymentsByCustomer',
          message: e.toString(),
        ),
      );
    }
  }

  /// Re-hydrate the persisted entity so the success path returns
  /// the most current row (timestamps adjusted by the storage
  /// layer, internal `Id` resolved) rather than the pre-save
  /// snapshot. Mirrors the customer / service _readBack.
  Future<PaymentEntity?> _readBack(String id) async {
    final model = await _localDataSource.getById(id);
    return model?.toEntity();
  }
}
