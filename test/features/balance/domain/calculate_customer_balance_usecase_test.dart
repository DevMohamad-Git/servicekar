import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/balance/domain/entities/balance_status.dart';
import 'package:servicar/features/balance/domain/failures/balance_failure.dart';
import 'package:servicar/features/balance/domain/value_models/customer_balance_result.dart';
import 'package:servicar/features/balance/domain/usecases/calculate_customer_balance_usecase.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/invoice/domain/entities/invoice_entity.dart';
import 'package:servicar/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';
import 'package:servicar/features/payment/domain/repositories/payment_repository.dart';

// ─── Test fakes (in-memory) ─────────────────────────────────────────

class FakeCustomerRepository implements CustomerRepository {
  final Map<String, CustomerEntity> _store;
  FakeCustomerRepository([Map<String, CustomerEntity>? seed])
    : _store = {...?seed};

  factory FakeCustomerRepository.withEntities(
    Iterable<CustomerEntity> existing,
  ) => FakeCustomerRepository({for (final c in existing) c.id: c});

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

class FakeInvoiceRepository implements InvoiceRepository {
  final Map<String, InvoiceEntity> _byId;
  final List<InvoiceEntity> _byCustomer;
  FakeInvoiceRepository({
    Map<String, InvoiceEntity>? byId,
    List<InvoiceEntity>? byCustomer,
  }) : _byId = {...?byId},
       _byCustomer = [...?byCustomer];

  FakeInvoiceRepository.withInvoices(Iterable<InvoiceEntity> invoices)
    : _byId = {for (final i in invoices) i.id: i},
      _byCustomer = invoices.toList();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async {
    final i = _byId[id];
    if (i == null) return Left(InvoiceNotFoundFailure(id: id));
    return Right(i);
  }

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String customerUuid,
  ) async =>
      Right(_byCustomer.where((i) => i.customerUuid == customerUuid).toList());

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String customerUuid,
  ) async {
    var total = 0.0;
    for (final i in _byCustomer) {
      if (i.customerUuid == customerUuid) total += i.totalAmount;
    }
    return Right(total);
  }

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

class FakePaymentRepository implements PaymentRepository {
  final List<PaymentEntity> _all;
  FakePaymentRepository([List<PaymentEntity>? seed]) : _all = [...?seed];

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String customerUuid,
  ) async => Right(_all.where((p) => p.customerUuid == customerUuid).toList());

  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
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

// ─── Builders ───────────────────────────────────────────────────────

CustomerEntity _customer({String id = 'cust-1'}) =>
    CustomerEntity(id: id, fullName: 'Alice', phoneNumber: '0');

InvoiceEntity _invoice({
  required String id,
  double total = 0.0,
  String? customerUuid,
}) => InvoiceEntity(
  id: id,
  customerUuid: customerUuid ?? 'cust-1',
  invoiceNumber: 'INV-$id',
  issueDate: DateTime.utc(2026, 1, 1),
  totalAmount: total,
);

PaymentEntity _payment({
  required String id,
  required double amount,
  String? invoiceUuid,
  String? customerUuid,
}) => PaymentEntity(
  id: id,
  customerUuid: customerUuid ?? 'cust-1',
  amount: amount,
  paidAt: DateTime.utc(2026, 1, 1),
  invoiceUuid: invoiceUuid,
);

CalculateCustomerBalanceUseCase _uc({
  required CustomerRepository customerRepository,
  required InvoiceRepository invoiceRepository,
  required PaymentRepository paymentRepository,
}) => CalculateCustomerBalanceUseCase(
  customerRepository: customerRepository,
  invoiceRepository: invoiceRepository,
  paymentRepository: paymentRepository,
);

void main() {
  group('CalculateCustomerBalanceUseCase — brief scenarios', () {
    Future<CustomerBalanceResult> success(
      Future<Either<BalanceFailure, CustomerBalanceResult>> fut,
    ) async {
      final r = await fut;
      expect(
        r.isRight,
        isTrue,
        reason:
            'Expected success; got '
            '${r.leftOrNull?.message ?? 'unknown'}',
      );
      return (r as Right<BalanceFailure, CustomerBalanceResult>).value;
    }

    test(
      'Scenario 1: invoice=1000000, payment=0 → balance=-1000000 debtor',
      () async {
        final uc = _uc(
          customerRepository: FakeCustomerRepository.withEntities([
            _customer(),
          ]),
          invoiceRepository: FakeInvoiceRepository.withInvoices([
            _invoice(id: 'inv-1', total: 1_000_000.0),
          ]),
          paymentRepository: FakePaymentRepository([]),
        );
        final r = await success(uc(_customer().id));
        expect(r.balance, -1_000_000.0);
        expect(r.invoicesTotal, 1_000_000.0);
        expect(r.paymentsTotal, 0.0);
        expect(r.status, BalanceStatus.debtor);
        expect(r.invoiceCount, 1);
        expect(r.paymentCount, 0);
      },
    );

    test(
      'Scenario 2: invoice=1000000, payment=1000000 → balance=0 settled',
      () async {
        final uc = _uc(
          customerRepository: FakeCustomerRepository.withEntities([
            _customer(),
          ]),
          invoiceRepository: FakeInvoiceRepository.withInvoices([
            _invoice(id: 'inv-1', total: 1_000_000.0),
          ]),
          paymentRepository: FakePaymentRepository([
            _payment(id: 'p1', amount: 1_000_000.0, invoiceUuid: 'inv-1'),
          ]),
        );
        final r = await success(uc(_customer().id));
        expect(r.balance, 0.0);
        expect(r.invoicesTotal, 1_000_000.0);
        expect(r.paymentsTotal, 1_000_000.0);
        expect(r.status, BalanceStatus.settled);
      },
    );

    test('Scenario 3: invoice=1000000, payment=1500000 → balance=+500000 '
        'creditor', () async {
      final uc = _uc(
        customerRepository: FakeCustomerRepository.withEntities([_customer()]),
        invoiceRepository: FakeInvoiceRepository.withInvoices([
          _invoice(id: 'inv-1', total: 1_000_000.0),
        ]),
        paymentRepository: FakePaymentRepository([
          _payment(id: 'p1', amount: 1_500_000.0, invoiceUuid: 'inv-1'),
        ]),
      );
      final r = await success(uc(_customer().id));
      expect(r.balance, 500_000.0);
      expect(r.invoicesTotal, 1_000_000.0);
      expect(r.paymentsTotal, 1_500_000.0);
      expect(r.status, BalanceStatus.creditor);
    });

    test('Scenario 4: invoice=1000000 + two payments (300k + 200k) → '
        'balance=-500000 debtor', () async {
      final uc = _uc(
        customerRepository: FakeCustomerRepository.withEntities([_customer()]),
        invoiceRepository: FakeInvoiceRepository.withInvoices([
          _invoice(id: 'inv-1', total: 1_000_000.0),
        ]),
        paymentRepository: FakePaymentRepository([
          _payment(id: 'p1', amount: 300_000.0, invoiceUuid: 'inv-1'),
          _payment(id: 'p2', amount: 200_000.0, invoiceUuid: 'inv-1'),
        ]),
      );
      final r = await success(uc(_customer().id));
      expect(r.balance, -500_000.0);
      expect(r.paymentsTotal, 500_000.0);
      expect(r.status, BalanceStatus.debtor);
      expect(r.paymentCount, 2);
    });

    test(
      'Scenario 5: invoice=0, payment=500000 → balance=+500000 creditor',
      () async {
        final uc = _uc(
          customerRepository: FakeCustomerRepository.withEntities([
            _customer(),
          ]),
          invoiceRepository: FakeInvoiceRepository.withInvoices([]),
          paymentRepository: FakePaymentRepository([
            _payment(id: 'advance', amount: 500_000.0, invoiceUuid: null),
          ]),
        );
        final r = await success(uc(_customer().id));
        expect(r.balance, 500_000.0);
        expect(r.invoicesTotal, 0.0);
        expect(r.paymentsTotal, 500_000.0);
        expect(r.status, BalanceStatus.creditor);
      },
    );

    test('multiple invoices are summed correctly', () async {
      final uc = _uc(
        customerRepository: FakeCustomerRepository.withEntities([_customer()]),
        invoiceRepository: FakeInvoiceRepository.withInvoices([
          _invoice(id: 'inv-1', total: 500_000.0),
          _invoice(id: 'inv-2', total: 200_000.0),
          _invoice(id: 'inv-3', total: 300_000.0),
        ]),
        paymentRepository: FakePaymentRepository([
          _payment(id: 'p1', amount: 800_000.0, invoiceUuid: 'inv-1'),
        ]),
      );
      final r = await success(uc(_customer().id));
      expect(r.invoicesTotal, 1_000_000.0);
      expect(r.invoiceCount, 3);
      expect(r.paymentsTotal, 800_000.0);
      expect(r.balance, -200_000.0);
      expect(r.status, BalanceStatus.debtor);
    });

    test('customer unknown → BalanceCustomerUnknownFailure', () async {
      final uc = _uc(
        customerRepository: FakeCustomerRepository(),
        invoiceRepository: FakeInvoiceRepository(),
        paymentRepository: FakePaymentRepository(),
      );
      final r = await uc('does-not-exist');
      expect(r.isLeft, isTrue);
      expect(
        (r as Left<BalanceFailure, CustomerBalanceResult>).value,
        isA<BalanceCustomerUnknownFailure>(),
      );
    });

    test('invoice storage failure → BalanceInvoiceLookupFailure', () async {
      final uc = _uc(
        customerRepository: FakeCustomerRepository.withEntities([_customer()]),
        invoiceRepository: _ThrowingInvoiceRepo(),
        paymentRepository: FakePaymentRepository(),
      );
      final r = await uc(_customer().id);
      expect(r.isLeft, isTrue);
      expect(
        (r as Left<BalanceFailure, CustomerBalanceResult>).value,
        isA<BalanceInvoiceLookupFailure>(),
      );
    });

    test('payment storage failure → BalancePaymentLookupFailure', () async {
      final uc = _uc(
        customerRepository: FakeCustomerRepository.withEntities([_customer()]),
        invoiceRepository: FakeInvoiceRepository(),
        paymentRepository: _ThrowingPaymentRepo(),
      );
      final r = await uc(_customer().id);
      expect(r.isLeft, isTrue);
      expect(
        (r as Left<BalanceFailure, CustomerBalanceResult>).value,
        isA<BalancePaymentLookupFailure>(),
      );
    });

    test('empty customerUuid → BalanceCustomerUnknownFailure', () async {
      final uc = _uc(
        customerRepository: FakeCustomerRepository(),
        invoiceRepository: FakeInvoiceRepository(),
        paymentRepository: FakePaymentRepository(),
      );
      final r = await uc('   ');
      expect(r.isLeft, isTrue);
      expect(
        (r as Left<BalanceFailure, CustomerBalanceResult>).value,
        isA<BalanceCustomerUnknownFailure>(),
      );
    });
  });
}

class _ThrowingInvoiceRepo implements InvoiceRepository {
  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String uuid,
  ) async => const Left(
    InvoiceStorageFailure(operation: 'getByCustomer', message: 'boom'),
  );

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

class _ThrowingPaymentRepo implements PaymentRepository {
  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String uuid,
  ) async => const Left(
    PaymentStorageFailure(operation: 'getPaymentsByCustomer', message: 'boom'),
  );

  @override
  Future<Either<PaymentFailure, PaymentEntity>> getPaymentById(
    String id,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
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
