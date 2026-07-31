import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/balance/domain/entities/balance_status.dart';
import 'package:servicar/features/balance/domain/failures/balance_failure.dart';
import 'package:servicar/features/balance/domain/usecases/calculate_customer_balance_usecase.dart';
import 'package:servicar/features/balance/domain/value_models/customer_balance_result.dart';
import 'package:servicar/features/customer/data/models/invoice_model.dart';
import 'package:servicar/features/customer/data/models/payment_model.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/invoice/data/datasources/local/invoice_local_datasource.dart';
import 'package:servicar/features/invoice/data/repositories/invoice_repository_impl.dart';
import 'package:servicar/features/invoice/domain/failures/invoice_failure.dart';
import 'package:servicar/features/invoice/domain/usecases/params/register_invoice_params.dart';
import 'package:servicar/features/invoice/domain/usecases/register_invoice_usecase.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';
import 'package:servicar/features/payment/domain/repositories/payment_repository.dart';

/// Cross-feature integration test — Invoice mutations drive the
/// Balance derivation.
///
/// The brief asks specifically that creating, updating, and
/// deleting invoices changes the customer's balance — and that
/// invalid invoices do not affect it. This file exercises the
/// *real* [InvoiceRepositoryImpl] (against an in-memory invoice
/// datasource fake) alongside the *real*
/// [CalculateCustomerBalanceUseCase] (against an in-memory payment
/// repository) to prove the round-trip: Invoice CRUD → Balance
/// re-derivation.
///
/// ─── Why a fake datasource instead of real Isar ───────────────────
/// The Isar integration is exercised separately in
/// `invoice_isar_impl_test.dart` (skipped on Windows due to
/// `libisar.dll` not being shipped). This file stays
/// platform-independent so it always runs on the Windows test
/// host, where the brief-scenario integration assertions are most
/// often requested.

// ─── Builders ────────────────────────────────────────────────────────

CustomerEntity _customer(String id) =>
    CustomerEntity(id: id, fullName: 'Alice', phoneNumber: '+98 912 0');

InvoiceEntity _seed({
  required String id,
  required String customerUuid,
  required double totalAmount,
}) => InvoiceEntity(
  id: id,
  customerUuid: customerUuid,
  invoiceNumber: 'INV-$id',
  issueDate: DateTime.utc(2026, 1, 1),
  totalAmount: totalAmount,
);

InvoiceEntity _pastDatedSeed({
  required String id,
  required String customerUuid,
  required double totalAmount,
}) => InvoiceEntity(
  id: id,
  customerUuid: customerUuid,
  invoiceNumber: 'INV-$id',
  // Far in the past so the future-issueDate warning is never
  // emitted by `InvoiceOperationOutcome.withDetectedWarnings`.
  issueDate: DateTime.utc(2000, 1, 1),
  totalAmount: totalAmount,
);

// ─── In-memory invoice datasource ────────────────────────────────────

class InMemoryInvoiceLocalDataSource implements InvoiceLocalDataSource {
  InMemoryInvoiceLocalDataSource([Map<String, InvoiceModel>? seed])
    : _store = {...?seed};

  final Map<String, InvoiceModel> _store;

  @override
  Future<InvoiceModel?> getById(String id) async => _store[id];

  @override
  Future<List<InvoiceModel>> getByCustomer(String customerUuid) async =>
      _store.values
          .where((m) => m.customerUuid == customerUuid)
          .toList(growable: false);

  @override
  Future<double> getTotalByCustomer(String customerUuid) async {
    var total = 0.0;
    for (final m in _store.values) {
      if (m.customerUuid == customerUuid) total += m.totalAmount;
    }
    return total;
  }

  @override
  Future<void> save(InvoiceModel model) async {
    _store[model.id] = model;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}

// ─── In-memory payment repository ────────────────────────────────────
// We only implement what `CalculateCustomerBalanceUseCase` needs:
// `getPaymentsByCustomer`. The rest is `throw UnimplementedError` so
// any unintended call fails loudly.

class InMemoryPaymentRepo implements PaymentRepository {
  InMemoryPaymentRepo([Map<String, PaymentModel>? seed])
    : _store = {...?seed};

  final Map<String, PaymentModel> _store;

  PaymentEntity _toEntity(PaymentModel m) => PaymentEntity(
    id: m.id,
    customerUuid: m.customerUuid,
    invoiceUuid: m.invoiceUuid,
    amount: m.amount,
    paidAt: m.paidAt,
    method: PaymentMethod.fromWire(m.method),
    note: m.note,
  );

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByCustomer(
    String customerUuid,
  ) async {
    final list = _store.values
        .where((m) => m.customerUuid == customerUuid)
        .map(_toEntity)
        .toList(growable: false);
    return Right<PaymentFailure, List<PaymentEntity>>(list);
  }

  @override
  Future<Either<PaymentFailure, List<PaymentEntity>>> getPaymentsByInvoice(
    String invoiceUuid,
  ) async {
    final list = _store.values
        .where((m) => m.invoiceUuid == invoiceUuid)
        .map(_toEntity)
        .toList(growable: false);
    return Right<PaymentFailure, List<PaymentEntity>>(list);
  }

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

  @override
  Future<Either<PaymentFailure, Unit>> deletePayment(String id) async =>
      throw UnimplementedError();
}

// ─── In-memory customer repository ───────────────────────────────────

class InMemoryCustomerRepo implements CustomerRepository {
  InMemoryCustomerRepo([Map<String, CustomerEntity>? seed])
    : _store = {...?seed};

  final Map<String, CustomerEntity> _store;

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async {
    final c = _store[id];
    return c == null
        ? Left(CustomerNotFoundFailure(id: id))
        : Right(c);
  }

  @override
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity e,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity e,
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
  Future<Either<CustomerFailure, double>> getCustomerBalance(
    String id,
  ) async => throw UnimplementedError();
}

// ─── Helpers ─────────────────────────────────────────────────────────

/// Build a [CalculateCustomerBalanceUseCase] wired to the supplied
/// in-memory datasources.
CalculateCustomerBalanceUseCase _uc({
  required InMemoryInvoiceLocalDataSource invoiceDs,
  required InMemoryCustomerRepo customerRepo,
  required InMemoryPaymentRepo paymentRepo,
}) {
  return CalculateCustomerBalanceUseCase(
    customerRepository: customerRepo,
    invoiceRepository: InvoiceRepositoryImpl(
      localDataSource: invoiceDs,
    ),
    paymentRepository: paymentRepo,
  );
}

/// Build a [RegisterInvoiceUseCase] for the gate-short-circuit
/// tests where a "tried to register an invalid invoice" flow must
/// not change the in-memory store.
RegisterInvoiceUseCase _register({
  required InvoiceRepositoryImpl invoiceRepo,
  required InMemoryCustomerRepo customerRepo,
}) {
  return RegisterInvoiceUseCase(
    invoiceRepository: invoiceRepo,
    customerRepository: customerRepo,
  );
}

Future<CustomerBalanceResult> _expectRight(
  Future<Either<BalanceFailure, CustomerBalanceResult>> fut,
) async {
  final r = await fut;
  expect(
    r.isRight,
    isTrue,
    reason:
        'Expected success; got ${r.leftOrNull?.message ?? 'unknown'}',
  );
  return (r as Right<BalanceFailure, CustomerBalanceResult>).value;
}

void main() {
  group('Invoice ⨯ Balance integration — brief scenarios', () {
    test(
      'Scenario 1: invoice 1,000,000 + payment 0 → -1,000,000 debtor',
      () async {
        final invoiceDs = InMemoryInvoiceLocalDataSource();
        final customerRepo =
            InMemoryCustomerRepo({'cust-1': _customer('cust-1')});
        final paymentRepo = InMemoryPaymentRepo();
        final invoiceRepo =
            InvoiceRepositoryImpl(localDataSource: invoiceDs);

        // Baseline: no invoices, no payments → 0 settled.
        final before = await _expectRight(
          _uc(
            invoiceDs: invoiceDs,
            customerRepo: customerRepo,
            paymentRepo: paymentRepo,
          )('cust-1'),
        );
        expect(before.balance, 0.0);
        expect(before.status, BalanceStatus.settled);

        // Create invoice 1,000,000 → balance -1,000,000.
        await invoiceRepo.createInvoice(
          _seed(
            id: 'inv-1',
            customerUuid: 'cust-1',
            totalAmount: 1_000_000.0,
          ),
        );
        final after = await _expectRight(
          _uc(
            invoiceDs: invoiceDs,
            customerRepo: customerRepo,
            paymentRepo: paymentRepo,
          )('cust-1'),
        );
        expect(after.balance, -1_000_000.0);
        expect(after.status, BalanceStatus.debtor);
        expect(after.invoiceCount, 1);
        expect(after.paymentCount, 0);
      },
    );

    test(
      'Scenario 2: invoice 1,000,000 + payment 1,000,000 → 0 settled',
      () async {
        final invoiceDs = InMemoryInvoiceLocalDataSource();
        final customerRepo =
            InMemoryCustomerRepo({'cust-1': _customer('cust-1')});
        final paymentRepo = InMemoryPaymentRepo({
          'pay-1': PaymentModel(
            id: 'pay-1',
            customerUuid: 'cust-1',
            invoiceUuid: 'inv-1',
            amount: 1_000_000.0,
            paidAt: DateTime.utc(2026, 1, 2),
            method: 'cash',
          ),
        });
        final invoiceRepo =
            InvoiceRepositoryImpl(localDataSource: invoiceDs);

        await invoiceRepo.createInvoice(
          _seed(
            id: 'inv-1',
            customerUuid: 'cust-1',
            totalAmount: 1_000_000.0,
          ),
        );

        final result = await _expectRight(
          _uc(
            invoiceDs: invoiceDs,
            customerRepo: customerRepo,
            paymentRepo: paymentRepo,
          )('cust-1'),
        );
        expect(result.balance, 0.0);
        expect(result.status, BalanceStatus.settled);
        expect(result.invoicesTotal, 1_000_000.0);
        expect(result.paymentsTotal, 1_000_000.0);
      },
    );

    test(
      'Scenario 3: invoice 1,000,000 + payment 1,500,000 → '
      '+500,000 creditor',
      () async {
        final invoiceDs = InMemoryInvoiceLocalDataSource();
        final customerRepo =
            InMemoryCustomerRepo({'cust-1': _customer('cust-1')});
        final paymentRepo = InMemoryPaymentRepo({
          'pay-1': PaymentModel(
            id: 'pay-1',
            customerUuid: 'cust-1',
            invoiceUuid: 'inv-1',
            amount: 1_500_000.0,
            paidAt: DateTime.utc(2026, 1, 2),
            method: 'transfer',
          ),
        });
        final invoiceRepo =
            InvoiceRepositoryImpl(localDataSource: invoiceDs);

        await invoiceRepo.createInvoice(
          _pastDatedSeed(
            id: 'inv-1',
            customerUuid: 'cust-1',
            totalAmount: 1_000_000.0,
          ),
        );

        final result = await _expectRight(
          _uc(
            invoiceDs: invoiceDs,
            customerRepo: customerRepo,
            paymentRepo: paymentRepo,
          )('cust-1'),
        );
        expect(result.balance, 500_000.0);
        expect(result.status, BalanceStatus.creditor);
      },
    );
  });

  group('Invoice ⨯ Balance integration — mutation flows', () {
    test(
      'Updating invoice total (1,000,000 → 2,000,000) re-derives '
      'balance correctly',
      () async {
        final invoiceDs = InMemoryInvoiceLocalDataSource();
        final customerRepo =
            InMemoryCustomerRepo({'cust-1': _customer('cust-1')});
        final paymentRepo = InMemoryPaymentRepo();
        final invoiceRepo =
            InvoiceRepositoryImpl(localDataSource: invoiceDs);

        await invoiceRepo.createInvoice(
          _pastDatedSeed(
            id: 'inv-1',
            customerUuid: 'cust-1',
            totalAmount: 1_000_000.0,
          ),
        );
        final before = await _expectRight(
          _uc(
            invoiceDs: invoiceDs,
            customerRepo: customerRepo,
            paymentRepo: paymentRepo,
          )('cust-1'),
        );
        expect(before.balance, -1_000_000.0);

        await invoiceRepo.updateInvoice(
          _pastDatedSeed(
            id: 'inv-1',
            customerUuid: 'cust-1',
            totalAmount: 2_000_000.0,
          ),
        );
        final after = await _expectRight(
          _uc(
            invoiceDs: invoiceDs,
            customerRepo: customerRepo,
            paymentRepo: paymentRepo,
          )('cust-1'),
        );
        expect(after.balance, -2_000_000.0);
        expect(after.status, BalanceStatus.debtor);
      },
    );

    test('Deleting an invoice removes it from balance derivation',
        () async {
      final invoiceDs = InMemoryInvoiceLocalDataSource();
      final customerRepo =
          InMemoryCustomerRepo({'cust-1': _customer('cust-1')});
      final paymentRepo = InMemoryPaymentRepo();
      final invoiceRepo =
          InvoiceRepositoryImpl(localDataSource: invoiceDs);

      await invoiceRepo.createInvoice(
        _pastDatedSeed(
          id: 'inv-1',
          customerUuid: 'cust-1',
          totalAmount: 1_000_000.0,
        ),
      );
      await invoiceRepo.createInvoice(
        _pastDatedSeed(
          id: 'inv-2',
          customerUuid: 'cust-1',
          totalAmount: 500_000.0,
        ),
      );
      final before = await _expectRight(
        _uc(
          invoiceDs: invoiceDs,
          customerRepo: customerRepo,
          paymentRepo: paymentRepo,
        )('cust-1'),
      );
      expect(before.invoiceCount, 2);
      expect(before.balance, -1_500_000.0);

      await invoiceRepo.deleteInvoice('inv-2');
      final after = await _expectRight(
        _uc(
          invoiceDs: invoiceDs,
          customerRepo: customerRepo,
          paymentRepo: paymentRepo,
        )('cust-1'),
      );
      expect(after.invoiceCount, 1);
      expect(after.balance, -1_000_000.0);
      expect(after.invoicesTotal, 1_000_000.0);
    });

    test('Number of invoices flow through getByCustomer()', () async {
      final invoiceDs = InMemoryInvoiceLocalDataSource();
      final customerRepo =
          InMemoryCustomerRepo({'cust-1': _customer('cust-1')});
      final invoiceRepo =
          InvoiceRepositoryImpl(localDataSource: invoiceDs);

      await invoiceRepo.createInvoice(
        _pastDatedSeed(
          id: 'a',
          customerUuid: 'cust-1',
          totalAmount: 100.0,
        ),
      );
      await invoiceRepo.createInvoice(
        _pastDatedSeed(
          id: 'b',
          customerUuid: 'cust-1',
          totalAmount: 200.0,
        ),
      );
      await invoiceRepo.createInvoice(
        _pastDatedSeed(
          id: 'c',
          customerUuid: 'cust-2',
          totalAmount: 999.0,
        ),
      );

      final result = await invoiceRepo.getByCustomer('cust-1');
      expect(result.isRight, isTrue);
      final list =
          (result as Right<InvoiceFailure, List<InvoiceEntity>>).value;
      expect(list, hasLength(2));
      expect(list.map((i) => i.id).toSet(), {'a', 'b'});
    });
  });

  group(
    'Invoice ⨯ Balance integration — use-case gate short-circuits',
    () {
      test(
        'Invalid invoice (negative totalAmount) → use case rejects → '
        'balance unchanged',
        () async {
          final invoiceDs = InMemoryInvoiceLocalDataSource();
          final customerRepo =
              InMemoryCustomerRepo({'cust-1': _customer('cust-1')});
          final paymentRepo = InMemoryPaymentRepo();
          final invoiceRepo =
              InvoiceRepositoryImpl(localDataSource: invoiceDs);

          final useCase = _register(
            invoiceRepo: invoiceRepo,
            customerRepo: customerRepo,
          );

          // Baseline: no invoices → 0 settled.
          final before = await _expectRight(
            _uc(
              invoiceDs: invoiceDs,
              customerRepo: customerRepo,
              paymentRepo: paymentRepo,
            )('cust-1'),
          );
          expect(before.balance, 0.0);
          expect(before.invoiceCount, 0);

          // Attempt to register a negative-total invoice.
          final invalidResult = await useCase(
            RegisterInvoiceParams(
              id: 'inv-bad',
              customerUuid: 'cust-1',
              invoiceNumber: 'INV-BAD',
              issueDate: DateTime.utc(2026, 1, 1),
              totalAmount: -1.0,
            ),
          );
          expect(
            invalidResult.isLeft,
            isTrue,
            reason:
                'Use case MUST reject negative totalAmount before '
                'the repository is called — that gate is the rule '
                'from the brief.',
          );
          final failure = invalidResult
              .leftOrNull as InvoiceFailure;
          expect(failure, isA<InvoiceValidationFailure>());
          expect(
            (failure as InvoiceValidationFailure).field,
            'totalAmount',
          );

          // The repository was NEVER called → the in-memory store
          // is empty → balance is unchanged.
          final after = await _expectRight(
            _uc(
              invoiceDs: invoiceDs,
              customerRepo: customerRepo,
              paymentRepo: paymentRepo,
            )('cust-1'),
          );
          expect(after.balance, 0.0);
          expect(after.invoiceCount, 0);
        },
      );

      test(
        'Customer-missing failure → use case rejects → '
        'balance unchanged and in-memory store still empty',
        () async {
          final invoiceDs = InMemoryInvoiceLocalDataSource();
          final customerRepo =
              InMemoryCustomerRepo(); // no rows
          final paymentRepo = InMemoryPaymentRepo();
          final invoiceRepo =
              InvoiceRepositoryImpl(localDataSource: invoiceDs);

          final useCase = _register(
            invoiceRepo: invoiceRepo,
            customerRepo: customerRepo,
          );

          final result = await useCase(
            RegisterInvoiceParams(
              id: 'inv-orphan',
              customerUuid: 'cust-does-not-exist',
              invoiceNumber: 'INV-ORPHAN',
              issueDate: DateTime.utc(2026, 1, 1),
              totalAmount: 1_000_000.0,
            ),
          );
          expect(result.isLeft, isTrue);
          final failure = result.leftOrNull as InvoiceFailure;
          expect(failure, isA<InvoiceCustomerMissingFailure>());

          // The repository was NEVER called → the in-memory store
          // is empty for the orphan customerUuid.
          final list = await invoiceDs.getByCustomer(
            'cust-does-not-exist',
          );
          expect(list, isEmpty);
        },
      );
    },
  );
}


