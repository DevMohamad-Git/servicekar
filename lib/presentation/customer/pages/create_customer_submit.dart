import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/customer/data/services/customer_image_storage.dart';
import '../../../injection/feature_injection/customer_providers.dart';

/// Presentation-only draft of the values captured by the Create Customer form.
///
/// Deliberately does not contain `XFile`: the page owns the temporary picker
/// object and passes only its path through this presentation draft. The path
/// is copied to durable storage by [LiveCreateCustomerSubmit] before the
/// domain Entity is constructed.
@immutable
class CreateCustomerDraft {
  const CreateCustomerDraft({
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.notes,
    this.profileImageTempPath,
  });

  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? notes;

  /// Cache path owned by the picker for the current form session.
  final String? profileImageTempPath;
}

/// Submit boundary behind the Create Customer form.
///
/// Returns `null` on success, or a failure message on failure. Keeping this
/// boundary presentation-friendly lets the page remain independent of the
/// repository while the live adapter coordinates file and Entity persistence.
abstract class CreateCustomerSubmit {
  Future<String?> call(CreateCustomerDraft draft);
}

/// Live Create Customer adapter.
///
/// The image copy happens before the customer write because the stable
/// customer id is needed in the destination path. If the database rejects the
/// Entity, the newly copied file is deleted so no path points at an orphaned
/// file and no orphaned file remains on disk.
class LiveCreateCustomerSubmit implements CreateCustomerSubmit {
  const LiveCreateCustomerSubmit({
    required CreateCustomerController controller,
    required CustomerImageStorage imageStorage,
  }) : _controller = controller,
       _imageStorage = imageStorage;

  final CreateCustomerController _controller;
  final CustomerImageStorage _imageStorage;

  @override
  Future<String?> call(CreateCustomerDraft draft) async {
    final customerId = _newCustomerId();
    String? persistedImagePath;

    try {
      final temporaryPath = draft.profileImageTempPath;
      if (temporaryPath != null && temporaryPath.trim().isNotEmpty) {
        persistedImagePath = await _imageStorage.persistTemporaryImage(
          customerId: customerId,
          temporaryPath: temporaryPath,
        );
      }

      final failure = await _controller.submit(
        id: customerId,
        fullName: draft.fullName,
        phoneNumber: draft.phoneNumber,
        email: draft.email,
        address: draft.address,
        notes: draft.notes,
        profileImagePath: persistedImagePath,
      );

      if (failure != null) {
        await _cleanup(persistedImagePath);
      }
      return failure;
    } catch (error) {
      await _cleanup(persistedImagePath);
      return error.toString();
    }
  }

  Future<void> _cleanup(String? relativePath) async {
    if (relativePath == null) return;
    try {
      await _imageStorage.deleteRelativeImage(relativePath);
    } catch (_) {
      // Preserve the original create/storage failure. Cleanup is best effort
      // and must never crash the form or replace the useful error message.
    }
  }

  static String _newCustomerId() =>
      'cus_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
}

/// The production provider consumed by [CreateCustomerPage].
final createCustomerSubmitProvider = Provider<CreateCustomerSubmit>((ref) {
  return LiveCreateCustomerSubmit(
    controller: ref.read(createCustomerControllerProvider.notifier),
    imageStorage: ref.read(customerImageStorageProvider),
  );
});
