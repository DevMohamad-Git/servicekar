import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/core/utils/either.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/failures/customer_failure.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/local/customer_local_datasource.dart';
import '../datasources/local/customer_local_datasource_impl.dart';
import '../mappers/customer_mapper.dart';

/// Offline-first implementation of [CustomerRepository]. Talks to the
/// local Isar-backed datasource only; remote sync will be layered on top
/// later without changing the contract above.
///
/// Methods return an `Either<Failure, T>` and short-circuit with a
/// [CustomerStorageFailure] when the underlying datasource throws.
class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl({
    required CustomerLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final CustomerLocalDataSource _localDataSource;

  @override
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity customer,
  ) async {
    try {
      final model = customer.toModel();
      await _localDataSource.save(model);
      return Right(await _readBack(model.id) ?? customer);
    } catch (e) {
      return Left(
        CustomerStorageFailure(
          operation: 'createCustomer',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity customer,
  ) async {
    try {
      await _localDataSource.save(customer.toModel());
      return Right(await _readBack(customer.id) ?? customer);
    } catch (e) {
      return Left(
        CustomerStorageFailure(
          operation: 'updateCustomer',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<CustomerFailure, Unit>> deleteCustomer(String id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(Unit.instance);
    } catch (e) {
      return Left(
        CustomerStorageFailure(
          operation: 'deleteCustomer',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return Left(CustomerNotFoundFailure(id: id));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        CustomerStorageFailure(
          operation: 'getCustomerById',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> getCustomers() async {
    try {
      final models = await _localDataSource.getAll();
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } catch (e) {
      return Left(
        CustomerStorageFailure(
          operation: 'getCustomers',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> searchCustomers(
    String query,
  ) async {
    try {
      final models = await _localDataSource.search(query);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } catch (e) {
      return Left(
        CustomerStorageFailure(
          operation: 'searchCustomers',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<CustomerFailure, double>> getCustomerBalance(String id) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return Left(CustomerNotFoundFailure(id: id));
      }
      return Right(model.balance);
    } catch (e) {
      return Left(
        CustomerStorageFailure(
          operation: 'getCustomerBalance',
          message: e.toString(),
        ),
      );
    }
  }

  Future<CustomerEntity?> _readBack(String id) async {
    final model = await _localDataSource.getById(id);
    return model?.toEntity();
  }
}

/// Riverpod binding (manual — no `@riverpod` codegen). The repository is
/// a singleton bound to the Isar database; recreating on every read is
/// wasteful so we expose it as a regular `Provider`.
final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepositoryImpl(
    localDataSource: ref.watch(customerLocalDataSourceProvider),
  ),
);
