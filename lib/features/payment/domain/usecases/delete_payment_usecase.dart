import 'package:servicar/core/utils/either.dart';

import '../failures/payment_failure.dart';
import '../repositories/payment_repository.dart';

/// Permanently remove a payment. Symmetric with
/// `DeleteServiceUseCase` / `DeleteCustomerUseCase` — the
/// implementation may soft-delete later, but the contract exposes
/// removal from the caller's POV.
///
/// `id` is required; an empty / whitespace string is treated as
/// [PaymentValidationFailure] for symmetry with the other
/// `DeleteXUseCase` validators.
class DeletePaymentUseCase {
  const DeletePaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<PaymentFailure, Unit>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(
        const Left(
          PaymentValidationFailure(
            field: 'id',
            message: 'Payment id is required.',
          ),
        ),
      );
    }
    return _repository.deletePayment(id);
  }
}
