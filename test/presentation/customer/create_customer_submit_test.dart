import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/services/customer_image_storage.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/injection/feature_injection/customer_providers.dart';
import 'package:servicar/presentation/customer/pages/create_customer_submit.dart';

class _RecordingImageStorage implements CustomerImageStorage {
  _RecordingImageStorage({this.persistedPath = 'customers/cus/avatar.jpg'});

  final String persistedPath;
  String? temporaryPath;
  String? customerId;
  final List<String> deletedPaths = <String>[];

  @override
  Future<String> persistTemporaryImage({
    required String customerId,
    required String temporaryPath,
  }) async {
    this.customerId = customerId;
    this.temporaryPath = temporaryPath;
    return persistedPath;
  }

  @override
  Future<void> deleteRelativeImage(String? relativePath) async {
    if (relativePath != null) deletedPaths.add(relativePath);
  }
}

class _RecordingCustomerRepository implements CustomerRepository {
  _RecordingCustomerRepository(this.createResult);

  final Either<CustomerFailure, CustomerEntity> createResult;
  CustomerEntity? created;

  @override
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity customer,
  ) async {
    created = customer;
    return createResult;
  }

  @override
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity customer,
  ) => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, Unit>> deleteCustomer(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> getCustomers() =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> searchCustomers(
    String query,
  ) => throw UnimplementedError();
}

void main() {
  late ProviderContainer container;

  tearDown(() {
    container.dispose();
  });

  test('persists the relative image path through the live create flow', () async {
    final repository = _RecordingCustomerRepository(
      const Right<CustomerFailure, CustomerEntity>(
        CustomerEntity(id: 'created', fullName: 'Alice', phoneNumber: '1'),
      ),
    );
    final storage = _RecordingImageStorage(
      persistedPath: 'customers/cus/avatar.webp',
    );
    container = ProviderContainer(
      overrides: [
        customerRepositoryProvider.overrideWithValue(repository),
        customerImageStorageProvider.overrideWithValue(storage),
      ],
    );

    final result = await container.read(createCustomerSubmitProvider)(
      const CreateCustomerDraft(
        fullName: 'Alice',
        phoneNumber: '09121234567',
        profileImageTempPath: '/cache/picked.webp',
      ),
    );

    expect(result, isNull);
    expect(storage.temporaryPath, '/cache/picked.webp');
    expect(storage.customerId, startsWith('cus_'));
    expect(repository.created?.profileImagePath, 'customers/cus/avatar.webp');
    expect(storage.deletedPaths, isEmpty);
  });

  test('cleans the newly copied file when the customer write fails', () async {
    const failure = CustomerStorageFailure(
      operation: 'createCustomer',
      message: 'disk full',
    );
    final repository = _RecordingCustomerRepository(
      const Left<CustomerFailure, CustomerEntity>(failure),
    );
    final storage = _RecordingImageStorage();
    container = ProviderContainer(
      overrides: [
        customerRepositoryProvider.overrideWithValue(repository),
        customerImageStorageProvider.overrideWithValue(storage),
      ],
    );

    final result = await container.read(createCustomerSubmitProvider)(
      const CreateCustomerDraft(
        fullName: 'Alice',
        phoneNumber: '09121234567',
        profileImageTempPath: '/cache/picked.jpg',
      ),
    );

    expect(result, failure.message);
    expect(repository.created?.profileImagePath, 'customers/cus/avatar.jpg');
    expect(storage.deletedPaths, ['customers/cus/avatar.jpg']);
  });

  test('does not touch image storage when no image was selected', () async {
    final repository = _RecordingCustomerRepository(
      const Right<CustomerFailure, CustomerEntity>(
        CustomerEntity(id: 'created', fullName: 'Alice', phoneNumber: '1'),
      ),
    );
    final storage = _RecordingImageStorage();
    container = ProviderContainer(
      overrides: [
        customerRepositoryProvider.overrideWithValue(repository),
        customerImageStorageProvider.overrideWithValue(storage),
      ],
    );

    final result = await container.read(createCustomerSubmitProvider)(
      const CreateCustomerDraft(
        fullName: 'Alice',
        phoneNumber: '09121234567',
      ),
    );

    expect(result, isNull);
    expect(storage.temporaryPath, isNull);
    expect(repository.created?.profileImagePath, isNull);
  });
}
