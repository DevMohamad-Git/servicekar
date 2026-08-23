import 'package:image_picker/image_picker.dart';

/// Outcome of a service-photo selection attempt.
enum ServicePhotoPickStatus { selected, cancelled, failed }

/// Safe result returned by [ServicePhotoPicker].
class ServicePhotoPickResult {
  const ServicePhotoPickResult._({
    required this.status,
    this.file,
    this.error,
  });

  const ServicePhotoPickResult.selected(this.file)
    : status = ServicePhotoPickStatus.selected,
      error = null;

  const ServicePhotoPickResult.cancelled()
    : status = ServicePhotoPickStatus.cancelled,
      file = null,
      error = null;

  const ServicePhotoPickResult.failed(Object this.error)
    : status = ServicePhotoPickStatus.failed,
      file = null;

  final ServicePhotoPickStatus status;
  final XFile? file;
  final Object? error;

  bool get isSelected => status == ServicePhotoPickStatus.selected;
  bool get isCancelled => status == ServicePhotoPickStatus.cancelled;
  bool get isFailed => status == ServicePhotoPickStatus.failed;
}

/// Presentation-side boundary around the `image_picker` plugin for the
/// service-entry photo flow.
///
/// Mirrors the customer module's `ProfileImagePicker` contract:
/// [pickImage] is injectable so cancellation, selection, and permission /
/// plugin failures can be tested without a platform channel. On Android
/// the plugin itself requests the CAMERA permission at runtime (granted
/// the manifest declares it) and uses the system Photo Picker for the
/// gallery on Android 13+, so no extra permission wiring is needed here.
class ServicePhotoPicker {
  ServicePhotoPicker({ServicePhotoPickerCallback? pickImage})
    : _pickImage = pickImage ?? _pickWithPlugin;

  final ServicePhotoPickerCallback _pickImage;

  Future<ServicePhotoPickResult> pick(ImageSource source) async {
    try {
      final file = await _pickImage(source);
      if (file == null) return const ServicePhotoPickResult.cancelled();
      return ServicePhotoPickResult.selected(file);
    } catch (error) {
      // Reaches here for camera_access_denied / photo_access_denied and
      // every other plugin failure — surfaced to the caller as one state.
      return ServicePhotoPickResult.failed(error);
    }
  }

  static Future<XFile?> _pickWithPlugin(ImageSource source) {
    return ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
  }
}

typedef ServicePhotoPickerCallback = Future<XFile?> Function(
  ImageSource source,
);
