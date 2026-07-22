import '../../models/customer_model.dart';

/// Abstraction over local storage for customers.
///
/// Implementations live in `datasources/local/`. Keeping the interface
/// here makes it trivial to swap Isar for Hive / sqflite / an in-memory
/// fake during testing without touching the repository.
abstract class CustomerLocalDataSource {
  /// Return the customer with [id], or `null` if absent.
  Future<CustomerModel?> getById(String id);

  /// Return every persisted customer.
  Future<List<CustomerModel>> getAll();

  /// Insert or update [model].
  Future<void> save(CustomerModel model);

  /// Remove the record with [id]. No-op if it does not exist.
  Future<void> delete(String id);

  /// Free-text search across the customer's indexed fields.
  Future<List<CustomerModel>> search(String query);
}
