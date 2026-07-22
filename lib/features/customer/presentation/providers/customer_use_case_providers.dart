import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../domain/usecases/get_customer_balance_usecase.dart';
import '../../domain/usecases/get_customer_by_id_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/search_customers_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';

/// Single source of truth for wiring Customer use-cases. Every controller
/// imports this file once and never the data layer directly.
///
/// `customerRepositoryProvider` is the only data-to-presentation seam and
/// is documented in `ARCHITECTURE_RULES.md`.
final createCustomerUseCaseProvider = Provider<CreateCustomerUseCase>(
  (ref) => CreateCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>(
  (ref) => UpdateCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final deleteCustomerUseCaseProvider = Provider<DeleteCustomerUseCase>(
  (ref) => DeleteCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final getCustomerByIdUseCaseProvider = Provider<GetCustomerByIdUseCase>(
  (ref) => GetCustomerByIdUseCase(ref.watch(customerRepositoryProvider)),
);

final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>(
  (ref) => GetCustomersUseCase(ref.watch(customerRepositoryProvider)),
);

final searchCustomersUseCaseProvider = Provider<SearchCustomersUseCase>(
  (ref) => SearchCustomersUseCase(ref.watch(customerRepositoryProvider)),
);

final getCustomerBalanceUseCaseProvider = Provider<GetCustomerBalanceUseCase>(
  (ref) => GetCustomerBalanceUseCase(ref.watch(customerRepositoryProvider)),
);
