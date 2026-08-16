import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
import 'package:servicar/features/invoice/data/datasources/local/invoice_local_datasource.dart';
import 'package:servicar/features/invoice/data/datasources/local/invoice_local_datasource_impl.dart';
import 'package:servicar/features/invoice/data/repositories/invoice_repository_impl.dart';
import 'package:servicar/features/invoice/domain/failures/invoice_failure.dart';
import 'package:servicar/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:servicar/features/invoice/domain/usecases/delete_invoice_usecase.dart';
import 'package:servicar/features/invoice/domain/usecases/get_customer_invoices_usecase.dart';
import 'package:servicar/features/invoice/domain/usecases/get_invoice_by_id_usecase.dart';
import 'package:servicar/features/invoice/domain/usecases/get_invoice_count_usecase.dart';
import 'package:servicar/features/invoice/domain/usecases/params/register_invoice_params.dart';
import 'package:servicar/features/invoice/domain/usecases/params/update_invoice_params.dart';
import 'package:servicar/features/invoice/domain/usecases/register_invoice_usecase.dart';
import 'package:servicar/features/invoice/domain/usecases/update_invoice_usecase.dart';
import 'package:servicar/features/invoice/domain/value_models/invoice_operation_outcome.dart';

import '../global_providers.dart';
import 'balance_providers.dart';
import 'customer_providers.dart';

/// Invoice feature — Riverpod bindings
/// ===================================
///
/// Mirrors the structure of `customer_providers.dart` /
/// `service_providers.dart` / `payment_providers.dart` exactly:
///   * DataSource provider sits at the top of the data seam.
///   * Repository provider wires the datasource.
///   * Use case providers wire the repository (plus, for
///     [RegisterInvoiceUseCase], the customer repository as the
///     validation gate).
///   * Controllers provide the read / intent surface UI consumes.
///
/// ─── Layer ownership ───────────────────────────────────────────────
/// This file is the SOLE owner of every Riverpod provider for the
/// Invoice feature. The data layer's
/// `invoice_local_datasource_impl.dart` contains only datasource
/// logic and Isar glue — no Riverpod binding.
final invoiceLocalDataSourceProvider = Provider<InvoiceLocalDataSource>(
  (ref) => InvoiceLocalDataSourceImpl(ref.watch(isarInstanceProvider)),
);

final invoiceRepositoryProvider = Provider<InvoiceRepository>(
  (ref) => InvoiceRepositoryImpl(
    localDataSource: ref.watch(invoiceLocalDataSourceProvider),
  ),
);

// ─── Use cases ───────────────────────────────────────────────────────
final registerInvoiceUseCaseProvider = Provider<RegisterInvoiceUseCase>(
  (ref) => RegisterInvoiceUseCase(
    invoiceRepository: ref.watch(invoiceRepositoryProvider),
    customerRepository: ref.watch(customerRepositoryProvider),
  ),
);

final updateInvoiceUseCaseProvider = Provider<UpdateInvoiceUseCase>(
  (ref) => UpdateInvoiceUseCase(ref.watch(invoiceRepositoryProvider)),
);

final deleteInvoiceUseCaseProvider = Provider<DeleteInvoiceUseCase>(
  (ref) => DeleteInvoiceUseCase(ref.watch(invoiceRepositoryProvider)),
);

final getInvoiceByIdUseCaseProvider = Provider<GetInvoiceByIdUseCase>(
  (ref) => GetInvoiceByIdUseCase(ref.watch(invoiceRepositoryProvider)),
);

final getCustomerInvoicesUseCaseProvider = Provider<GetCustomerInvoicesUseCase>(
  (ref) => GetCustomerInvoicesUseCase(ref.watch(invoiceRepositoryProvider)),
);

final getInvoiceCountUseCaseProvider = Provider<GetInvoiceCountUseCase>(
  (ref) => GetInvoiceCountUseCase(ref.watch(invoiceRepositoryProvider)),
);

// ─── Controllers ────────────────────────────────────────────────────

/// Family-keyed read state for a customer's invoice history. UI
/// watches `ref.watch(customerInvoicesControllerProvider(customerUuid))`.
///
/// Always returns a (possibly empty) list on success; an
/// [InvoiceFailure] is thrown so the page can render an
/// [AsyncError] carrying the original failure.
class CustomerInvoicesController extends AsyncNotifier<List<InvoiceEntity>> {
  CustomerInvoicesController(this.customerUuid);

  final String customerUuid;

  @override
  Future<List<InvoiceEntity>> build() async {
    final useCase = ref.watch(getCustomerInvoicesUseCaseProvider);
    final result = await useCase(customerUuid);
    return result.fold((failure) => throw failure, (invoices) => invoices);
  }

  /// Pull-to-refresh / retry hook. Pure refetch — no mutation.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final customerInvoicesControllerProvider =
    AsyncNotifierProvider.family<
      CustomerInvoicesController,
      List<InvoiceEntity>,
      String
    >(CustomerInvoicesController.new);

/// Family-keyed read state for a single [InvoiceEntity]. UI reads
/// `invoiceControllerProvider(id)`.
class InvoiceController extends AsyncNotifier<InvoiceEntity> {
  InvoiceController(this.invoiceId);

  final String invoiceId;

  @override
  Future<InvoiceEntity> build() async {
    final useCase = ref.watch(getInvoiceByIdUseCaseProvider);
    final result = await useCase(invoiceId);
    return result.fold((failure) => throw failure, (invoice) => invoice);
  }
}

final invoiceControllerProvider =
    AsyncNotifierProvider.family<InvoiceController, InvoiceEntity, String>(
      InvoiceController.new,
    );

/// Write-intent controller for [RegisterInvoiceUseCase]. Returns
/// `null` on success or a failure message string on failure. UI
/// takes one branch on this and does not have to unpack `Either`
/// itself.
class CreateInvoiceController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(RegisterInvoiceParams params) async {
    final useCase = ref.read(registerInvoiceUseCaseProvider);
    final result = await useCase(params);
    // Use `rightOrNull` so we avoid `as dynamic` and stay type-safe.
    final outcome = result.rightOrNull;
    if (outcome != null) {
      // Refresh sibling controllers so the UI sees the new row.
      ref.invalidate(customerInvoicesControllerProvider(params.customerUuid));
      // Also refresh any per-id detail view, if the consumer is
      // already pointing at this id.
      ref.invalidate(invoiceControllerProvider(outcome.invoice.id));
      // Balance is derived from this customer's invoice/payment
      // totals; the mutation just changed the invoice side.
      ref.invalidate(customerBalanceControllerProvider(params.customerUuid));
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final createInvoiceControllerProvider =
    NotifierProvider<CreateInvoiceController, void>(
      CreateInvoiceController.new,
    );

/// Write-intent controller for [UpdateInvoiceUseCase].
class UpdateInvoiceController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(UpdateInvoiceParams params) async {
    final useCase = ref.read(updateInvoiceUseCaseProvider);
    final result = await useCase(params);
    final outcome = result.rightOrNull;
    if (outcome != null) {
      ref.invalidate(customerInvoicesControllerProvider(params.customerUuid));
      ref.invalidate(invoiceControllerProvider(outcome.invoice.id));
      ref.invalidate(customerBalanceControllerProvider(params.customerUuid));
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final updateInvoiceControllerProvider =
    NotifierProvider<UpdateInvoiceController, void>(
      UpdateInvoiceController.new,
    );

/// Write-intent controller for [DeleteInvoiceUseCase].
class DeleteInvoiceController extends Notifier<void> {
  @override
  void build() {}

  /// `customerUuid` is required alongside `id` so the controller
  /// can invalidate the per-customer invoices family after a
  /// successful delete.
  Future<String?> submit({
    required String id,
    required String customerUuid,
  }) async {
    final useCase = ref.read(deleteInvoiceUseCaseProvider);
    final result = await useCase(id);
    if (result.isRight) {
      ref.invalidate(customerInvoicesControllerProvider(customerUuid));
      ref.invalidate(invoiceControllerProvider(id));
      ref.invalidate(customerBalanceControllerProvider(customerUuid));
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final deleteInvoiceControllerProvider =
    NotifierProvider<DeleteInvoiceController, void>(
      DeleteInvoiceController.new,
    );
