import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:servicar/features/customer/data/services/customer_image_storage.dart';

void main() {
  late Directory documentsDirectory;
  late Directory sourceDirectory;
  late LocalCustomerImageStorage storage;

  setUp(() async {
    documentsDirectory = await Directory.systemTemp.createTemp(
      'servicar_customer_documents_',
    );
    sourceDirectory = await Directory.systemTemp.createTemp(
      'servicar_picker_cache_',
    );
    storage = LocalCustomerImageStorage(
      directoryProvider: () async => documentsDirectory,
    );
  });

  tearDown(() async {
    if (await documentsDirectory.exists()) {
      await documentsDirectory.delete(recursive: true);
    }
    if (await sourceDirectory.exists()) {
      await sourceDirectory.delete(recursive: true);
    }
  });

  test('copies the picker file and returns a relative avatar path', () async {
    final source = File(p.join(sourceDirectory.path, 'picked.PNG'));
    const bytes = <int>[1, 2, 3, 4];
    await source.writeAsBytes(bytes);

    final relativePath = await storage.persistTemporaryImage(
      customerId: 'cus-1',
      temporaryPath: source.path,
    );

    expect(relativePath, 'customers/cus-1/avatar.png');
    final destination = File(
      p.joinAll(<String>[
        documentsDirectory.path,
        ...relativePath.split('/'),
      ]),
    );
    expect(await destination.exists(), isTrue);
    expect(await destination.readAsBytes(), bytes);
  });

  test('deletes a persisted image and tolerates a repeated cleanup', () async {
    final source = File(p.join(sourceDirectory.path, 'picked.jpg'));
    await source.writeAsBytes(const <int>[9, 8, 7]);
    final relativePath = await storage.persistTemporaryImage(
      customerId: 'cus-2',
      temporaryPath: source.path,
    );
    final destination = File(
      p.joinAll(<String>[
        documentsDirectory.path,
        ...relativePath.split('/'),
      ]),
    );

    await storage.deleteRelativeImage(relativePath);
    await storage.deleteRelativeImage(relativePath);

    expect(await destination.exists(), isFalse);
  });

  test('fails without creating a database path for a missing source', () async {
    expect(
      storage.persistTemporaryImage(
        customerId: 'cus-3',
        temporaryPath: p.join(sourceDirectory.path, 'missing.jpg'),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(
      await Directory(p.join(documentsDirectory.path, 'customers')).exists(),
      isFalse,
    );
  });
}
