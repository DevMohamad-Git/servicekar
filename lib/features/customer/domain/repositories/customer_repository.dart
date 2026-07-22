import 'package:servicar/core/utils/either.dart';

import '../entities/customer_entity.dart';
import '../failures/customer_failure.dart';

/// Contract every Customer repository implementation must satisfy.
///
/// Implementations live in `features/customer/data/repositories/`. Domain
/// code only ever sees this interface — never the implementation, which
/// lets us swap local/remote or mock the contract in tests without
/// touching business logic.
///
/// Methods return [Future] of [Either] so callers handle failure without
/// `try/catch`. A success of "nothing meaningful" is modelled with
/// [Unit] rather than `void`.
abstract class CustomerRepository {
  /// Persist a brand-new customer. Throws / returns [CustomerValidationFailure]
  /// when the supplied entity is invalid; [CustomerStorageFailure] on I/O.
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity customer,
  );

  /// Persist updates to an existing customer. Behaviour on a missing id is
  /// up to the implementation (typically returns [CustomerNotFoundFailure]).
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity customer,
  );

  /// Remove the customer with the given [id]. A successful delete yields
  /// [Unit.instance] on the success side.
  Future<Either<CustomerFailure, Unit>> deleteCustomer(String id);

  /// Look up a single customer by id. Returns [CustomerNotFoundFailure]
  /// on no match.
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(String id);

  /// Return every customer in local storage, ordered by creation time
  /// (most recent first) — TBD by implementation.
  Future<Either<CustomerFailure, List<CustomerEntity>>> getCustomers();

  /// Fuzzy/full-text search across [fullName], [phoneNumber], [email], [notes].
  Future<Either<CustomerFailure, List<CustomerEntity>>> searchCustomers(
    String query,
  );

  /// Read-only access to the customer's current balance. Convenient for the
  /// dashboard / details screen without hauling the entire record.
  Future<Either<CustomerFailure, double>> getCustomerBalance(String id);
}
