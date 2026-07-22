import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/customer_entity.dart';
import 'customer_use_case_providers.dart';

/// Controller exposing a single `submit` intent. The page form supplies
/// field values; this controller stitches them into a [CustomerEntity]
/// and delegates to the use case.
///
/// Returns `null` on success, or a failure message string on failure.
class CreateCustomerController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> submit({
    required String id,
    required String fullName,
    required String phoneNumber,
    String? email,
    String? address,
    String? notes,
    List<String> tags = const <String>[],
  }) async {
    final useCase = ref.read(createCustomerUseCaseProvider);
    final result = await useCase(
      CustomerEntity(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        notes: notes,
        tags: tags,
      ),
    );
    return result.fold((failure) => failure.message, (_) => null);
  }
}

final createCustomerControllerProvider =
    NotifierProvider<CreateCustomerController, void>(
  CreateCustomerController.new,
);
