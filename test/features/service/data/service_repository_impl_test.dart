import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/models/service_model.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/service/data/datasources/local/service_local_datasource.dart';
import 'package:servicar/features/service/data/repositories/service_repository_impl.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';

/// In-memory fake of [ServiceLocalDataSource].
///
/// Mirrors the customer test's `_FakeCustomerLocalDataSource` so the
/// repository-layer tests stay independent of the Isar platform
/// channel. The repository's `_readBack` round-trip depends on
/// `getById`, so the fake is faithful about it.
class InMemoryServiceLocalDataSource implements ServiceLocalDataSource {
  InMemoryServiceLocalDataSource([Map<String, ServiceModel>? seed])
    : _store = {...?seed};

  final Map<String, ServiceModel> _store;

  @override
  Future<ServiceModel?> getById(String id) async => _store[id];

  @override
  Future<List<ServiceModel>> getByCustomer(String customerUuid) async => _store
      .values
      .where((m) => m.customerUuid == customerUuid)
      .toList(growable: false);

  @override
  Future<void> save(ServiceModel model) async {
    _store[model.id] = model;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}

void main() {
  group('ServiceRepositoryImpl', () {
    late ServiceRepositoryImpl repo;
    late InMemoryServiceLocalDataSource fake;

    setUp(() {
      fake = InMemoryServiceLocalDataSource();
      repo = ServiceRepositoryImpl(localDataSource: fake);
    });

    test('createService round-trips through getById', () async {
      const input = ServiceEntity(
        id: 'srv-1',
        customerUuid: 'cust-1',
        title: 'Oil change',
        price: 100.0,
      );

      final saveResult = await repo.createService(input);
      expect(saveResult.isRight, isTrue);
      expect(
        (saveResult as Right<ServiceFailure, ServiceEntity>).value.id,
        'srv-1',
      );

      final read = await repo.getServiceById('srv-1');
      expect(read.isRight, isTrue);
      final entity = (read as Right<ServiceFailure, ServiceEntity>).value;
      expect(entity.title, 'Oil change');
      expect(entity.customerUuid, 'cust-1');
      expect(entity.price, 100.0);
    });

    test(
      'updateService overwrites the row (replace: true behaviour)',
      () async {
        await fake.save(
          const ServiceModel(
            id: 'srv-1',
            customerUuid: 'cust-1',
            title: 'Old',
            price: 10.0,
          ),
        );
        final res = await repo.updateService(
          const ServiceEntity(
            id: 'srv-1',
            customerUuid: 'cust-1',
            title: 'New',
            price: 20.0,
          ),
        );
        expect(res.isRight, isTrue);
        final read = await repo.getServiceById('srv-1');
        expect(
          (read as Right<ServiceFailure, ServiceEntity>).value.title,
          'New',
        );
        expect(
          (read as Right<ServiceFailure, ServiceEntity>).value.price,
          20.0,
        );
      },
    );

    test('getServiceById returns ServiceNotFoundFailure on miss', () async {
      final fetched = await repo.getServiceById('does-not-exist');
      expect(fetched.isLeft, isTrue);
      expect(
        (fetched as Left<ServiceFailure, ServiceEntity>).value,
        isA<ServiceNotFoundFailure>(),
      );
    });

    test('getServicesByCustomer filters by FK', () async {
      await fake.save(
        const ServiceModel(
          id: 'a',
          customerUuid: 'cust-1',
          title: 'A',
          price: 1.0,
        ),
      );
      await fake.save(
        const ServiceModel(
          id: 'b',
          customerUuid: 'cust-2',
          title: 'B',
          price: 1.0,
        ),
      );
      await fake.save(
        const ServiceModel(
          id: 'c',
          customerUuid: 'cust-1',
          title: 'C',
          price: 1.0,
        ),
      );

      final list = await repo.getServicesByCustomer('cust-1');
      expect(list.isRight, isTrue);
      final services =
          (list as Right<ServiceFailure, List<ServiceEntity>>).value;
      expect(services, hasLength(2));
      expect(services.map((s) => s.id).toSet(), {'a', 'c'});
    });

    test('deleteService returns Right(Unit) and removes the row', () async {
      await fake.save(
        const ServiceModel(
          id: 'd',
          customerUuid: 'cust-1',
          title: 'D',
          price: 1.0,
        ),
      );
      final result = await repo.deleteService('d');
      expect(result, const Right<ServiceFailure, Unit>(Unit.instance));
      expect(await fake.getById('d'), isNull);
    });

    test(
      'mapper is stable: tags, nullable, status wire value preserved',
      () async {
        await fake.save(
          const ServiceModel(
            id: 's',
            customerUuid: 'cust-1',
            title: 'T',
            description: 'D',
            status: 'inProgress',
            price: 12.5,
            tags: ['vip', 'warranty'],
            startedAt: null,
          ),
        );
        final fetched = await repo.getServiceById('s');
        expect(fetched.isRight, isTrue);
        final e = (fetched as Right<ServiceFailure, ServiceEntity>).value;
        expect(e.status, ServiceStatus.inProgress);
        expect(e.title, 'T');
        expect(e.description, 'D');
        expect(e.price, 12.5);
        expect(e.tags, ['vip', 'warranty']);
        expect(e.startedAt, isNull);
      },
    );

    test(
      'source-layer exception is wrapped as ServiceStorageFailure',
      () async {
        final broken = _BrokenServiceLocalDataSource();
        final r = ServiceRepositoryImpl(localDataSource: broken);

        const input = ServiceEntity(
          id: 'srv-1',
          customerUuid: 'cust-1',
          title: 'T',
        );
        final result = await r.createService(input);
        expect(result.isLeft, isTrue);
        final failure = (result as Left<ServiceFailure, ServiceEntity>).value;
        expect(failure, isA<ServiceStorageFailure>());
        expect((failure as ServiceStorageFailure).operation, 'createService');
      },
    );
  });
}

/// Always-throws datasource. Used to verify the repository's
/// try/catch contract without involving the Isar platform channel.
class _BrokenServiceLocalDataSource implements ServiceLocalDataSource {
  @override
  Future<void> save(ServiceModel model) async {
    throw StateError('boom');
  }

  @override
  Future<ServiceModel?> getById(String id) async => null;

  @override
  Future<List<ServiceModel>> getByCustomer(String uuid) async =>
      const <ServiceModel>[];

  @override
  Future<void> delete(String id) async {}
}
