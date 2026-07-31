import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/features/customer/domain/entities/payment_entity.dart';
import 'package:servicar/features/invoice/domain/repositories/invoice_repository.dart';

import '../../../features/payment/data/datasources/local/payment_local_datasource.dart';
import '../../../features/payment/data/datasources/local/payment_local_datasource_impl.dart';
import '../../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../../features/payment/domain/repositories/payment_repository.dart';
import '../../../features/payment/domain/usecases/delete_payment_usecase.dart';
import '../../../features/payment/domain/usecases/get_invoice_payments_usecase.dart';
import '../../../features/payment/domain/usecases/get_payment_by_id_usecase.dart';
import '../../../features/payment/domain/usecases/params/register_payment_params.dart';
import '../../../features/payment/domain/usecases/params/update_payment_params.dart';
import '../../../features/payment/domain/usecases/register_payment_usecase.dart';
import '../../../features/payment/domain/usecases/update_payment_usecase.dart';
import '../global_providers.dart';
import 'balance_providers.dart';
import 'customer_providers.dart';
import 'invoice_providers.dart';

/// Payment feature — Riverpod bindings
/// ===================================
///
/// Mirrors the structure of `customer_providers.dart` /
/// `service_providers.dart` exactly:
///   * DataSource provider sits at the top of the data seam.
///   * Repository provider wires the datasource.
///   * Use case providers wire the repository (plus, for
///     [RegisterPaymentUseCase], the customer + invoice
///     repositories as the validation gate).
///   * Controllers provide the read / intent surface UI
///     consumes.
///
/// ─── Layer ownership ───────────────────────────────────────────────
/// This file is the SOLE owner of every Riverpod provider for the
/// Payment feature. The data layer's `payment_local_datasource_impl.dart`
/// contains only datasource logic and Isar glue — no Riverpod
/// binding.
final paymentLocalDataSourceProvider = Provider<PaymentLocalDataSource>(
  (ref) => PaymentLocalDataSourceImpl(ref.watch(isarInstanceProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepositoryImpl(
    localDataSource: ref.watch(paymentLocalDataSourceProvider),
  ),
);

// ─── Use cases ────────────────────────────────────────────────────────
final registerPaymentUseCaseProvider = Provider<RegisterPaymentUseCase>(
  (ref) => RegisterPaymentUseCase(
    paymentRepository: ref.watch(paymentRepositoryProvider),
    customerRepository: ref.watch(customerRepositoryProvider),
    invoiceRepository: ref.watch(invoiceRepositoryProvider),
  ),
);

final updatePaymentUseCaseProvider = Provider<UpdatePaymentUseCase>(
  (ref) => UpdatePaymentUseCase(
    paymentRepository: ref.watch(paymentRepositoryProvider),
    customerRepository: ref.watch(customerRepositoryProvider),
    invoiceRepository: ref.watch(invoiceRepositoryProvider),
  ),
);

final deletePaymentUseCaseProvider = Provider<DeletePaymentUseCase>(
  (ref) => DeletePaymentUseCase(ref.watch(paymentRepositoryProvider)),
);

final getPaymentByIdUseCaseProvider = Provider<GetPaymentByIdUseCase>(
  (ref) => GetPaymentByIdUseCase(ref.watch(paymentRepositoryProvider)),
);

final getInvoicePaymentsUseCaseProvider = Provider<GetInvoicePaymentsUseCase>(
  (ref) => GetInvoicePaymentsUseCase(ref.watch(paymentRepositoryProvider)),
);

// ─── Controllers ────────────────────────────────────────────────────

/// Family-keyed read state for a customer's payment history (every
/// payment, invoice-tied OR on-account). UI calls
/// `ref.watch(customerPaymentsControllerProvider(customerUuid))`.
class CustomerPaymentsController extends AsyncNotifier<List<PaymentEntity>> {
  CustomerPaymentsController(this.customerUuid);

  final String customerUuid;

  @override
  Future<List<PaymentEntity>> build() async {
    final repo = ref.watch(paymentRepositoryProvider);
    final result = await repo.getPaymentsByCustomer(customerUuid);
    return result.fold((failure) => throw failure, (payments) => payments);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final customerPaymentsControllerProvider =
    AsyncNotifierProvider.family<
      CustomerPaymentsController,
      List<PaymentEntity>,
      String
    >(CustomerPaymentsController.new);

/// Family-keyed read state for a single invoice's payment history.
/// UI calls
/// `ref.watch(invoicePaymentsControllerProvider(invoiceUuid))`.
class InvoicePaymentsController extends AsyncNotifier<List<PaymentEntity>> {
  InvoicePaymentsController(this.invoiceUuid);

  final String invoiceUuid;

  @override
  Future<List<PaymentEntity>> build() async {
    final useCase = ref.watch(getInvoicePaymentsUseCaseProvider);
    final result = await useCase(invoiceUuid);
    return result.fold((failure) => throw failure, (payments) => payments);
  }
}

final invoicePaymentsControllerProvider =
    AsyncNotifierProvider.family<
      InvoicePaymentsController,
      List<PaymentEntity>,
      String
    >(InvoicePaymentsController.new);

/// Write-intent controller for [RegisterPaymentUseCase]. Returns a
/// type-narrow `String? failureMessage` mirroring the customer /
/// service write controllers — UI takes one branch on this and
/// does not have to unpack `Either` itself.
class RegisterPaymentController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(RegisterPaymentParams params) async {
    final useCase = ref.read(registerPaymentUseCaseProvider);
    final result = await useCase(params);
    if (result.isRight) {
      // Refresh sibling controllers so the UI sees the new row.
      ref.invalidate(customerPaymentsControllerProvider(params.customerUuid));
      if (params.invoiceUuid != null) {
        ref.invalidate(invoicePaymentsControllerProvider(params.invoiceUuid!));
      }
      // Balance is derived live from this customer's invoice/payment
      // totals; the mutation just changed the payment side.
      ref.invalidate(customerBalanceControllerProvider(params.customerUuid));
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final registerPaymentControllerProvider =
    NotifierProvider<RegisterPaymentController, void>(
      RegisterPaymentController.new,
    );

class UpdatePaymentController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(UpdatePaymentParams params) async {
    final useCase = ref.read(updatePaymentUseCaseProvider);
    final result = await useCase(params);
    if (result.isRight) {
      ref.invalidate(customerPaymentsControllerProvider(params.customerUuid));
      if (params.invoiceUuid != null) {
        ref.invalidate(invoicePaymentsControllerProvider(params.invoiceUuid!));
      }
      ref.invalidate(customerBalanceControllerProvider(params.customerUuid));
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final updatePaymentControllerProvider =
    NotifierProvider<UpdatePaymentController, void>(
      UpdatePaymentController.new,
    );

class DeletePaymentController extends Notifier<void> {
  @override
  void build() {}

  /// `customerUuid` and `invoiceUuid` are passed alongside `id`
  /// so the controller can invalidate the per-customer payments
  /// family and (when supplied) the per-invoice payments family.
  Future<String?> submit({
    required String id,
    required String customerUuid,
    String? invoiceUuid,
  }) async {
    final useCase = ref.read(deletePaymentUseCaseProvider);
    final result = await useCase(id);
    if (result.isRight) {
      ref.invalidate(customerPaymentsControllerProvider(customerUuid));
      if (invoiceUuid != null) {
        ref.invalidate(invoicePaymentsControllerProvider(invoiceUuid));
      }
      ref.invalidate(customerBalanceControllerProvider(customerUuid));
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final deletePaymentControllerProvider =
    NotifierProvider<DeletePaymentController, void>(
      DeletePaymentController.new,
    );
