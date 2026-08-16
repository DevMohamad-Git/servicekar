import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show Override;

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/balance/domain/usecases/calculate_customer_balance_usecase.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:servicar/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:servicar/features/invoice/domain/usecases/get_invoice_count_usecase.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';
import 'package:servicar/features/payment/domain/repositories/payment_repository.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';
import 'package:servicar/features/service/domain/repositories/service_repository.dart';
import 'package:servicar/features/service/domain/usecases/get_service_count_usecase.dart';
import 'package:servicar/injection/feature_injection/balance_providers.dart';
import 'package:servicar/injection/feature_injection/customer_providers.dart';
import 'package:servicar/injection/feature_injection/dashboard_providers.dart';
import 'package:servicar/injection/feature_injection/invoice_providers.dart';
import 'package:servicar/injection/feature_injection/service_providers.dart';

// ─── In-memory fakes (only the read paths the dashboard exercises) ────────

class _FakeCustomerRepository implements CustomerRepository {
  _FakeCustomerRepository(this.customers);

  final Map<String, CustomerEntity> customers;

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async {
    final customer = customers[id];
    if (customer == null) return Left(CustomerNotFoundFailure(id: id));
    return Right(customer);
  }

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> getCustomers() async =>
      Right(customers.values.toList(growable: false));

  @override
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity customer,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity customer,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, Unit>> deleteCustomer(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> searchCustomers(
    String query,
  ) async => throw UnimplementedError();
}

class _FakeInvoiceRepository implements InvoiceRepository {
  _FakeInvoiceRepository(this.invoices);

  final List<InvoiceEntity> invoices;

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String customerUuid,
  ) async => Right(
    invoices
        .where((invoice) => invoice.customerUuid == customerUuid)
        .toList(growable: false),
  );

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

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String customerUuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, int>> getInvoiceCount() async =>
      Right(invoices.length);
}

/// Always-fails [InvoiceRepository] for the KPI failure path — verifies
/// a broken count surfaces the failure instead of a fake fallback.
class _ThrowingInvoiceRepository implements InvoiceRepository {
  @override
  Future<Either<InvoiceFailure, int>> getInvoiceCount() async => const Left(
    InvoiceStorageFailure(operation: 'getInvoiceCount', message: 'boom'),
  );

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async =>
      throw UnimplementedError();

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

class _FakeServiceRepository implements ServiceRepository {
  _FakeServiceRepository(this.services);

  final List<ServiceEntity> services;

  @override
  Future<Either<ServiceFailure, int>> getServiceCount() async =>
      Right(services.length);

  @override
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String customerUuid,
  ) async => Right(
    services
        .where((service) => service.customerUuid == customerUuid)
        .toList(growable: false),
  );

  @override
  Future<Either<ServiceFailure, ServiceEntity>> createService(
    ServiceEntity service,
  ) async => throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, ServiceEntity>> updateService(
    ServiceEntity service,
  ) async => throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, Unit>> deleteService(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(
    String id,
  ) async => throw UnimplementedError();
}

class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository(this.payments);

  final List<PaymentEntity> payments;

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String customerUuid,
  ) async => Right(
    payments
        .where((payment) => payment.customerUuid == customerUuid)
        .toList(growable: false),
  );

  @override
  Future<Either<PaymentFailure, PaymentEntity>> createPayment(
    PaymentEntity payment,
  ) async => throw UnimplementedError();

  @override
  Future<Either<PaymentFailure, PaymentEntity>> updatePayment(
    PaymentEntity payment,
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
}

// ─── Builders ─────────────────────────────────────────────────────────────

CustomerEntity _customer(String id) =>
    CustomerEntity(id: id, fullName: id, phoneNumber: '0');

InvoiceEntity _invoice({
  required String id,
  required String customerUuid,
  required double total,
}) => InvoiceEntity(
  id: id,
  customerUuid: customerUuid,
  invoiceNumber: 'INV-$id',
  issueDate: DateTime.utc(2026, 1, 1),
  totalAmount: total,
);

PaymentEntity _payment({
  required String id,
  required String customerUuid,
  required double amount,
}) => PaymentEntity(
  id: id,
  customerUuid: customerUuid,
  amount: amount,
  paidAt: DateTime.utc(2026, 1, 1),
);

ServiceEntity _service({
  required String id,
  required String customerUuid,
}) => ServiceEntity(
  id: id,
  customerUuid: customerUuid,
  title: 'SVC-$id',
);

ProviderContainer _container({
  required Map<String, CustomerEntity> customers,
  required List<InvoiceEntity> invoices,
  required List<PaymentEntity> payments,
  List<ServiceEntity> services = const <ServiceEntity>[],
}) {
  final customerRepository = _FakeCustomerRepository(customers);
  final overrides = <Override>[
    getCustomersUseCaseProvider.overrideWithValue(
      GetCustomersUseCase(customerRepository),
    ),
    calculateCustomerBalanceUseCaseProvider.overrideWithValue(
      CalculateCustomerBalanceUseCase(
        customerRepository: customerRepository,
        invoiceRepository: _FakeInvoiceRepository(invoices),
        paymentRepository: _FakePaymentRepository(payments),
      ),
    ),
    getInvoiceCountUseCaseProvider.overrideWithValue(
      GetInvoiceCountUseCase(_FakeInvoiceRepository(invoices)),
    ),
    getServiceCountUseCaseProvider.overrideWithValue(
      GetServiceCountUseCase(_FakeServiceRepository(services)),
    ),
  ];
  return ProviderContainer(overrides: overrides);
}

void main() {
  group('TotalDebtorsController', () {
    test('sums only the debtor customers outstanding amounts', () async {
      final container = _container(
        customers: {
          'c1': _customer('c1'),
          'c2': _customer('c2'),
        },
        invoices: [
          _invoice(id: 'i1', customerUuid: 'c1', total: 1000000),
          _invoice(id: 'i2', customerUuid: 'c2', total: 500000),
        ],
        payments: [
          _payment(id: 'p1', customerUuid: 'c1', amount: 200000),
        ],
      );
      addTearDown(container.dispose);

      final total = await container.read(totalDebtorsControllerProvider.future);

      // c1 owes 800,000; c2 owes 500,000 → 1,300,000.
      expect(total, 1300000.0);
    });

    test('ignores settled and creditor customers', () async {
      final container = _container(
        customers: {
          'c1': _customer('c1'),
          'c2': _customer('c2'),
          'c3': _customer('c3'),
        },
        invoices: [
          _invoice(id: 'i1', customerUuid: 'c1', total: 1000000),
          _invoice(id: 'i2', customerUuid: 'c2', total: 1000000),
          _invoice(id: 'i3', customerUuid: 'c3', total: 1000000),
        ],
        payments: [
          _payment(id: 'p1', customerUuid: 'c1', amount: 200000),
          _payment(id: 'p2', customerUuid: 'c2', amount: 1500000),
          _payment(id: 'p3', customerUuid: 'c3', amount: 1000000),
        ],
      );
      addTearDown(container.dispose);

      final total = await container.read(totalDebtorsControllerProvider.future);

      // c1 owes 800,000; c2 is a creditor (+500k); c3 is settled → 800,000.
      expect(total, 800000.0);
    });

    test('returns zero when there are no customers', () async {
      final container = _container(
        customers: const {},
        invoices: const [],
        payments: const [],
      );
      addTearDown(container.dispose);

      final total = await container.read(totalDebtorsControllerProvider.future);

      expect(total, 0.0);
    });
  });

  group('Business Overview count controllers', () {
    test('invoice count equals the number of persisted invoices', () async {
      final container = _container(
        customers: {'c1': _customer('c1'), 'c2': _customer('c2')},
        invoices: [
          _invoice(id: 'i1', customerUuid: 'c1', total: 1_000_000),
          _invoice(id: 'i2', customerUuid: 'c1', total: 500_000),
          _invoice(id: 'i3', customerUuid: 'c2', total: 700_000),
        ],
        payments: const [],
      );
      addTearDown(container.dispose);

      final count =
          await container.read(invoiceCountControllerProvider.future);
      expect(count, 3);
    });

    test('customer count equals the number of persisted customers',
        () async {
      final container = _container(
        customers: {'c1': _customer('c1'), 'c2': _customer('c2')},
        invoices: const [],
        payments: const [],
      );
      addTearDown(container.dispose);

      final count =
          await container.read(customerCountControllerProvider.future);
      expect(count, 2);
    });

    test('service count equals the number of persisted services', () async {
      final container = _container(
        customers: {'c1': _customer('c1')},
        invoices: const [],
        payments: const [],
        services: [
          _service(id: 's1', customerUuid: 'c1'),
          _service(id: 's2', customerUuid: 'c1'),
        ],
      );
      addTearDown(container.dispose);

      final count =
          await container.read(serviceCountControllerProvider.future);
      expect(count, 2);
    });

    test('services are counted independently of invoices', () async {
      // A service may exist without any invoice — the counts must not
      // be derived from one another.
      final container = _container(
        customers: {'c1': _customer('c1')},
        invoices: const [],
        payments: const [],
        services: [_service(id: 's1', customerUuid: 'c1')],
      );
      addTearDown(container.dispose);

      expect(await container.read(serviceCountControllerProvider.future), 1);
      expect(await container.read(invoiceCountControllerProvider.future), 0);
    });

    test('zero records produce zero for every KPI', () async {
      final container = _container(
        customers: const {},
        invoices: const [],
        payments: const [],
      );
      addTearDown(container.dispose);

      expect(await container.read(invoiceCountControllerProvider.future), 0);
      expect(await container.read(customerCountControllerProvider.future), 0);
      expect(await container.read(serviceCountControllerProvider.future), 0);
    });

    test('a failing count surfaces the failure (no fake fallback)', () async {
      final container = ProviderContainer(
        // Riverpod 3 auto-retries failures that are not `Error`/
        // `ProviderException` (defaultRetry), which would keep the
        // controller in AsyncLoading and stall the assertion. Fail fast
        // in the test so the failure surfaces as AsyncError.
        retry: (retryCount, error) => null,
        overrides: [
          getInvoiceCountUseCaseProvider.overrideWithValue(
            GetInvoiceCountUseCase(_ThrowingInvoiceRepository()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(invoiceCountControllerProvider.future),
        throwsA(isA<InvoiceStorageFailure>()),
      );
    });
  });
}
