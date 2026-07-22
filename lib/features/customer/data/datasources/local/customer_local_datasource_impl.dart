import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/customer_model.dart';
import 'customer_local_datasource.dart';

/// Isar-backed implementation of [CustomerLocalDataSource].
///
/// TODO: Inject an `Isar` collection wrapper, e.g.:
///
/// ```dart
/// class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
///   const CustomerLocalDataSourceImpl(this._isar);
///   final Isar _isar;
/// }
/// ```
///
/// Until Isar is wired up each method throws [UnimplementedError] so
/// the dependency chain stays compilable.
class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  const CustomerLocalDataSourceImpl();

  @override
  Future<CustomerModel?> getById(String id) async {
    // TODO: replace with `_isar.customers.get(...)`.
    throw UnimplementedError(
      'CustomerLocalDataSourceImpl.getById not implemented yet.',
    );
  }

  @override
  Future<List<CustomerModel>> getAll() async {
    // TODO: replace with `_isar.customers.where().findAll()`.
    throw UnimplementedError(
      'CustomerLocalDataSourceImpl.getAll not implemented yet.',
    );
  }

  @override
  Future<void> save(CustomerModel model) async {
    // TODO: replace with `_isar.writeTxn(() => _isar.customers.put(...))`.
    throw UnimplementedError(
      'CustomerLocalDataSourceImpl.save not implemented yet.',
    );
  }

  @override
  Future<void> delete(String id) async {
    // TODO: replace with `_isar.writeTxn(() => _isar.customers.delete(...))`.
    throw UnimplementedError(
      'CustomerLocalDataSourceImpl.delete not implemented yet.',
    );
  }

  @override
  Future<List<CustomerModel>> search(String query) async {
    // TODO: full-text / prefix search once Isar indexes are added.
    throw UnimplementedError(
      'CustomerLocalDataSourceImpl.search not implemented yet.',
    );
  }
}

/// Riverpod binding (manual — no `@riverpod` codegen). Default to the
/// no-op shipping implementation; swap it out in `main` once
/// `isarInstance` exists.
final customerLocalDataSourceProvider = Provider<CustomerLocalDataSource>(
  (ref) => const CustomerLocalDataSourceImpl(),
);
