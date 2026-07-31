import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';
import 'package:servicar/features/payment/domain/repositories/payment_repository.dart';
import 'package:servicar/features/payment/domain/usecases/get_invoice_payments_usecase.dart';

class RecordingPaymentRepository implements PaymentRepository {
  final Map<String, List<PaymentEntity>> _byInvoice;
  RecordingPaymentRepository([Map<String, List<PaymentEntity>>? seed])
    : _byInvoice = {...?seed};

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String invoiceUuid,
  ) async {
    return Right(_byInvoice[invoiceUuid] ?? const <PaymentEntity>[]);
  }

  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
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
  group('GetInvoicePaymentsUseCase', () {
    final repo = RecordingPaymentRepository({
      'inv-1': [
        PaymentEntity(
          id: 'a',
          customerUuid: 'cust-1',
          amount: 10.0,
          paidAt: DateTime.utc(2026, 1, 1),
        ),
        PaymentEntity(
          id: 'b',
          customerUuid: 'cust-1',
          amount: 20.0,
          paidAt: DateTime.utc(2026, 1, 2),
        ),
      ],
    });
    final useCase = GetInvoicePaymentsUseCase(repo);

    test('empty invoiceUuid → ValidationFailure', () async {
      final result = await useCase('   ');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, List<PaymentEntity>>).value,
        isA<PaymentValidationFailure>(),
      );
    });

    test('existing invoice → list', () async {
      final result = await useCase('inv-1');
      expect(result.isRight, isTrue);
      expect(
        (result as Right<PaymentFailure, List<PaymentEntity>>).value,
        hasLength(2),
      );
    });

    test('unknown invoice → empty list (not failure)', () async {
      final result = await useCase('inv-unknown');
      expect(result.isRight, isTrue);
      expect(
        (result as Right<PaymentFailure, List<PaymentEntity>>).value,
        isEmpty,
      );
    });

    test('storage failure propagates', () async {
      final broken = _ThrowingRepo();
      final uc = GetInvoicePaymentsUseCase(broken);
      final result = await uc('inv-1');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, List<PaymentEntity>>).value,
        isA<PaymentStorageFailure>(),
      );
    });
  });
}

class _ThrowingRepo implements PaymentRepository {
  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String uuid,
  ) async => const Left(
    PaymentStorageFailure(operation: 'getPaymentsByInvoice', message: 'x'),
  );

  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
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
