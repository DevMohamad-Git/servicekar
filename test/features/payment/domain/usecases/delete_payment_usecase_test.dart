import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';
import 'package:servicar/features/payment/domain/repositories/payment_repository.dart';
import 'package:servicar/features/payment/domain/usecases/delete_payment_usecase.dart';

class RecordingPaymentRepository implements PaymentRepository {
  final List<String> deleted = [];
  RecordingPaymentRepository();

  @override
  Future<Either<PaymentFailure, Unit>> deletePayment(String id) async {
    deleted.add(id);
    return const Right(Unit.instance);
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
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();
}

void main() {
  group('DeletePaymentUseCase', () {
    test('empty id → PaymentValidationFailure', () async {
      final repo = RecordingPaymentRepository();
      final uc = DeletePaymentUseCase(repo);
      final result = await uc('   ');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, Unit>).value,
        isA<PaymentValidationFailure>(),
      );
      expect(repo.deleted, isEmpty);
    });

    test('valid id → Right(Unit)', () async {
      final repo = RecordingPaymentRepository();
      final uc = DeletePaymentUseCase(repo);
      final result = await uc('pay-1');
      expect(result, const Right<PaymentFailure, Unit>(Unit.instance));
      expect(repo.deleted, ['pay-1']);
    });

    test('storage failure propagates', () async {
      final broken = _ThrowingRepo();
      final uc = DeletePaymentUseCase(broken);
      final result = await uc('pay-1');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, Unit>).value,
        isA<PaymentStorageFailure>(),
      );
    });
  });
}

class _ThrowingRepo implements PaymentRepository {
  @override
  Future<Either<PaymentFailure, Unit>> deletePayment(String id) async =>
      const Left(
        PaymentStorageFailure(operation: 'deletePayment', message: 'boom'),
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
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();
}
