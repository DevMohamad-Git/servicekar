import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/customer_entity.dart';
import 'customer_use_case_providers.dart';

/// Controller exposing a single `submit` intent. UI hands in the
/// current entity (or a copy with edits applied) and receives a
/// nullable failure message back.
class UpdateCustomerController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit(CustomerEntity customer) async {
    final useCase = ref.read(updateCustomerUseCaseProvider);
    final result = await useCase(customer);
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final updateCustomerControllerProvider =
    NotifierProvider<UpdateCustomerController, void>(
  UpdateCustomerController.new,
);
