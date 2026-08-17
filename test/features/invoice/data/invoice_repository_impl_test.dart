import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/models/invoice_model.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
import 'package:servicar/features/invoice/data/datasources/local/invoice_local_datasource.dart';
import 'package:servicar/features/invoice/data/repositories/invoice_repository_impl.dart';
import 'package:servicar/features/invoice/domain/failures/invoice_failure.dart';

/// In-memory fake of [InvoiceLocalDataSource].
///
/// Mirrors the customer / service / payment test fakes so the
/// repository-layer tests stay independent of the Isar platform
/// channel. The repository's `_readBack` round-trip depends on
/// `getById`, so the fake is faithful about it.
class InMemoryInvoiceLocalDataSource implements InvoiceLocalDataSource {
  InMemoryInvoiceLocalDataSource([Map<String, InvoiceModel>? seed])
    : _store = {...?seed};

  final Map<String, InvoiceModel> _store;

  @override
  Future<InvoiceModel?> getById(String id) async => _store[id];

  @override
  Future<List<InvoiceModel>> getByCustomer(String customerUuid) async => _store
      .values
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
  Future<int> countAll() async => _store.length;

  @override
  Future<void> save(InvoiceModel model) async {
    _store[model.id] = model;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}

void main() {
  group('InvoiceRepositoryImpl', () {
    late InvoiceRepositoryImpl repo;
    late InMemoryInvoiceLocalDataSource fake;

    setUp(() {
      fake = InMemoryInvoiceLocalDataSource();
      repo = InvoiceRepositoryImpl(localDataSource: fake);
    });

    InvoiceEntity seed({
      String id = 'inv-1',
      String customerUuid = 'cust-1',
      double total = 1_000_000.0,
      String invoiceNumber = 'INV-1',
      InvoiceStatus status = InvoiceStatus.issued,
      List<InvoiceLineItemEntity> items = const [],
    }) => InvoiceEntity(
      id: id,
      customerUuid: customerUuid,
      invoiceNumber: invoiceNumber,
      issueDate: DateTime.utc(2026, 1, 1),
      status: status,
      lineItems: items,
      totalAmount: total,
    );

    test('createInvoice round-trips through getById', () async {
      final result = await repo.createInvoice(seed(total: 1_000_000.0));
      expect(result.isRight, isTrue);
      expect(
        (result as Right<InvoiceFailure, InvoiceEntity>).value.id,
        'inv-1',
      );

      final read = await repo.getById('inv-1');
      expect(read.isRight, isTrue);
      final invoice =
          (read as Right<InvoiceFailure, InvoiceEntity>).value;
      expect(invoice.customerUuid, 'cust-1');
      expect(invoice.totalAmount, 1_000_000.0);
      expect(invoice.invoiceNumber, 'INV-1');
    });

    test(
      'updateInvoice overwrites the row (replace: true behaviour)',
      () async {
        await fake.save(
          InvoiceModel(
            id: 'inv-1',
            customerUuid: 'cust-1',
            invoiceNumber: 'INV-OLD',
            issueDate: DateTime.utc(2026, 1, 1),
            totalAmount: 100.0,
          ),
        );
        final res = await repo.updateInvoice(seed(total: 250.0));
        expect(res.isRight, isTrue);
        final read = await repo.getById('inv-1');
        expect(
          (read as Right<InvoiceFailure, InvoiceEntity>).value.totalAmount,
          250.0,
        );
      },
    );

    test('getById returns InvoiceNotFoundFailure on miss', () async {
      final fetched = await repo.getById('does-not-exist');
      expect(fetched.isLeft, isTrue);
      expect(
        (fetched as Left<InvoiceFailure, InvoiceEntity>).value,
        isA<InvoiceNotFoundFailure>(),
      );
    });

    test('getByCustomer filters by FK', () async {
      await fake.save(
        InvoiceModel(
          id: 'a',
          customerUuid: 'cust-1',
          invoiceNumber: 'A',
          issueDate: DateTime.utc(2026, 1, 1),
          totalAmount: 1.0,
        ),
      );
      await fake.save(
        InvoiceModel(
          id: 'b',
          customerUuid: 'cust-2',
          invoiceNumber: 'B',
          issueDate: DateTime.utc(2026, 1, 1),
          totalAmount: 1.0,
        ),
      );
      await fake.save(
        InvoiceModel(
          id: 'c',
          customerUuid: 'cust-1',
          invoiceNumber: 'C',
          issueDate: DateTime.utc(2026, 1, 1),
          totalAmount: 1.0,
        ),
      );

      final list = await repo.getByCustomer('cust-1');
      expect(list.isRight, isTrue);
      final invoices =
          (list as Right<InvoiceFailure, List<InvoiceEntity>>).value;
      expect(invoices, hasLength(2));
      expect(invoices.map((i) => i.id).toSet(), {'a', 'c'});
    });

    test('deleteInvoice returns Right(Unit) and removes the row',
        () async {
      await fake.save(
        InvoiceModel(
          id: 'd',
          customerUuid: 'cust-1',
          invoiceNumber: 'D',
          issueDate: DateTime.utc(2026, 1, 1),
          totalAmount: 1.0,
        ),
      );
      final result = await repo.deleteInvoice('d');
      expect(result, const Right<InvoiceFailure, Unit>(Unit.instance));
      expect(await fake.getById('d'), isNull);
    });

    test(
      'mapper is stable: line items, status, nullable notes/issueDate '
      'preserved',
      () async {
        const items = <InvoiceLineItemEntity>[
          InvoiceLineItemEntity(
            description: 'Oil change',
            quantity: 1.0,
            unitPrice: 100.0,
            total: 100.0,
          ),
          InvoiceLineItemEntity(
            description: 'Labor',
            quantity: 2.0,
            unitPrice: 50.0,
            total: 100.0,
          ),
        ];
        await fake.save(
          InvoiceModel(
            id: 'i',
            customerUuid: 'cust-1',
            invoiceNumber: 'INV-I',
            issueDate: DateTime.utc(2026, 1, 1),
            dueDate: DateTime.utc(2026, 2, 1),
            status: 'draft',
            totalAmount: 200.0,
            notes: 'VIP — please call',
            lineItems: const [
              InvoiceLineItemModel(
                description: 'Oil change',
                quantity: 1.0,
                unitPrice: 100.0,
                total: 100.0,
              ),
              InvoiceLineItemModel(
                description: 'Labor',
                quantity: 2.0,
                unitPrice: 50.0,
                total: 100.0,
              ),
            ],
          ),
        );
        final fetched = await repo.getById('i');
        expect(fetched.isRight, isTrue);
        final e =
            (fetched as Right<InvoiceFailure, InvoiceEntity>).value;
        expect(e.status, InvoiceStatus.draft);
        expect(e.dueDate, DateTime.utc(2026, 2, 1));
        expect(e.notes, 'VIP — please call');
        expect(e.lineItems, items);
        expect(e.totalAmount, 200.0);
      },
    );

    test(
      'source-layer exception is wrapped as InvoiceStorageFailure',
      () async {
        final broken = _BrokenInvoiceLocalDataSource();
        final r = InvoiceRepositoryImpl(localDataSource: broken);

        final result = await r.createInvoice(seed());
        expect(result.isLeft, isTrue);
        final failure =
            (result as Left<InvoiceFailure, InvoiceEntity>).value;
        expect(failure, isA<InvoiceStorageFailure>());
        expect((failure as InvoiceStorageFailure).operation, 'createInvoice');
      },
    );

    test('getTotalByCustomer sums every invoice row for the customer',
        () async {
      await fake.save(
        InvoiceModel(
          id: 'a',
          customerUuid: 'cust-1',
          invoiceNumber: 'A',
          issueDate: DateTime.utc(2026, 1, 1),
          totalAmount: 500_000.0,
        ),
      );
      await fake.save(
        InvoiceModel(
          id: 'b',
          customerUuid: 'cust-1',
          invoiceNumber: 'B',
          issueDate: DateTime.utc(2026, 1, 2),
          totalAmount: 300_000.0,
        ),
      );
      await fake.save(
        InvoiceModel(
          id: 'c',
          customerUuid: 'cust-2',
          invoiceNumber: 'C',
          issueDate: DateTime.utc(2026, 1, 3),
          totalAmount: 999_000.0,
        ),
      );

      final total = await repo.getTotalByCustomer('cust-1');
      expect(
        total,
        const Right<InvoiceFailure, double>(800_000.0),
      );
      final empty = await repo.getTotalByCustomer('cust-3');
      expect(empty, const Right<InvoiceFailure, double>(0.0));
    });

    test('getInvoiceCount counts every persisted invoice', () async {
      await fake.save(
        InvoiceModel(
          id: 'a',
          customerUuid: 'cust-1',
          invoiceNumber: 'A',
          issueDate: DateTime.utc(2026, 1, 1),
          totalAmount: 1.0,
        ),
      );
      await fake.save(
        InvoiceModel(
          id: 'b',
          customerUuid: 'cust-2',
          invoiceNumber: 'B',
          issueDate: DateTime.utc(2026, 1, 1),
          totalAmount: 1.0,
        ),
      );

      final count = await repo.getInvoiceCount();
      expect(count, const Right<InvoiceFailure, int>(2));

      final emptyRepo = InvoiceRepositoryImpl(
        localDataSource: InMemoryInvoiceLocalDataSource(),
      );
      final empty = await emptyRepo.getInvoiceCount();
      expect(empty, const Right<InvoiceFailure, int>(0));
    });

    test(
      'count failure is wrapped as InvoiceStorageFailure',
      () async {
        final r = InvoiceRepositoryImpl(
          localDataSource: _BrokenInvoiceLocalDataSource(),
        );

        final result = await r.getInvoiceCount();
        expect(result.isLeft, isTrue);
        final failure = (result as Left<InvoiceFailure, int>).value;
        expect(failure, isA<InvoiceStorageFailure>());
        expect((failure as InvoiceStorageFailure).operation, 'getInvoiceCount');
      },
    );
  });
}

/// Always-throws datasource. Used to verify the repository's
/// try/catch contract without involving the Isar platform channel.
class _BrokenInvoiceLocalDataSource implements InvoiceLocalDataSource {
  @override
  Future<void> save(InvoiceModel model) async {
    throw StateError('boom');
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<InvoiceModel?> getById(String id) async => null;

  @override
  Future<List<InvoiceModel>> getByCustomer(String uuid) async =>
      const <InvoiceModel>[];

  @override
  Future<double> getTotalByCustomer(String uuid) async => 0.0;

  @override
  Future<int> countAll() async => throw StateError('boom');
}
