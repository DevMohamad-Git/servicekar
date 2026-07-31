import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/datasources/local/customer_local_datasource.dart';
import 'package:servicar/features/customer/data/datasources/local/customer_local_datasource_impl.dart';
import 'package:servicar/features/customer/data/models/customer_isar.dart';
import 'package:servicar/features/customer/data/models/customer_model.dart';
import 'package:servicar/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/usecases/create_customer_usecase.dart';

/// Customer Persistence — real Isar (physical-storage round-trip).
///
/// These tests are deliberately NOT based on an in-memory fake: they
/// drive the production [CustomerLocalDataSourceImpl] against a real
/// `Isar` running on a per-test temp directory. The full persistence
/// cycle (`write → close → reopen → read`) is the assertion the
/// production wiring has to pass before any UI is built on top.
///
/// ─── Why `Isar.open` is called directly (no `DatabaseService.open`,
///     no `path_provider` mock) ─────────────────────────────────────
///   * The `CustomerLocalDataSourceImpl` only needs a live `Isar`
///     handle — it never inspects `path_provider`. Calling
///     `Isar.open(schemas: [...], directory: dir.path, ...)` keeps
///     this test file self-contained.
///   * `Isar.open` is a public API; not going through
///     `DatabaseService.open` is intentional, because the latter
///     pins `inspector: kDebugMode` (which is `true` in `flutter test`
///     and would attempt to bind ports across rapid setUp/tearDown
///     cycles — see Isar v3 docs on the Inspector).
///
/// ─── Skip policy ───────────────────────────────────────────────────
///   On Windows the project's `isar_community_flutter_libs` only
///   ships the Android `.so` binary (`libisar.so` for arm64/armeabi/
///   x86/x86_64). The host test runner therefore cannot load
///   `libisar.dll` and `Isar.open` throws `Failed to load dynamic
///   library 'libisar.dll'`. The whole group is `skip:`'d on Windows
///   so local dev stays green; CI on Linux/macOS still exercises every
///   assertion below.
void main() {
  group(
    'Customer Persistence (real Isar — physical storage)',
    () {
      late Directory dir;
      late Isar isar;

      setUp(() async {
        dir = await Directory.systemTemp.createTemp('servicar_isar_test_');
        isar = await Isar.open(
          [CustomerIsarSchema],
          directory: dir.path,
          // Fixed `name` means the persistence test can re-open with
          // identical args and Isar will re-attach to the same file.
          name: 'servicar_isar_test',
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

      // Single accessor so each test that needs a DataSource is one
      // line long. Closing the underlying Isar inside one test will
      // cause subsequent touches through this `source()` to throw,
      // which is what the StorageFailure test below relies on.
      CustomerLocalDataSource newSource() => CustomerLocalDataSourceImpl(isar);

      // ════════════════════════════════════════════════════════════════
      //  Happy path
      // ════════════════════════════════════════════════════════════════

      test('Create & Read round-trip preserves all profile fields', () async {
        final source = newSource();
        const input = CustomerModel(
          id: 'c1',
          fullName: 'Alice',
          phoneNumber: '+98 912 000 0000',
          email: 'alice@example.com',
          address: 'Tehran',
          notes: 'VIP customer',
          tags: ['vip', 'cash'],
        );
        await source.save(input);

        final read = await source.getById('c1');
        expect(read, isNotNull);
        expect(read!.id, 'c1');
        expect(read.fullName, 'Alice');
        expect(read.phoneNumber, '+98 912 000 0000');
        expect(read.email, 'alice@example.com');
        expect(read.address, 'Tehran');
        expect(read.notes, 'VIP customer');
        expect(read.tags, ['vip', 'cash']);
      });

      test('Get All returns every persisted customer', () async {
        final source = newSource();
        await source.save(
          const CustomerModel(id: 'a', fullName: 'Alice', phoneNumber: '1'),
        );
        await source.save(
          const CustomerModel(id: 'b', fullName: 'Bob', phoneNumber: '2'),
        );
        await source.save(
          const CustomerModel(id: 'c', fullName: 'Charlie', phoneNumber: '3'),
        );

        final all = await source.getAll();
        expect(all.length, 3);
        expect(all.map((m) => m.id).toSet(), {'a', 'b', 'c'});
      });

      test('Search by name (case-insensitive contains)', () async {
        final source = newSource();
        await source.save(
          const CustomerModel(id: 'a', fullName: 'Alice', phoneNumber: '1'),
        );
        await source.save(
          const CustomerModel(id: 'b', fullName: 'Bob', phoneNumber: '2'),
        );
        await source.save(
          const CustomerModel(id: 'c', fullName: 'Alina', phoneNumber: '3'),
        );

        final hits = await source.search('ali');
        expect(hits.length, 2);
        expect(hits.map((m) => m.id).toSet(), {'a', 'c'});
      });

      test('Search by phone number (digits)', () async {
        final source = newSource();
        await source.save(
          const CustomerModel(
            id: 'a',
            fullName: 'Alice',
            phoneNumber: '+98 912 111',
          ),
        );
        await source.save(
          const CustomerModel(
            id: 'b',
            fullName: 'Bob',
            phoneNumber: '+98 912 222',
          ),
        );
        await source.save(
          const CustomerModel(
            id: 'c',
            fullName: 'Charlie',
            phoneNumber: '+98 933 333',
          ),
        );

        final hits = await source.search('912');
        expect(hits.length, 2);
        expect(hits.map((m) => m.id).toSet(), {'a', 'b'});
      });

      test('Update via upsert (no duplicate row)', () async {
        final source = newSource();
        await source.save(
          const CustomerModel(id: 'u1', fullName: 'Alice', phoneNumber: '111'),
        );
        await source.save(
          const CustomerModel(
            id: 'u1',
            fullName: 'Alice Updated',
            phoneNumber: '111',
            email: 'alice@new.com',
          ),
        );

        final read = await source.getById('u1');
        expect(read, isNotNull);
        expect(read!.fullName, 'Alice Updated');
        expect(read.email, 'alice@new.com');

        // The `unique + replace: true` index on `uuid` collapses
        // the re-save into an in-place row update, not a duplicate.
        final all = await source.getAll();
        expect(all.length, 1);
      });

      test('Delete removes the record', () async {
        final source = newSource();
        await source.save(
          const CustomerModel(id: 'd1', fullName: 'Doomed', phoneNumber: '1'),
        );
        expect(await source.getById('d1'), isNotNull);

        await source.delete('d1');
        expect(await source.getById('d1'), isNull);
      });

      test(
        'Persistence: write → close → reopen → read survives restart',
        () async {
          // Write through the freshly opened Isar.
          final sWrite = newSource();
          // The CustomerIsar schema preserves the deprecated
          // `balance` column on-disk for backwards compatibility
          // with pre-migration DBs. We do NOT touch the column here
          // — the mapper ignores it on both read and write paths.
          const input = CustomerModel(
            id: 'persist-1',
            fullName: 'Persisted',
            phoneNumber: '+1 000 000',
            tags: ['critical', 'persist-test'],
          );
          await sWrite.save(input);

          // Close — simulates process exit / app restart.
          await isar.close();

          // Re-open with the *same* (directory, name) pair. Isar
          // re-attaches to the existing file and the previously
          // inserted row is visible without any extra ritual.
          isar = await Isar.open(
            [CustomerIsarSchema],
            directory: dir.path,
            name: 'servicar_isar_test',
            inspector: false,
          );

          final sRead = newSource();
          final read = await sRead.getById('persist-1');
          expect(read, isNotNull);
          expect(read!.id, 'persist-1');
          expect(read.fullName, 'Persisted');
          expect(read.phoneNumber, '+1 000 000');
          expect(read.tags, ['critical', 'persist-test']);
        },
      );

      // ════════════════════════════════════════════════════════════════
      //  Edge cases on the DataSource
      // ════════════════════════════════════════════════════════════════

      test('getById returns null when the record is absent', () async {
        final source = newSource();
        expect(await source.getById('does-not-exist'), isNull);
      });

      test('getAll returns empty list on a fresh database', () async {
        final source = newSource();
        expect(await source.getAll(), isEmpty);
      });

      test('search returns empty list when there are no matches', () async {
        final source = newSource();
        await source.save(
          const CustomerModel(id: 'a', fullName: 'Alice', phoneNumber: '1'),
        );
        final hits = await source.search('zzz_no_match_xyz');
        expect(hits, isEmpty);
      });

      test('empty / whitespace search falls back to getAll', () async {
        final source = newSource();
        await source.save(
          const CustomerModel(id: 'a', fullName: 'Alice', phoneNumber: '1'),
        );
        await source.save(
          const CustomerModel(id: 'b', fullName: 'Bob', phoneNumber: '2'),
        );

        expect((await source.search('')).length, 2);
        expect((await source.search('   ')).length, 2);
      });

      // ════════════════════════════════════════════════════════════════
      //  Repository → domain Failure mapping (over real Isar)
      // ════════════════════════════════════════════════════════════════

      test('getCustomerById for absent id → CustomerNotFoundFailure', () async {
        final repo = CustomerRepositoryImpl(localDataSource: newSource());
        final fetched = await repo.getCustomerById('missing');
        expect(fetched.isLeft, isTrue);
        expect(
          (fetched as Left<CustomerFailure, CustomerEntity>).value,
          isA<CustomerNotFoundFailure>(),
        );
      });

      test(
        'createCustomer with empty fullName → CustomerValidationFailure',
        () async {
          final usecase = CreateCustomerUseCase(
            CustomerRepositoryImpl(localDataSource: newSource()),
          );
          final result = await usecase(
            const CustomerEntity(
              id: 'x',
              fullName: '',
              phoneNumber: '+98 912 000 0000',
            ),
          );
          expect(result.isLeft, isTrue);
          expect(
            (result as Left<CustomerFailure, CustomerEntity>).value,
            isA<CustomerValidationFailure>(),
          );
          expect(
            ((result).value as CustomerValidationFailure).field,
            'fullName',
          );
        },
      );

      test(
        'createCustomer on a closed Isar → CustomerStorageFailure',
        () async {
          final repo = CustomerRepositoryImpl(localDataSource: newSource());
          // Force the underlying Isar handle to throw on the next
          // write — the repository must absorb the thrown error
          // into `Left(CustomerStorageFailure(...))` rather than
          // surfacing it raw.
          await isar.close();

          final result = await repo.createCustomer(
            const CustomerEntity(id: 'x', fullName: 'Alice', phoneNumber: '1'),
          );
          expect(result.isLeft, isTrue);
          final failure =
              (result as Left<CustomerFailure, CustomerEntity>).value;
          expect(failure, isA<CustomerStorageFailure>());
          expect(
            (failure as CustomerStorageFailure).operation,
            'createCustomer',
          );
          expect(failure.message, isNotEmpty);
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
