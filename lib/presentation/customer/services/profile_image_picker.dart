import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Outcome of a profile-image selection attempt.
enum ProfileImagePickStatus { selected, cancelled, failed }

/// Safe result returned by [ProfileImagePicker].
class ProfileImagePickResult {
  const ProfileImagePickResult._({
    required this.status,
    this.file,
    this.error,
  });

  const ProfileImagePickResult.selected(XFile file)
    : this._(status: ProfileImagePickStatus.selected, file: file);

  const ProfileImagePickResult.cancelled()
    : this._(status: ProfileImagePickStatus.cancelled);

  const ProfileImagePickResult.failed(Object error)
    : this._(status: ProfileImagePickStatus.failed, error: error);

  final ProfileImagePickStatus status;
  final XFile? file;
  final Object? error;

  bool get isSelected => status == ProfileImagePickStatus.selected;
  bool get isCancelled => status == ProfileImagePickStatus.cancelled;
  bool get isFailed => status == ProfileImagePickStatus.failed;
}

/// Presentation-side boundary around the `image_picker` plugin.
///
/// [pickImage] is injectable so cancellation, selection, and plugin failures
/// can be tested without a platform channel. The production callback applies
/// bounded dimensions and JPEG quality before returning the temporary [XFile].
class ProfileImagePicker {
  ProfileImagePicker({ProfileImagePickerCallback? pickImage})
    : _pickImage = pickImage ?? _pickWithPlugin;

  final ProfileImagePickerCallback _pickImage;

  Future<ProfileImagePickResult> pick(ImageSource source) async {
    try {
      final file = await _pickImage(source);
      if (file == null) return const ProfileImagePickResult.cancelled();
      return ProfileImagePickResult.selected(file);
    } catch (error) {
      return ProfileImagePickResult.failed(error);
    }
  }

  /// Best-effort cleanup for an old picker-owned cache file.
  ///
  /// The durable copy is managed by the data-layer storage service; this method only
  /// drops temporary files that this presentation session no longer needs.
  Future<void> discard(XFile? file) async {
    if (file == null || file.path.trim().isEmpty) return;
    try {
      final temporaryFile = File(file.path);
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
    } catch (_) {
      // Picker cache cleanup is best effort and must not interrupt the form.
    }
  }

  static Future<XFile?> _pickWithPlugin(ImageSource source) {
    return ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
  }
}

typedef ProfileImagePickerCallback = Future<XFile?> Function(
  ImageSource source,
);
