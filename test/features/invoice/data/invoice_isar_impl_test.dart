import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/mappers/invoice_mapper.dart';
import 'package:servicar/features/customer/data/models/customer_isar.dart';
import 'package:servicar/features/customer/data/models/invoice_isar.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
import 'package:servicar/features/invoice/data/datasources/local/invoice_local_datasource.dart';
import 'package:servicar/features/invoice/data/datasources/local/invoice_local_datasource_impl.dart';
import 'package:servicar/features/invoice/data/repositories/invoice_repository_impl.dart';
import 'package:servicar/features/invoice/domain/failures/invoice_failure.dart';

/// Invoice Persistence — real Isar (physical-storage round-trip).
///
/// Mirrors `service_isar_impl_test.dart` exactly:
///   * Seeds a single [CustomerIsar] row so the customerUuid FK
///     used by every Invoice fixture points at a real Customer row.
///   * Skips on Windows. The project only ships the Android `.so`
///     binary, so `Isar.open` cannot load `libisar.dll` on Windows.
///     Run on Linux/macOS CI to verify physical persistence
///     end-to-end.
void main() {
  group(
    'Invoice Persistence (real Isar — physical storage)',
    () {
      late Directory dir;
      late Isar isar;

      setUp(() async {
        dir = await Directory.systemTemp.createTemp(
          'servicar_invoice_isar_test_',
        );
        isar = await Isar.open(
          [CustomerIsarSchema, InvoiceIsarSchema],
          directory: dir.path,
          name: 'servicar_invoice_isar_test',
          inspector: false,
        );
      });

      tearDown(() async {
        if (isar.isOpen) {
          await isar.close();
        }
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      });

      Future<void> seedCustomer(String uuid) async {
        await isar.writeTxn(() async {
          await isar.customerIsars.putByUuid(
            CustomerIsar()
              ..uuid = uuid
              ..fullName = 'Test'
              ..phoneNumber = '+1 000 000'
              ..tags = []
              ..balance = 0.0,
          );
        });
      }

      InvoiceLocalDataSource newSource() =>
          InvoiceLocalDataSourceImpl(isar);
      InvoiceRepositoryImpl newRepo() =>
          InvoiceRepositoryImpl(localDataSource: newSource());

      InvoiceEntity seedInvoice({
        String id = 'inv-1',
        String customerUuid = 'cust-1',
        double totalAmount = 100.0,
        String invoiceNumber = 'INV-1',
        InvoiceStatus status = InvoiceStatus.issued,
      }) => InvoiceEntity(
        id: id,
        customerUuid: customerUuid,
        invoiceNumber: invoiceNumber,
        issueDate: DateTime.utc(2026, 1, 1),
        status: status,
        totalAmount: totalAmount,
      );

      test('Create & Read round-trip preserves all Invoice fields',
          () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          seedInvoice(
            id: 'inv-1',
            customerUuid: 'cust-1',
            totalAmount: 250.0,
            invoiceNumber: 'INV-001',
          ).toModel(),
        );

        final read = await source.getById('inv-1');
        expect(read, isNotNull);
        expect(read!.id, 'inv-1');
        expect(read.customerUuid, 'cust-1');
        expect(read.invoiceNumber, 'INV-001');
        expect(read.totalAmount, 250.0);
        expect(read.status, 'issued');
      });

      test('getByCustomer filters by FK', () async {
        await seedCustomer('cust-1');
        await seedCustomer('cust-2');
        final source = newSource();
        await source.save(seedInvoice(id: 'a', customerUuid: 'cust-1')
            .toModel());
        await source.save(seedInvoice(id: 'b', customerUuid: 'cust-2')
            .toModel());
        await source.save(seedInvoice(id: 'c', customerUuid: 'cust-1')
            .toModel());

        final list = await source.getByCustomer('cust-1');
        expect(list.map((m) => m.id).toSet(), {'a', 'c'});

        final listB = await source.getByCustomer('cust-2');
        expect(listB.map((m) => m.id), ['b']);
      });

      test('Update via upsert (no duplicate row)', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(seedInvoice(id: 'u1', totalAmount: 10.0)
            .toModel());
        await source.save(seedInvoice(id: 'u1', totalAmount: 25.0)
            .toModel());

        final read = await source.getById('u1');
        expect(read!.totalAmount, 25.0);

        final all = await source.getByCustomer('cust-1');
        expect(all, hasLength(1));
      });

      test('Delete removes the record', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(seedInvoice(id: 'd').toModel());
        expect(await source.getById('d'), isNotNull);

        await source.delete('d');
        expect(await source.getById('d'), isNull);
      });

      test('getById returns null when the record is absent', () async {
        final source = newSource();
        expect(await source.getById('does-not-exist'), isNull);
      });

      test('getByCustomer returns empty list when no matches',
          () async {
        final source = newSource();
        expect(await source.getByCustomer('nobody'), isEmpty);
      });

      test('getTotalByCustomer aggregates every row', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          seedInvoice(id: 'a', totalAmount: 500_000.0).toModel(),
        );
        await source.save(
          seedInvoice(id: 'b', totalAmount: 300_000.0).toModel(),
        );
        expect(await source.getTotalByCustomer('cust-1'), 800_000.0);
      });

      test(
        'Persistence: write → close → reopen → read survives restart',
        () async {
          await seedCustomer('cust-1');
          final sWrite = newSource();
          await sWrite.save(
            seedInvoice(
              id: 'persist-1',
              totalAmount: 75.0,
              invoiceNumber: 'INV-PERSIST-1',
              status: InvoiceStatus.paid,
            ).toModel(),
          );

          await isar.close();

          isar = await Isar.open(
            [CustomerIsarSchema, InvoiceIsarSchema],
            directory: dir.path,
            name: 'servicar_invoice_isar_test',
            inspector: false,
          );

          final sRead = newSource();
          final read = await sRead.getById('persist-1');
          expect(read, isNotNull);
          expect(read!.id, 'persist-1');
          expect(read.invoiceNumber, 'INV-PERSIST-1');
          expect(read.status, 'paid');
          expect(read.totalAmount, 75.0);
        },
      );

      test(
        'Repository: getById for absent id → InvoiceNotFoundFailure',
        () async {
          final repo = newRepo();
          final fetched = await repo.getById('missing');
          expect(fetched.isLeft, isTrue);
          expect(
            (fetched as Left<InvoiceFailure, InvoiceEntity>).value,
            isA<InvoiceNotFoundFailure>(),
          );
        },
      );

      test(
        'Repository: createInvoice on a closed Isar → '
        'InvoiceStorageFailure',
        () async {
          await seedCustomer('cust-1');
          final repo = newRepo();
          await isar.close();

          final result = await repo.createInvoice(
            seedInvoice(id: 'inv-x'),
          );
          expect(result.isLeft, isTrue);
          final failure =
              (result as Left<InvoiceFailure, InvoiceEntity>).value;
          expect(failure, isA<InvoiceStorageFailure>());
          expect(
            (failure as InvoiceStorageFailure).operation,
            'createInvoice',
          );
        },
      );

      test(
        'Repository: deleteInvoice on a closed Isar → '
        'InvoiceStorageFailure',
        () async {
          await seedCustomer('cust-1');
          final source = newSource();
          await source.save(seedInvoice(id: 'inv-d').toModel());

          final repo = newRepo();
          await isar.close();

          final result = await repo.deleteInvoice('inv-d');
          expect(result.isLeft, isTrue);
          final failure =
              (result as Left<InvoiceFailure, Unit>).value;
          expect(failure, isA<InvoiceStorageFailure>());
          expect(
            (failure as InvoiceStorageFailure).operation,
            'deleteInvoice',
          );
        },
      );
    },
    skip: Platform.isWindows
        ? 'libisar.dll is not shipped for the Windows test host '
              '(isar_community_flutter_libs only includes Android .so). '
              'Run this suite on Linux/macOS CI to verify physical '
              'persistence end-to-end.'
        : null,
  );
}
