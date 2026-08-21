import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/datasources/local/customer_local_datasource.dart';
import 'package:servicar/features/customer/data/models/customer_model.dart';
import 'package:servicar/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';

/// In-memory `CustomerLocalDataSource`.
///
/// The Isar infrastructure is wired but `CustomerLocalDataSourceImpl`
/// is intentionally a stub that throws `UnimplementedError` on every
/// call until the first `@collection` ships. Repository-level tests
/// substitute this fake so the data layer exercises its real
/// contract without depending on the platform channel.
class InMemoryCustomerLocalDataSource implements CustomerLocalDataSource {
  InMemoryCustomerLocalDataSource([Map<String, CustomerModel>? seed])
    : _store = {...?seed};

  final Map<String, CustomerModel> _store;

  @override
  Future<CustomerModel?> getById(String id) async => _store[id];

  @override
  Future<List<CustomerModel>> getAll() async => _store.values.toList();

  @override
  Future<void> save(CustomerModel model) async {
    _store[model.id] = model;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<CustomerModel>> search(String query) async {
    final q = query.toLowerCase();
    return _store.values
        .where(
          (m) =>
              m.fullName.toLowerCase().contains(q) ||
              m.phoneNumber.toLowerCase().contains(q),
        )
        .toList();
  }
}

/// Sample-repository test: validates mapper round-trip, fails closed
/// on not-found, and proxies list / delete / search through the
/// `Either` failure-or-success contract.
void main() {
  group('CustomerRepositoryImpl', () {
    late CustomerRepositoryImpl repo;
    late InMemoryCustomerLocalDataSource fake;

    setUp(() {
      fake = InMemoryCustomerLocalDataSource();
      repo = CustomerRepositoryImpl(localDataSource: fake);
    });

    test('createCustomer round-trips through getById', () async {
      const input = CustomerEntity(
        id: 'c1',
        fullName: 'Alice',
        phoneNumber: '+98 912 000 0000',
        profileImagePath: 'customers/c1/avatar.jpg',
      );

      final saveResult = await repo.createCustomer(input);
      expect(saveResult.isRight, isTrue);
      expect(
        (saveResult as Right<CustomerFailure, CustomerEntity>).value.id,
        'c1',
      );

      final read = await repo.getCustomerById('c1');
      expect(read.isRight, isTrue);
      final entity = (read as Right<CustomerFailure, CustomerEntity>).value;
      expect(entity.fullName, 'Alice');
      expect(entity.phoneNumber, '+98 912 000 0000');
      expect(entity.profileImagePath, 'customers/c1/avatar.jpg');
    });

    test('getCustomerById returns CustomerNotFoundFailure on miss', () async {
      final fetched = await repo.getCustomerById('does-not-exist');
      expect(fetched.isLeft, isTrue);
      expect(
        (fetched as Left<CustomerFailure, CustomerEntity>).value,
        isA<CustomerNotFoundFailure>(),
      );
    });

    test('getCustomers returns every persisted entity', () async {
      await fake.save(CustomerModel(id: 'a', fullName: 'A', phoneNumber: '1'));
      await fake.save(CustomerModel(id: 'b', fullName: 'B', phoneNumber: '2'));
      final list = await repo.getCustomers();
      expect(list.isRight, isTrue);
      expect(
        (list as Right<CustomerFailure, List<CustomerEntity>>).value,
        hasLength(2),
      );
    });

    test('deleteCustomer returns Right(Unit) on success', () async {
      await fake.save(CustomerModel(id: 'a', fullName: 'A', phoneNumber: '1'));
      final result = await repo.deleteCustomer('a');
      expect(result, const Right<CustomerFailure, Unit>(Unit.instance));
      expect(await fake.getById('a'), isNull);
    });

    test('searchCustomers proxies through to the datasource', () async {
      await fake.save(
        CustomerModel(id: 'a', fullName: 'Alice', phoneNumber: '1'),
      );
      await fake.save(
        CustomerModel(id: 'b', fullName: 'Bob', phoneNumber: '2'),
      );
      final hits = await repo.searchCustomers('ali');
      expect(hits.isRight, isTrue);
      final list = (hits as Right<CustomerFailure, List<CustomerEntity>>).value;
      expect(list, hasLength(1));
      expect(list.first.fullName, 'Alice');
    });
    test('mapper is stable: tags, nullable fields preserved', () async {
      const model = CustomerModel(
        id: 'c1',
        fullName: 'Alice',
        phoneNumber: '+98 912 000 0000',
        email: 'a@example.com',
        address: 'Tehran',
        profileImagePath: 'customers/c1/avatar.png',
        tags: ['vip', 'cash'],
      );
      await fake.save(model);

      final fetched = await repo.getCustomerById('c1');
      expect(fetched.isRight, isTrue);
      final e = (fetched as Right<CustomerFailure, CustomerEntity>).value;
      expect(e.email, 'a@example.com');
      expect(e.address, 'Tehran');
      expect(e.profileImagePath, 'customers/c1/avatar.png');
      expect(e.tags, ['vip', 'cash']);
    });

    test(
      'source-layer exception is wrapped as CustomerStorageFailure',
      () async {
        // Forge a faulty datasource: save throws. The repository must
        // contain the throw inside Left(CustomerStorageFailure) so
        // callers never see raw exceptions.
        final broken = _BrokenCustomerLocalDataSource();
        final r = CustomerRepositoryImpl(localDataSource: broken);

        const input = CustomerEntity(id: 'c1', fullName: 'A', phoneNumber: '1');
        final result = await r.createCustomer(input);
        expect(result.isLeft, isTrue);
        final failure = (result as Left<CustomerFailure, CustomerEntity>).value;
        expect(failure, isA<CustomerStorageFailure>());
        expect((failure as CustomerStorageFailure).operation, 'createCustomer');
      },
    );
  });
}

/// Datasource that always throws on `save`. Used to verify the
/// repository's try/catch contract without involving the Isar
/// platform channel.
class _BrokenCustomerLocalDataSource implements CustomerLocalDataSource {
  @override
  Future<void> save(CustomerModel model) async {
    throw StateError('boom');
  }

  @override
  Future<CustomerModel?> getById(String id) async => null;

  @override
  Future<List<CustomerModel>> getAll() async => const [];

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<CustomerModel>> search(String query) async => const [];
}
