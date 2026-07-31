import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:servicar/features/customer/data/models/customer_isar.dart';
import 'package:servicar/features/customer/data/models/payment_isar.dart';
import 'package:servicar/features/customer/data/models/payment_model.dart';
import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/payment/data/datasources/local/payment_local_datasource.dart';
import 'package:servicar/features/payment/data/datasources/local/payment_local_datasource_impl.dart';

/// Payment Persistence — real Isar (physical-storage round-trip).
///
/// Why we skip on Windows: same `libisar.dll` constraint as the
/// service / customer Isar suites. Run on Linux/macOS CI to
/// exercise physical persistence end-to-end.
void main() {
  group(
    'Payment Persistence (real Isar — physical storage)',
    () {
      late Directory dir;
      late Isar isar;

      setUp(() async {
        dir = await Directory.systemTemp.createTemp(
          'servicar_payment_isar_test_',
        );
        isar = await Isar.open(
          [CustomerIsarSchema, PaymentIsarSchema],
          directory: dir.path,
          name: 'servicar_payment_isar_test',
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

      PaymentLocalDataSource newSource() => PaymentLocalDataSourceImpl(isar);

      final paidAt = DateTime.utc(2026, 1, 1);

      test('Create & Read round-trip preserves Payment fields', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        final input = PaymentEntity(
          id: 'pay-1',
          customerUuid: 'cust-1',
          invoiceUuid: null,
          amount: 150_000.0,
          paidAt: paidAt,
          method: PaymentMethod.cash,
        );
        await source.save(PaymentModelX(input).model);

        final read = await source.getById('pay-1');
        expect(read, isNotNull);
        expect(read!.id, 'pay-1');
        expect(read.customerUuid, 'cust-1');
        expect(read.invoiceUuid, isNull);
        expect(read.amount, 150_000.0);
        expect(read.paidAt, paidAt);
      });

      test('getByInvoice filters by FK', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'a',
              customerUuid: 'cust-1',
              amount: 10.0,
              paidAt: paidAt,
              invoiceUuid: 'inv-1',
            ),
          ).model,
        );
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'b',
              customerUuid: 'cust-1',
              amount: 20.0,
              paidAt: DateTime.utc(2026, 1, 2),
              invoiceUuid: 'inv-2',
            ),
          ).model,
        );
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'c',
              customerUuid: 'cust-1',
              amount: 30.0,
              paidAt: DateTime.utc(2026, 1, 3),
              invoiceUuid: null, // on-account must NOT appear
            ),
          ).model,
        );

        final list = await source.getByInvoice('inv-1');
        expect(list.map((m) => m.id), ['a']);
        final listB = await source.getByInvoice('inv-2');
        expect(listB.map((m) => m.id), ['b']);
      });

      test('getByCustomer returns both invoice-tied AND on-account', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'a',
              customerUuid: 'cust-1',
              amount: 10.0,
              paidAt: paidAt,
              invoiceUuid: 'inv-1',
            ),
          ).model,
        );
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'b',
              customerUuid: 'cust-1',
              amount: 20.0,
              paidAt: DateTime.utc(2026, 1, 2),
              invoiceUuid: null,
            ),
          ).model,
        );
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'c',
              customerUuid: 'cust-2',
              amount: 999.0,
              paidAt: DateTime.utc(2026, 1, 3),
            ),
          ).model,
        );

        final list = await source.getByCustomer('cust-1');
        expect(list.map((m) => m.id).toSet(), {'a', 'b'});
      });

      test('Update via upsert (no duplicate row)', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'u1',
              customerUuid: 'cust-1',
              amount: 10.0,
              paidAt: paidAt,
            ),
          ).model,
        );
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'u1',
              customerUuid: 'cust-1',
              amount: 25.0,
              paidAt: DateTime.utc(2026, 1, 2),
            ),
          ).model,
        );

        final read = await source.getById('u1');
        expect(read!.amount, 25.0);
        final all = await source.getByCustomer('cust-1');
        expect(all, hasLength(1));
      });

      test('Delete removes the record', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          PaymentModelX(
            PaymentEntity(
              id: 'd',
              customerUuid: 'cust-1',
              amount: 5.0,
              paidAt: paidAt,
            ),
          ).model,
        );
        expect(await source.getById('d'), isNotNull);

        await source.delete('d');
        expect(await source.getById('d'), isNull);
      });

      test(
        'Persistence: write → close → reopen → read survives restart',
        () async {
          await seedCustomer('cust-1');
          final sWrite = newSource();
          await sWrite.save(
            PaymentModelX(
              PaymentEntity(
                id: 'persist-1',
                customerUuid: 'cust-1',
                amount: 75.0,
                paidAt: paidAt,
              ),
            ).model,
          );

          await isar.close();

          isar = await Isar.open(
            [CustomerIsarSchema, PaymentIsarSchema],
            directory: dir.path,
            name: 'servicar_payment_isar_test',
            inspector: false,
          );

          final sRead = newSource();
          final read = await sRead.getById('persist-1');
          expect(read, isNotNull);
          expect(read!.id, 'persist-1');
          expect(read.amount, 75.0);
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

/// Tiny `Entity → Model` bridge used only by the Isar tests so we
/// don't need to import the customer-feature mapper (which would
/// collide with the test fixture imports). Mirrors the
/// `payment_mapper.dart` contract field-for-field.
class PaymentModelX {
  PaymentModelX(this.entity);
  final PaymentEntity entity;

  PaymentModel get model => PaymentModel(
    id: entity.id,
    customerUuid: entity.customerUuid,
    invoiceUuid: entity.invoiceUuid,
    amount: entity.amount,
    paidAt: entity.paidAt,
    method: entity.method.wire,
    note: entity.note,
  );
}
