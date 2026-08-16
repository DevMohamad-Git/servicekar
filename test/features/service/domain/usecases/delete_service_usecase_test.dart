import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';
import 'package:servicar/features/service/domain/repositories/service_repository.dart';
import 'package:servicar/features/service/domain/usecases/delete_service_usecase.dart';

class RecordingServiceRepository implements ServiceRepository {
  final List<String> deleted = [];
  Either<ServiceFailure, Unit> Function(String) onDelete;

  RecordingServiceRepository({required this.onDelete});

  @override
  Future<Either<ServiceFailure, Unit>> deleteService(String id) async {
    deleted.add(id);
    return onDelete(id);
  }

  // Unused by this test:
  @override
  Future<Either<ServiceFailure, ServiceEntity>> createService(
    ServiceEntity service,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, ServiceEntity>> updateService(
    ServiceEntity service,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String customerUuid,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, int>> getServiceCount() async =>
      throw UnimplementedError();
}

void main() {
  group('DeleteServiceUseCase — gate', () {
    test('empty id → ServiceValidationFailure(field=id)', () async {
      final repo = RecordingServiceRepository(
        onDelete: (id) => throw StateError('should not reach: $id'),
      );
      final useCase = DeleteServiceUseCase(repo);

      final result = await useCase('   ');
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, Unit>).value;
      expect(failure, isA<ServiceValidationFailure>());
      expect((failure as ServiceValidationFailure).field, 'id');
      expect(repo.deleted, isEmpty);
    });

    test('valid id → delegates to repository unchanged', () async {
      final repo = RecordingServiceRepository(
        onDelete: (id) => const Right<ServiceFailure, Unit>(Unit.instance),
      );
      final useCase = DeleteServiceUseCase(repo);

      final result = await useCase('srv-1');
      expect(result.isRight, isTrue);
      expect(
        (result as Right<ServiceFailure, Unit>).value,
        same(Unit.instance),
      );
      expect(repo.deleted, ['srv-1']);
    });

    test('repository storage failure propagates', () async {
      const failure = ServiceStorageFailure(
        operation: 'deleteService',
        message: 'simulated',
      );
      final repo = RecordingServiceRepository(
        onDelete: (_) => const Left<ServiceFailure, Unit>(failure),
      );
      final useCase = DeleteServiceUseCase(repo);

      final result = await useCase('srv-1');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<ServiceFailure, Unit>).value,
        same(failure),
      );
    });
  });
}
