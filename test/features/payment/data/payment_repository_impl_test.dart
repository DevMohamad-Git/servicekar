import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/models/payment_model.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/payment/data/datasources/local/payment_local_datasource.dart';
import 'package:servicar/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:servicar/features/payment/domain/failures/payment_failure.dart';

/// In-memory fake of [PaymentLocalDataSource].
///
/// Mirrors the customer / service fakes so the repository tests
/// stay independent of the Isar platform channel. The
/// repository's `_readBack` round-trip depends on `getById`, so
/// the fake is faithful about it.
class InMemoryPaymentLocalDataSource implements PaymentLocalDataSource {
  InMemoryPaymentLocalDataSource([Map<String, PaymentModel>? seed])
    : _store = {...?seed};

  final Map<String, PaymentModel> _store;

  @override
  Future<PaymentModel?> getById(String id) async => _store[id];

  @override
  Future<List<PaymentModel>> getByCustomer(String customerUuid) async => _store
      .values
      .where((m) => m.customerUuid == customerUuid)
      .toList(growable: false);

  @override
  Future<List<PaymentModel>> getByInvoice(String invoiceUuid) async => _store
      .values
      .where((m) => m.invoiceUuid == invoiceUuid)
      .toList(growable: false);

  @override
  Future<void> save(PaymentModel model) async {
    _store[model.id] = model;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}

void main() {
  final baseTime = DateTime.utc(2026, 1, 1);

  group('PaymentRepositoryImpl', () {
    late PaymentRepositoryImpl repo;
    late InMemoryPaymentLocalDataSource fake;

    setUp(() {
      fake = InMemoryPaymentLocalDataSource();
      repo = PaymentRepositoryImpl(localDataSource: fake);
    });

    PaymentEntity seed({
      String id = 'pay-1',
      String customerUuid = 'cust-1',
      double amount = 100.0,
      DateTime? paidAt,
      String? invoiceUuid,
    }) => PaymentEntity(
      id: id,
      customerUuid: customerUuid,
      amount: amount,
      paidAt: paidAt ?? baseTime,
      invoiceUuid: invoiceUuid,
    );

    test('createPayment round-trips through getById', () async {
      final saved = await repo.createPayment(
        seed(amount: 100.0, paidAt: baseTime),
      );
      expect(saved.isRight, isTrue);
      expect((saved as Right<PaymentFailure, PaymentEntity>).value.id, 'pay-1');

      final read = await repo.getPaymentById('pay-1');
      expect(read.isRight, isTrue);
      final e = (read as Right<PaymentFailure, PaymentEntity>).value;
      expect(e.amount, 100.0);
      expect(e.customerUuid, 'cust-1');
      expect(e.paidAt, baseTime);
    });

    test(
      'updatePayment overwrites the row (replace: true behaviour)',
      () async {
        await fake.save(
          PaymentModel(
            id: 'pay-1',
            customerUuid: 'cust-1',
            amount: 50.0,
            paidAt: baseTime,
          ),
        );
        final res = await repo.updatePayment(
          seed(amount: 75.0, paidAt: DateTime.utc(2026, 1, 2)),
        );
        expect(res.isRight, isTrue);
        final read = await repo.getPaymentById('pay-1');
        expect(
          (read as Right<PaymentFailure, PaymentEntity>).value.amount,
          75.0,
        );
      },
    );

    test('getPaymentById returns PaymentNotFoundFailure on miss', () async {
      final fetched = await repo.getPaymentById('does-not-exist');
      expect(fetched.isLeft, isTrue);
      expect(
        (fetched as Left<PaymentFailure, PaymentEntity>).value,
        isA<PaymentNotFoundFailure>(),
      );
    });

    test('getPaymentsByInvoice filters by FK', () async {
      await fake.save(
        PaymentModel(
          id: 'a',
          customerUuid: 'cust-1',
          invoiceUuid: 'inv-1',
          amount: 10.0,
          paidAt: baseTime,
        ),
      );
      await fake.save(
        PaymentModel(
          id: 'b',
          customerUuid: 'cust-1',
          invoiceUuid: 'inv-2',
          amount: 20.0,
          paidAt: DateTime.utc(2026, 1, 2),
        ),
      );
      await fake.save(
        PaymentModel(
          id: 'c',
          customerUuid: 'cust-1',
          invoiceUuid: 'inv-1',
          amount: 30.0,
          paidAt: DateTime.utc(2026, 1, 3),
        ),
      );
      // On-account payment (no invoice).
      await fake.save(
        PaymentModel(
          id: 'd',
          customerUuid: 'cust-1',
          invoiceUuid: null,
          amount: 100.0,
          paidAt: DateTime.utc(2026, 1, 4),
        ),
      );

      final list = await repo.getPaymentsByInvoice('inv-1');
      expect(list.isRight, isTrue);
      final payments =
          (list as Right<PaymentFailure, List<PaymentEntity>>).value;
      expect(payments.map((p) => p.id).toSet(), {'a', 'c'});
      // 'd' (on-account) MUST NOT appear because invoiceUuid == null.
    });

    test(
      'getPaymentsByCustomer returns on-account AND invoice-tied rows',
      () async {
        await fake.save(
          PaymentModel(
            id: 'a',
            customerUuid: 'cust-1',
            invoiceUuid: 'inv-1',
            amount: 10.0,
            paidAt: baseTime,
          ),
        );
        await fake.save(
          PaymentModel(
            id: 'b',
            customerUuid: 'cust-1',
            invoiceUuid: null, // on-account
            amount: 100.0,
            paidAt: DateTime.utc(2026, 1, 2),
          ),
        );
        await fake.save(
          PaymentModel(
            id: 'c',
            customerUuid: 'cust-2', // different customer
            invoiceUuid: null,
            amount: 999.0,
            paidAt: DateTime.utc(2026, 1, 3),
          ),
        );

        final list = await repo.getPaymentsByCustomer('cust-1');
        expect(list.isRight, isTrue);
        final payments =
            (list as Right<PaymentFailure, List<PaymentEntity>>).value;
        expect(payments.map((p) => p.id).toSet(), {'a', 'b'});
      },
    );

    test('deletePayment returns Right(Unit) and removes the row', () async {
      await fake.save(
        PaymentModel(
          id: 'd',
          customerUuid: 'cust-1',
          amount: 5.0,
          paidAt: baseTime,
        ),
      );
      final result = await repo.deletePayment('d');
      expect(result, const Right<PaymentFailure, Unit>(Unit.instance));
      expect(await fake.getById('d'), isNull);
    });

    test('mapper is stable: nullable invoiceUuid, method wire, paidAt '
        'preserved', () async {
      await fake.save(
        PaymentModel(
          id: 'p',
          customerUuid: 'cust-1',
          invoiceUuid: null,
          amount: 12.5,
          paidAt: baseTime,
          method: 'transfer',
          note: 'ref-12345',
        ),
      );
      final fetched = await repo.getPaymentById('p');
      expect(fetched.isRight, isTrue);
      final e = (fetched as Right<PaymentFailure, PaymentEntity>).value;
      expect(e.amount, 12.5);
      expect(e.invoiceUuid, isNull);
      expect(e.method, PaymentMethod.transfer);
      expect(e.note, 'ref-12345');
    });

    test(
      'source-layer exception is wrapped as PaymentStorageFailure',
      () async {
        final broken = _BrokenPaymentLocalDataSource();
        final r = PaymentRepositoryImpl(localDataSource: broken);

        final result = await r.createPayment(seed(paidAt: baseTime));
        expect(result.isLeft, isTrue);
        final failure = (result as Left<PaymentFailure, PaymentEntity>).value;
        expect(failure, isA<PaymentStorageFailure>());
        expect((failure as PaymentStorageFailure).operation, 'createPayment');
      },
    );
  });
}

class _BrokenPaymentLocalDataSource implements PaymentLocalDataSource {
  @override
  Future<void> save(PaymentModel model) async {
    throw StateError('boom');
  }

  @override
  Future<PaymentModel?> getById(String id) async => null;

  @override
  Future<List<PaymentModel>> getByCustomer(String uuid) async =>
      const <PaymentModel>[];

  @override
  Future<List<PaymentModel>> getByInvoice(String uuid) async =>
      const <PaymentModel>[];

  @override
  Future<void> delete(String id) async {}
}
