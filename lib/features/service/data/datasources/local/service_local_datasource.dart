import 'package:servicar/features/customer/data/models/service_model.dart';

/// Abstraction over local storage for services.
///
/// Implementations live in `data/datasources/local/service/`. Keeping the
/// interface here makes it trivial to swap Isar for Hive / sqflite / an
/// in-memory fake during testing without touching the repository.
///
/// Symmetric with [CustomerLocalDataSource] — see that file for the
/// wider rationale on the local-only abstraction. Reads are
/// per-customer — `getByCustomer(uuid)` — so the linked invoice/payment
/// flows can stack additional one-to-many queries on the same pattern.
abstract class ServiceLocalDataSource {
  /// Return the service with [id], or `null` if absent.
  Future<ServiceModel?> getById(String id);

  /// Return every service attached to [customerUuid], ordered by
  /// [ServiceModel.startedAt] descending (nulls last to keep the
  /// recently-started jobs at the top of the history list).
  Future<List<ServiceModel>> getByCustomer(String customerUuid);

  /// Insert or update [model]. The Isar `@Index(unique: true, replace: true)`
  /// on `uuid` collapses re-saves into in-place updates.
  Future<void> save(ServiceModel model);

  /// Remove the record with [id]. No-op if it does not exist.
  Future<void> delete(String id);
}
