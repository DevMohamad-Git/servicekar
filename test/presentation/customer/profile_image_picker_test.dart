import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:servicar/presentation/customer/services/profile_image_picker.dart';

void main() {
  test('cancel returns cancelled and does not create a selection', () async {
    ImageSource? requestedSource;
    final picker = ProfileImagePicker(
      pickImage: (source) async {
        requestedSource = source;
        return null;
      },
    );

    final result = await picker.pick(ImageSource.gallery);

    expect(requestedSource, ImageSource.gallery);
    expect(result.isCancelled, isTrue);
    expect(result.file, isNull);
  });

  test('forwards camera source and returns the selected XFile', () async {
    final selected = XFile('/cache/camera.jpg');
    final picker = ProfileImagePicker(
      pickImage: (source) async {
        expect(source, ImageSource.camera);
        return selected;
      },
    );

    final result = await picker.pick(ImageSource.camera);

    expect(result.isSelected, isTrue);
    expect(result.file, same(selected));
  });

  test('contains picker errors as a failed result', () async {
    final picker = ProfileImagePicker(
      pickImage: (_) async => throw StateError('picker unavailable'),
    );

    final result = await picker.pick(ImageSource.gallery);

    expect(result.isFailed, isTrue);
    expect(result.error, isA<StateError>());
  });

  test('discards an obsolete picker cache file without throwing', () async {
    final directory = await Directory.systemTemp.createTemp(
      'servicar_picker_cleanup_',
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    final file = File('${directory.path}${Platform.pathSeparator}old.jpg');
    await file.writeAsBytes(const <int>[1, 2, 3]);

    final picker = ProfileImagePicker(pickImage: (_) async => null);
    await picker.discard(XFile(file.path));

    expect(await file.exists(), isFalse);
  });
}
