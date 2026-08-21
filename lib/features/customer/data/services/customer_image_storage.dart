import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves the root directory used for durable customer image files.
typedef ApplicationDocumentsDirectoryProvider = Future<Directory> Function();

/// Storage boundary for customer profile images.
///
/// The presentation layer passes only the temporary file path returned by
/// `image_picker`. The picker-specific `XFile` type never crosses this
/// boundary, and the database receives only the relative path returned by
/// [persistTemporaryImage].
abstract interface class CustomerImageStorage {
  /// Copies a temporary picker file to durable app-private storage.
  ///
  /// Returns a slash-separated path relative to the application documents
  /// directory, for example `customers/cus-1/avatar.jpg`.
  Future<String> persistTemporaryImage({
    required String customerId,
    required String temporaryPath,
  });

  /// Deletes a previously persisted relative image path.
  ///
  /// A missing file is treated as an idempotent success. Paths outside the
  /// customer-image namespace are rejected so cleanup cannot escape the app
  /// documents directory.
  Future<void> deleteRelativeImage(String? relativePath);
}

/// Local filesystem implementation for [CustomerImageStorage].
class LocalCustomerImageStorage implements CustomerImageStorage {
  LocalCustomerImageStorage({
    ApplicationDocumentsDirectoryProvider? directoryProvider,
  }) : _directoryProvider =
           directoryProvider ?? _defaultDirectoryProvider;

  final ApplicationDocumentsDirectoryProvider _directoryProvider;

  static Future<Directory> _defaultDirectoryProvider() =>
      getApplicationDocumentsDirectory();

  @override
  Future<String> persistTemporaryImage({
    required String customerId,
    required String temporaryPath,
  }) async {
    _validateCustomerId(customerId);

    final source = File(temporaryPath);
    if (!await source.exists()) {
      throw FileSystemException(
        'The selected profile image no longer exists.',
        temporaryPath,
      );
    }

    final extension = _safeImageExtension(source.path);
    final relativePath = p.posix.join(
      'customers',
      customerId,
      'avatar$extension',
    );
    final documentsDirectory = await _directoryProvider();
    final destination = File(
      p.joinAll(<String>[documentsDirectory.path, ...relativePath.split('/')]),
    );

    await destination.parent.create(recursive: true);
    try {
      await source.copy(destination.path);
    } catch (_) {
      // A failed copy must not leave a partial file that could later be
      // mistaken for a successfully persisted profile image.
      if (await destination.exists()) {
        await destination.delete();
      }
      rethrow;
    }

    return relativePath;
  }

  @override
  Future<void> deleteRelativeImage(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) return;

    final normalized = relativePath.replaceAll('\\', '/');
    final segments = normalized.split('/');
    if (!_isSafeRelativeImagePath(normalized, segments)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Only customer profile-image paths may be deleted.',
      );
    }

    final documentsDirectory = await _directoryProvider();
    final file = File(
      p.joinAll(<String>[documentsDirectory.path, ...segments]),
    );
    if (await file.exists()) {
      await file.delete();
    }

    // The customer directory is owned by this image. Removing an empty
    // directory keeps repeated draft/failed-submit attempts from leaking
    // empty folders, while a non-empty directory is left untouched.
    final parent = file.parent;
    try {
      if (await parent.exists()) {
        await parent.delete();
      }
    } on FileSystemException {
      // A non-empty directory is expected when another future attachment
      // shares the customer folder; the image itself was still cleaned up.
    }
  }

  static void _validateCustomerId(String customerId) {
    if (customerId.trim().isEmpty ||
        customerId == '.' ||
        customerId == '..' ||
        customerId.contains('/') ||
        customerId.contains('\\')) {
      throw ArgumentError.value(customerId, 'customerId');
    }
  }

  static bool _isSafeRelativeImagePath(
    String normalized,
    List<String> segments,
  ) {
    return normalized.startsWith('customers/') &&
        segments.length == 3 &&
        segments.every(
          (segment) =>
              segment.isNotEmpty && segment != '.' && segment != '..',
        ) &&
        segments[2].startsWith('avatar.');
  }

  static String _safeImageExtension(String sourcePath) {
    final extension = p.extension(sourcePath).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)
        ? extension
        : '.jpg';
  }
}
