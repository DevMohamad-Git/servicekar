import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/invoice/domain/entities/invoice_entity.dart';
import 'package:servicar/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';
import 'package:servicar/features/payment/domain/repositories/payment_repository.dart';
import 'package:servicar/features/payment/domain/usecases/params/update_payment_params.dart';
import 'package:servicar/features/payment/domain/usecases/update_payment_usecase.dart';

class RecordingPaymentRepository implements PaymentRepository {
  final List<PaymentEntity> updated = [];
  final Either<PaymentFailure, PaymentEntity> Function(PaymentEntity) onUpdate;
  RecordingPaymentRepository({required this.onUpdate});

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity p,
  ) async {
    updated.add(p);
    return onUpdate(p);
  }

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity p,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, Unit>> deletePayment(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String uuid,
  ) async => throw UnimplementedError();
}

class StubCustomerRepository implements CustomerRepository {
  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async => Right(CustomerEntity(id: id, fullName: 'Stub', phoneNumber: '0'));

  @override
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity c,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity c,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, Unit>> deleteCustomer(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> getCustomers() async =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> searchCustomers(
    String q,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, double>> getCustomerBalance(String id) async =>
      throw UnimplementedError();
}

class StubInvoiceRepository implements InvoiceRepository {
  final Map<String, InvoiceEntity> _store;
  StubInvoiceRepository([Map<String, InvoiceEntity>? seed])
    : _store = {...?seed};

  factory StubInvoiceRepository.withExisting(
    Iterable<InvoiceEntity> existing,
  ) => StubInvoiceRepository({for (final i in existing) i.id: i});

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async {
    final i = _store[id];
    if (i == null) return Left(InvoiceNotFoundFailure(id: id));
    return Right(i);
  }

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> createInvoice(
    InvoiceEntity i,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> updateInvoice(
    InvoiceEntity i,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, Unit>> deleteInvoice(String id) async =>
      throw UnimplementedError();
}

void main() {
  final baseTime = DateTime.utc(2026, 6, 1);

  UpdatePaymentParams baseParams({
    String? id,
    String? customerUuid,
    String? invoiceUuid,
    double? amount,
    DateTime? paidAt,
  }) => UpdatePaymentParams(
    id: id ?? 'pay-1',
    customerUuid: customerUuid ?? 'cust-1',
    invoiceUuid: invoiceUuid,
    amount: amount ?? 100.0,
    paidAt: paidAt ?? baseTime,
  );

  group('UpdatePaymentUseCase — validation gates', () {
    test('empty id → PaymentValidationFailure(field=id)', () async {
      final repo = RecordingPaymentRepository(
        onUpdate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final uc = UpdatePaymentUseCase(
        paymentRepository: repo,
        customerRepository: StubCustomerRepository(),
        invoiceRepository: StubInvoiceRepository(),
      );
      final result = await uc(baseParams(id: '   '));
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, PaymentEntity>).value,
        isA<PaymentValidationFailure>(),
      );
      expect(repo.updated, isEmpty);
    });

    test('negative amount → rejects (field=amount)', () async {
      final repo = RecordingPaymentRepository(
        onUpdate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final uc = UpdatePaymentUseCase(
        paymentRepository: repo,
        customerRepository: StubCustomerRepository(),
        invoiceRepository: StubInvoiceRepository(),
      );
      final result = await uc(baseParams(amount: -1.0));
      expect(
        (result as Left<PaymentFailure, PaymentEntity>).value,
        isA<PaymentValidationFailure>(),
      );
    });

    test('zero amount is accepted', () async {
      final repo = RecordingPaymentRepository(
        onUpdate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final uc = UpdatePaymentUseCase(
        paymentRepository: repo,
        customerRepository: StubCustomerRepository(),
        invoiceRepository: StubInvoiceRepository(),
      );
      final result = await uc(baseParams(amount: 0.0));
      expect(result.isRight, isTrue);
    });

    test('paidAt in the future → rejects (field=paidAt)', () async {
      final repo = RecordingPaymentRepository(
        onUpdate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final uc = UpdatePaymentUseCase(
        paymentRepository: repo,
        customerRepository: StubCustomerRepository(),
        invoiceRepository: StubInvoiceRepository(),
      );
      final future = DateTime.now().add(const Duration(days: 1));
      final result = await uc(baseParams(paidAt: future));
      expect(
        (result as Left<PaymentFailure, PaymentEntity>).value,
        isA<PaymentValidationFailure>(),
      );
    });

    test(
      'invoiceUuid present but missing → PaymentInvoiceMissingFailure',
      () async {
        final repo = RecordingPaymentRepository(
          onUpdate: (p) => Right<PaymentFailure, PaymentEntity>(p),
        );
        final uc = UpdatePaymentUseCase(
          paymentRepository: repo,
          customerRepository: StubCustomerRepository(),
          invoiceRepository: StubInvoiceRepository(),
        );
        final result = await uc(baseParams(invoiceUuid: 'inv-x'));
        expect(result.isLeft, isTrue);
        expect(
          (result as Left<PaymentFailure, PaymentEntity>).value,
          isA<PaymentInvoiceMissingFailure>(),
        );
      },
    );

    test('invoiceUuid null → skips invoice lookup', () async {
      final repo = RecordingPaymentRepository(
        onUpdate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final invoiceless = _ThrowingInvoiceRepo();
      final uc = UpdatePaymentUseCase(
        paymentRepository: repo,
        customerRepository: StubCustomerRepository(),
        invoiceRepository: invoiceless,
      );
      final result = await uc(baseParams(invoiceUuid: null));
      expect(result.isRight, isTrue);
      expect(repo.updated.single.invoiceUuid, isNull);
    });

    test('valid update → delegates', () async {
      final repo = RecordingPaymentRepository(
        onUpdate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final uc = UpdatePaymentUseCase(
        paymentRepository: repo,
        customerRepository: StubCustomerRepository(),
        invoiceRepository: StubInvoiceRepository(),
      );
      final result = await uc(baseParams());
      expect(result.isRight, isTrue);
      expect(repo.updated.single.id, 'pay-1');
    });

    test('storage failure propagates', () async {
      const failure = PaymentStorageFailure(
        operation: 'updatePayment',
        message: 'simulated',
      );
      final repo = RecordingPaymentRepository(
        onUpdate: (_) => const Left<PaymentFailure, PaymentEntity>(failure),
      );
      final uc = UpdatePaymentUseCase(
        paymentRepository: repo,
        customerRepository: StubCustomerRepository(),
        invoiceRepository: StubInvoiceRepository(),
      );
      final result = await uc(baseParams());
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<PaymentFailure, PaymentEntity>).value,
        same(failure),
      );
    });
  });
}

class _ThrowingInvoiceRepo implements InvoiceRepository {
  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async =>
      Left(InvoiceNotFoundFailure(id: id));

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> createInvoice(
    InvoiceEntity i,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> updateInvoice(
    InvoiceEntity i,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, Unit>> deleteInvoice(String id) async =>
      throw UnimplementedError();
}
