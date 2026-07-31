import 'package:servicar/core/utils/either.dart';

import '../../../customer/domain/entities/payment_entity.dart';
import '../failures/payment_failure.dart';
import '../repositories/payment_repository.dart';

/// Lookup a single [PaymentEntity] by id. Returns
/// [PaymentNotFoundFailure] when the record is absent.
///
/// Symmetric with [GetCustomerByIdUseCase] / [GetServiceByIdUseCase] —
/// the use case contains the *only* defensive validation (id is
/// non-empty). Everything else delegates to the repository.
class GetPaymentByIdUseCase {
  const GetPaymentByIdUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<PaymentFailure, PaymentEntity>> call(String id) {
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
    return _repository.getPaymentById(id);
  }
}
