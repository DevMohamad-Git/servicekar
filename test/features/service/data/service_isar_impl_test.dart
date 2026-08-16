import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/mappers/service_mapper.dart';
import 'package:servicar/features/customer/data/models/customer_isar.dart';
import 'package:servicar/features/customer/data/models/service_isar.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/service/data/datasources/local/service_local_datasource.dart';
import 'package:servicar/features/service/data/datasources/local/service_local_datasource_impl.dart';
import 'package:servicar/features/service/data/repositories/service_repository_impl.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';
import 'package:servicar/features/service/domain/repositories/service_repository.dart';
import 'package:servicar/features/service/domain/usecases/params/register_service_params.dart';
import 'package:servicar/features/service/domain/usecases/register_service_usecase.dart';
import 'package:servicar/features/service/domain/value_models/service_operation_outcome.dart';

/// Service Persistence — real Isar (physical-storage round-trip).
///
/// ─── Why we seed `CustomerIsar` in this test ──────────────────────────
/// The Service collection's `customerUuid` is a plain `String` FK
/// without `IsarLink`. The service datasource does not verify FK
/// sanity; that gate lives in `RegisterServiceUseCase` (separate test
/// file). For the *physical persistence* assertion here we only care
/// that round-tripping Service rows survives close-and-reopen, so we
/// preload a single customer row and reference its uuid from every
/// Service fixture.
///
/// ─── Skip policy ─────────────────────────────────────────────────────
/// Same as `customer_isar_impl_test.dart`: on Windows the project
/// only ships the Android `.so` binary, so `Isar.open` cannot load
/// `libisar.dll`. The suite skips on Windows and runs on Linux/macOS CI.
void main() {
  group(
    'Service Persistence (real Isar — physical storage)',
    () {
      late Directory dir;
      late Isar isar;

      setUp(() async {
        dir = await Directory.systemTemp.createTemp(
          'servicar_service_isar_test_',
        );
        // Both collections are registered so the Service FK to
        // Customer is at least syntactically usable in the test
        // (Service only ever reads `customerUuid` as a String —
        // cross-collection integrity is enforced at the UseCase
        // boundary, not the Isar layer).
        isar = await Isar.open(
          [CustomerIsarSchema, ServiceIsarSchema],
          directory: dir.path,
          name: 'servicar_service_isar_test',
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

      /// Seeds a single customer row so Reference-by-uuid works.
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

      ServiceLocalDataSource newSource() => ServiceLocalDataSourceImpl(isar);
      ServiceRepository newRepo() =>
          ServiceRepositoryImpl(localDataSource: newSource());

      // ════════════════════════════════════════════════════════════════
      //  DataSource round-trip
      // ════════════════════════════════════════════════════════════════

      test('Create & Read round-trip preserves all Service fields', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        const input = ServiceEntity(
          id: 'srv-1',
          customerUuid: 'cust-1',
          title: 'Oil change',
          description: '5W-30 synthetic',
          status: ServiceStatus.inProgress,
          price: 120.0,
          tags: ['vip', 'priority'],
          startedAt: null,
        );
        // We pass through the entity-model-isar chain via the
        // mapper. The mapper is exercised at the Repository layer
        // test file (`service_repository_impl_test.dart`); here we
        // focus on the Isar round-trip.
        await source.save(input.toModel());

        final read = await source.getById('srv-1');
        expect(read, isNotNull);
        expect(read!.id, 'srv-1');
        expect(read.customerUuid, 'cust-1');
        expect(read.title, 'Oil change');
        expect(read.description, '5W-30 synthetic');
        expect(read.status, 'inProgress');
        expect(read.price, 120.0);
        expect(read.tags, ['vip', 'priority']);
        expect(read.startedAt, isNull);
      });

      test('getByCustomer filters by FK', () async {
        await seedCustomer('cust-1');
        await seedCustomer('cust-2');
        final source = newSource();
        await source.save(
          const ServiceEntity(
            id: 'a',
            customerUuid: 'cust-1',
            title: 'A',
          ).toModel(),
        );
        await source.save(
          const ServiceEntity(
            id: 'b',
            customerUuid: 'cust-2',
            title: 'B',
          ).toModel(),
        );
        await source.save(
          const ServiceEntity(
            id: 'c',
            customerUuid: 'cust-1',
            title: 'C',
          ).toModel(),
        );

        final list = await source.getByCustomer('cust-1');
        expect(list.map((m) => m.id).toSet(), {'a', 'c'});

        final listB = await source.getByCustomer('cust-2');
        expect(listB.map((m) => m.id), ['b']);
      });

      test('Update via upsert (no duplicate row)', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          const ServiceEntity(
            id: 'u1',
            customerUuid: 'cust-1',
            title: 'Old',
          ).toModel(),
        );
        await source.save(
          const ServiceEntity(
            id: 'u1',
            customerUuid: 'cust-1',
            title: 'New',
            price: 50.0,
          ).toModel(),
        );

        final read = await source.getById('u1');
        expect(read!.title, 'New');
        expect(read.price, 50.0);

        // `replace: true` collapses to an in-place row update.
        final all = await source.getByCustomer('cust-1');
        expect(all, hasLength(1));
      });

      test('Delete removes the record', () async {
        await seedCustomer('cust-1');
        final source = newSource();
        await source.save(
          const ServiceEntity(
            id: 'd',
            customerUuid: 'cust-1',
            title: 'D',
          ).toModel(),
        );
        expect(await source.getById('d'), isNotNull);

        await source.delete('d');
        expect(await source.getById('d'), isNull);
      });

      test('getById returns null when the record is absent', () async {
        final source = newSource();
        expect(await source.getById('does-not-exist'), isNull);
      });

      test('getByCustomer returns empty list when no matches', () async {
        final source = newSource();
        expect(await source.getByCustomer('nobody'), isEmpty);
      });

      test('countAll counts every persisted row', () async {
        final source = newSource();
        expect(await source.countAll(), 0);

        await seedCustomer('cust-1');
        await seedCustomer('cust-2');
        await source.save(
          const ServiceEntity(
            id: 'a',
            customerUuid: 'cust-1',
            title: 'A',
          ).toModel(),
        );
        await source.save(
          const ServiceEntity(
            id: 'b',
            customerUuid: 'cust-2',
            title: 'B',
          ).toModel(),
        );
        expect(await source.countAll(), 2);
      });

      // ════════════════════════════════════════════════════════════════
      //  Persistence: write → close → reopen → read
      // ════════════════════════════════════════════════════════════════

      test(
        'Persistence: write → close → reopen → read survives restart',
        () async {
          await seedCustomer('cust-1');
          final sWrite = newSource();
          const input = ServiceEntity(
            id: 'persist-1',
            customerUuid: 'cust-1',
            title: 'Persisted job',
            description: 'survives restart',
            status: ServiceStatus.completed,
            price: 75.0,
            tags: ['critical', 'persist-test'],
          );
          await sWrite.save(input.toModel());

          // Close — simulates process exit / app restart.
          await isar.close();

          // Re-open with the *same* (directory, name) pair. Isar
          // re-attaches and the previously inserted row is visible
          // without any extra ritual. Customer is re-seeded because
          // the use-case-level FK check does NOT run in this test
          // — the Service datasource happily holds a Service row
          // whose customerUuid is not backed by a live Customer row
          // (FK enforcement is a domain-layer concern, see
          // `register_service_usecase_test.dart`).
          isar = await Isar.open(
            [CustomerIsarSchema, ServiceIsarSchema],
            directory: dir.path,
            name: 'servicar_service_isar_test',
            inspector: false,
          );

          final sRead = newSource();
          final read = await sRead.getById('persist-1');
          expect(read, isNotNull);
          expect(read!.id, 'persist-1');
          expect(read.title, 'Persisted job');
          expect(read.customerUuid, 'cust-1');
          expect(read.status, 'completed');
          expect(read.price, 75.0);
          expect(read.tags, ['critical', 'persist-test']);
        },
      );

      // ════════════════════════════════════════════════════════════════
      //  Repository → domain Failure mapping (over real Isar)
      // ════════════════════════════════════════════════════════════════

      test('getServiceById for absent id → ServiceNotFoundFailure', () async {
        final repo = newRepo();
        final fetched = await repo.getServiceById('missing');
        expect(fetched.isLeft, isTrue);
        expect(
          (fetched as Left<ServiceFailure, ServiceEntity>).value,
          isA<ServiceNotFoundFailure>(),
        );
      });

      test(
        'RegisterServiceUseCase on a closed Isar → ServiceStorageFailure',
        () async {
          await seedCustomer('cust-1');
          // We bypass the use case's customer-existence check by
          // supplying a stub [CustomerRepository] that always
          // succeeds. Then we force-close the underlying Isar handle
          // used by the service datasource — `_localDataSource.save`
          // cannot open the write txn on a closed handle and throws,
          // which the repository will wrap as `ServiceStorageFailure`.
          final repo = newRepo();
          await isar.close();

          final useCase = RegisterServiceUseCase(
            serviceRepository: repo,
            customerRepository: _SucceedingCustomerRepo(),
          );

          final result = await useCase(
            const RegisterServiceParams(
              id: 'srv-x',
              customerUuid: 'cust-1',
              title: 'T',
            ),
          );
          expect(result.isLeft, isTrue);
          final failure =
              (result as Left<ServiceFailure, ServiceOperationOutcome>).value;
          expect(failure, isA<ServiceStorageFailure>());
          expect((failure as ServiceStorageFailure).operation, 'createService');
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

/// Stand-in [CustomerRepository] that always returns success for
/// `getCustomerById`. Used to skip the FK-validation gate when the
/// test wants to exercise the storage-failure branch on a closed Isar.
class _SucceedingCustomerRepo implements CustomerRepository {
  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async => Right(CustomerEntity(id: id, fullName: 'Stub', phoneNumber: '0'));

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
