import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';
import 'package:servicar/features/payment/domain/repositories/payment_repository.dart';
import 'package:servicar/features/payment/domain/usecases/get_payment_by_id_usecase.dart';

class RecordingPaymentRepository implements PaymentRepository {
  final Map<String, PaymentEntity> _store;
  RecordingPaymentRepository(this._store);

  factory RecordingPaymentRepository.withEntities(
    Iterable<PaymentEntity> existing,
  ) => RecordingPaymentRepository({for (final p in existing) p.id: p});

  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async {
    final p = _store[id];
    if (p == null) return Left(PaymentNotFoundFailure(id: id));
    return Right(p);
  }

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, Unit>> deletePayment(String id) async =>
      throw UnimplementedError();
}

void main() {
  final baseTime = DateTime.utc(2026, 1, 1);

  group('GetPaymentByIdUseCase', () {
    final repo = RecordingPaymentRepository.withEntities([
      PaymentEntity(
        id: 'pay-1',
        customerUuid: 'cust-1',
        amount: 100.0,
        paidAt: baseTime,
      ),
    ]);
    final useCase = GetPaymentByIdUseCase(repo);

    test('empty id → PaymentValidationFailure', () async {
      final result = await useCase('   ');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, PaymentEntity>).value,
        isA<PaymentValidationFailure>(),
      );
    });

    test('existing id → entity', () async {
      final result = await useCase('pay-1');
      expect(result.isRight, isTrue);
      expect(
        (result as Right<PaymentFailure, PaymentEntity>).value.id,
        'pay-1',
      );
    });

    test('missing id → PaymentNotFoundFailure', () async {
      final result = await useCase('nope');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, PaymentEntity>).value,
        isA<PaymentNotFoundFailure>(),
      );
    });

    test('storage failure propagates', () async {
      final broken = _ThrowingPaymentRepository();
      final uc = GetPaymentByIdUseCase(broken);
      final result = await uc('pay-1');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, PaymentEntity>).value,
        isA<PaymentStorageFailure>(),
      );
    });
  });
}

class _ThrowingPaymentRepository implements PaymentRepository {
  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async => const Left(
    PaymentStorageFailure(operation: 'getPaymentById', message: 'boom'),
  );

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, Unit>> deletePayment(String id) async =>
      throw UnimplementedError();
}
