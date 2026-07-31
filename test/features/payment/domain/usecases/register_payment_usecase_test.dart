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
import 'package:servicar/features/payment/domain/usecases/params/register_payment_params.dart';
import 'package:servicar/features/payment/domain/usecases/register_payment_usecase.dart';

/// Recording fake. Only `createPayment` is exercised here.
class RecordingPaymentRepository implements PaymentRepository {
  final List<PaymentEntity> created = [];
  final Either<PaymentFailure, PaymentEntity> Function(PaymentEntity) onCreate;
  RecordingPaymentRepository({required this.onCreate});

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity p,
  ) async {
    created.add(p);
    return onCreate(p);
  }

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
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
    String invoiceUuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String customerUuid,
  ) async => throw UnimplementedError();
}

class RecordingCustomerRepository implements CustomerRepository {
  final Map<String, CustomerEntity> _store;
  RecordingCustomerRepository([Map<String, CustomerEntity>? seed])
    : _store = {...?seed};

  factory RecordingCustomerRepository.withExisting(
    Iterable<CustomerEntity> existing,
  ) => RecordingCustomerRepository({for (final c in existing) c.id: c});

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async {
    final c = _store[id];
    if (c == null) return Left(CustomerNotFoundFailure(id: id));
    return Right(c);
  }

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

class RecordingInvoiceRepository implements InvoiceRepository {
  final Map<String, InvoiceEntity> _store;
  RecordingInvoiceRepository([Map<String, InvoiceEntity>? seed])
    : _store = {...?seed};

  factory RecordingInvoiceRepository.withExisting(
    Iterable<InvoiceEntity> existing,
  ) => RecordingInvoiceRepository({for (final i in existing) i.id: i});

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async {
    final i = _store[id];
    if (i == null) return Left(InvoiceNotFoundFailure(id: id));
    return Right(i);
  }

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String customerUuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String customerUuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> createInvoice(
    InvoiceEntity invoice,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> updateInvoice(
    InvoiceEntity invoice,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, Unit>> deleteInvoice(String id) async =>
      throw UnimplementedError();
}

void main() {
  const okCustomer = CustomerEntity(
    id: 'cust-1',
    fullName: 'Alice',
    phoneNumber: '0',
  );
  final customerRepo = RecordingCustomerRepository.withExisting([okCustomer]);

  final baseTime = DateTime.utc(2026, 6, 1);

  RegisterPaymentParams baseParams({
    String? id,
    String? customerUuid,
    String? invoiceUuid,
    double? amount,
    DateTime? paidAt,
    PaymentMethod? method,
    String? note,
  }) => RegisterPaymentParams(
    id: id ?? 'pay-1',
    customerUuid: customerUuid ?? okCustomer.id,
    invoiceUuid: invoiceUuid,
    amount: amount ?? 100.0,
    paidAt: paidAt ?? baseTime,
    method: method ?? PaymentMethod.cash,
    note: note,
  );

  /// Constructs a seeded invoice for FK tests.
  InvoiceEntity seedInvoice(String id) => InvoiceEntity(
    id: id,
    customerUuid: okCustomer.id,
    invoiceNumber: 'INV-$id',
    issueDate: baseTime,
  );

  group('RegisterPaymentUseCase — validation gates', () {
    test('empty id → PaymentValidationFailure(field=id)', () async {
      final repo = RecordingPaymentRepository(
        onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final useCase = RegisterPaymentUseCase(
        paymentRepository: repo,
        customerRepository: customerRepo,
        invoiceRepository: RecordingInvoiceRepository(),
      );
      final result = await useCase(baseParams(id: '   '));
      expect(result.isLeft, isTrue);
      final f = (result as Left<PaymentFailure, PaymentEntity>).value;
      expect(f, isA<PaymentValidationFailure>());
      expect((f as PaymentValidationFailure).field, 'id');
      expect(repo.created, isEmpty);
    });

    test('negative amount → PaymentValidationFailure(field=amount)', () async {
      final repo = RecordingPaymentRepository(
        onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final useCase = RegisterPaymentUseCase(
        paymentRepository: repo,
        customerRepository: customerRepo,
        invoiceRepository: RecordingInvoiceRepository(),
      );
      final result = await useCase(baseParams(amount: -1.0));
      expect(result.isLeft, isTrue);
      final f = (result as Left<PaymentFailure, PaymentEntity>).value;
      expect((f as PaymentValidationFailure).field, 'amount');
      expect(repo.created, isEmpty);
    });

    test('zero amount is accepted (write-off case)', () async {
      final repo = RecordingPaymentRepository(
        onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final useCase = RegisterPaymentUseCase(
        paymentRepository: repo,
        customerRepository: customerRepo,
        invoiceRepository: RecordingInvoiceRepository(),
      );
      final result = await useCase(baseParams(amount: 0.0));
      expect(result.isRight, isTrue);
      final e = (result as Right<PaymentFailure, PaymentEntity>).value;
      expect(e.amount, 0.0);
      expect(repo.created.single.amount, 0.0);
    });

    test(
      'paidAt in the future → PaymentValidationFailure(field=paidAt)',
      () async {
        final repo = RecordingPaymentRepository(
          onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
        );
        final useCase = RegisterPaymentUseCase(
          paymentRepository: repo,
          customerRepository: customerRepo,
          invoiceRepository: RecordingInvoiceRepository(),
        );
        final future = DateTime.now().add(const Duration(days: 30));
        final result = await useCase(baseParams(paidAt: future));
        expect(result.isLeft, isTrue);
        final f = (result as Left<PaymentFailure, PaymentEntity>).value;
        expect((f as PaymentValidationFailure).field, 'paidAt');
      },
    );

    test('paidAt == past is accepted', () async {
      final repo = RecordingPaymentRepository(
        onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final useCase = RegisterPaymentUseCase(
        paymentRepository: repo,
        customerRepository: customerRepo,
        invoiceRepository: RecordingInvoiceRepository(),
      );
      final past = DateTime.now().subtract(const Duration(seconds: 5));
      final result = await useCase(baseParams(paidAt: past));
      expect(result.isRight, isTrue);
    });

    test('CustomerMissingFailure when FK does not resolve', () async {
      final repo = RecordingPaymentRepository(
        onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final emptyCustomerRepo = RecordingCustomerRepository();
      final useCase = RegisterPaymentUseCase(
        paymentRepository: repo,
        customerRepository: emptyCustomerRepo,
        invoiceRepository: RecordingInvoiceRepository(),
      );
      final result = await useCase(baseParams());
      expect(result.isLeft, isTrue);
      final f = (result as Left<PaymentFailure, PaymentEntity>).value;
      expect(f, isA<PaymentCustomerMissingFailure>());
      expect((f as PaymentCustomerMissingFailure).reason, 'notFound');
      expect(repo.created, isEmpty);
    });

    test(
      'InvoiceMissingFailure when invoiceUuid supplied but FK missing',
      () async {
        final repo = RecordingPaymentRepository(
          onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
        );
        final useCase = RegisterPaymentUseCase(
          paymentRepository: repo,
          customerRepository: customerRepo,
          invoiceRepository: RecordingInvoiceRepository(),
        );
        final result = await useCase(baseParams(invoiceUuid: 'inv-x'));
        expect(result.isLeft, isTrue);
        final f = (result as Left<PaymentFailure, PaymentEntity>).value;
        expect(f, isA<PaymentInvoiceMissingFailure>());
        expect((f as PaymentInvoiceMissingFailure).reason, 'notFound');
        expect(repo.created, isEmpty);
      },
    );

    test('invoiceUuid supplied AND FK present → delegates', () async {
      final repo = RecordingPaymentRepository(
        onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final invoiceRepo = RecordingInvoiceRepository.withExisting([
        seedInvoice('inv-1'),
      ]);
      final useCase = RegisterPaymentUseCase(
        paymentRepository: repo,
        customerRepository: customerRepo,
        invoiceRepository: invoiceRepo,
      );
      final result = await useCase(baseParams(invoiceUuid: 'inv-1'));
      expect(result.isRight, isTrue);
      expect(repo.created, hasLength(1));
      expect(repo.created.single.invoiceUuid, 'inv-1');
    });

    test(
      'on-account payment (invoiceUuid=null) skips invoice lookup',
      () async {
        final invoicelessRepo = _AlwaysInvoiceUnknown();
        final repo = RecordingPaymentRepository(
          onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
        );
        final useCase = RegisterPaymentUseCase(
          paymentRepository: repo,
          customerRepository: customerRepo,
          invoiceRepository: invoicelessRepo,
        );
        final onAccountParams = RegisterPaymentParams(
          id: 'pay-1',
          customerUuid: okCustomer.id,
          amount: 100.0,
          paidAt: baseTime,
          invoiceUuid: null, // on-account
        );
        final result = await useCase(onAccountParams);
        expect(result.isRight, isTrue);
        expect(repo.created.single.invoiceUuid, isNull);
      },
    );

    test('valid input → delegates to the repository unchanged', () async {
      final repo = RecordingPaymentRepository(
        onCreate: (p) => Right<PaymentFailure, PaymentEntity>(p),
      );
      final useCase = RegisterPaymentUseCase(
        paymentRepository: repo,
        customerRepository: customerRepo,
        invoiceRepository: RecordingInvoiceRepository(),
      );
      final result = await useCase(baseParams());
      expect(result.isRight, isTrue);
      expect(repo.created.single.amount, 100.0);
      expect(repo.created.single.id, 'pay-1');
    });

    test(
      'Repository.storage failure propagates with operation=createPayment',
      () async {
        const failure = PaymentStorageFailure(
          operation: 'createPayment',
          message: 'simulated',
        );
        final repo = RecordingPaymentRepository(
          onCreate: (_) => const Left<PaymentFailure, PaymentEntity>(failure),
        );
        final useCase = RegisterPaymentUseCase(
          paymentRepository: repo,
          customerRepository: customerRepo,
          invoiceRepository: RecordingInvoiceRepository(),
        );
        final result = await useCase(baseParams());
        expect(result.isLeft, isTrue);
        expect(
          (result as Left<PaymentFailure, PaymentEntity>).value,
          same(failure),
        );
      },
    );
  });
}

/// Invoice repository that always throws on `getById`. Used to
/// verify the on-account fast-path does NOT consult invoices.
class _AlwaysInvoiceUnknown implements InvoiceRepository {
  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async =>
      Left(InvoiceNotFoundFailure(id: id));

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String customerUuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String customerUuid,
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
