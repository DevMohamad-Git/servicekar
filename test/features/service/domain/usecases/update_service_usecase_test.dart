import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';
import 'package:servicar/features/service/domain/repositories/service_repository.dart';
import 'package:servicar/features/service/domain/usecases/params/update_service_params.dart';
import 'package:servicar/features/service/domain/usecases/update_service_usecase.dart';
import 'package:servicar/features/service/domain/value_models/service_operation_outcome.dart';

class RecordingServiceRepository implements ServiceRepository {
  final List<ServiceEntity> updated = [];
  Either<ServiceFailure, ServiceEntity> Function(ServiceEntity) onUpdate;

  RecordingServiceRepository({required this.onUpdate});

  @override
  Future<Either<ServiceFailure, ServiceEntity>> updateService(
    ServiceEntity service,
  ) async {
    updated.add(service);
    return onUpdate(service);
  }

  // Unused by this test:
  @override
  Future<Either<ServiceFailure, ServiceEntity>> createService(
    ServiceEntity service,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, Unit>> deleteService(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String customerUuid,
  ) async =>
      throw UnimplementedError();
}

void main() {
  UpdateServiceParams baseParams({
    String? id,
    String? title,
    double? price,
    DateTime? startedAt,
  }) =>
      UpdateServiceParams(
        id: id ?? 'srv-1',
        customerUuid: 'cust-1',
        title: title ?? 'Oil change',
        status: ServiceStatus.inProgress,
        price: price ?? 100.0,
        startedAt: startedAt,
      );

  group('UpdateServiceUseCase — validation gates', () {
    test('empty id → ServiceValidationFailure(field=id)', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => throw StateError('should not reach: ${s.id}'),
      );
      final useCase = UpdateServiceUseCase(repo);
      final result = await useCase(baseParams(id: '   '));
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceOperationOutcome>).value;
      expect(failure, isA<ServiceValidationFailure>());
      expect((failure as ServiceValidationFailure).field, 'id');
      expect(repo.updated, isEmpty);
    });

    test('empty title → ServiceValidationFailure(field=title)', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => throw StateError('should not reach: ${s.id}'),
      );
      final useCase = UpdateServiceUseCase(repo);
      final result = await useCase(baseParams(title: '   '));
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceOperationOutcome>).value;
      expect((failure as ServiceValidationFailure).field, 'title');
      expect(repo.updated, isEmpty);
    });

    test('negative price → ServiceValidationFailure(field=price)', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => throw StateError('should not reach: ${s.id}'),
      );
      final useCase = UpdateServiceUseCase(repo);
      final result = await useCase(baseParams(price: -1.0));
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceOperationOutcome>).value;
      expect((failure as ServiceValidationFailure).field, 'price');
    });

    test('zero price accepted', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = UpdateServiceUseCase(repo);
      final result = await useCase(baseParams(price: 0.0));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.service.price, 0.0);
      expect(repo.updated.single.price, 0.0);
    });

    test('valid input → delegates unchanged', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = UpdateServiceUseCase(repo);
      final result = await useCase(baseParams());
      expect(result.isRight, isTrue);
      expect(repo.updated.single.id, 'srv-1');
    });

    test('future-dated startedAt → emits a warning', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = UpdateServiceUseCase(repo);
      final future = DateTime.now().add(const Duration(days: 30));
      final result = await useCase(baseParams(startedAt: future));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.warnings, hasLength(1));
      expect(outcome.warnings.single.field, 'startedAt');
      expect(outcome.warnings.single.message, contains('future'));
    });

    test('past dated startedAt → no warning', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = UpdateServiceUseCase(repo);
      final past = DateTime.now().subtract(const Duration(days: 1));
      final result = await useCase(baseParams(startedAt: past));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.warnings, isEmpty);
    });

    test('null startedAt → no warning', () async {
      final repo = RecordingServiceRepository(
        onUpdate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = UpdateServiceUseCase(repo);
      final result = await useCase(baseParams(startedAt: null));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.service.startedAt, isNull);
      expect(outcome.warnings, isEmpty);
    });

    test('repository storage failure propagates', () async {
      const failure = ServiceStorageFailure(
        operation: 'updateService',
        message: 'simulated',
      );
      final repo = RecordingServiceRepository(
        onUpdate: (_) =>
            const Left<ServiceFailure, ServiceEntity>(failure),
      );
      final useCase = UpdateServiceUseCase(repo);
      final result = await useCase(baseParams());
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<ServiceFailure, ServiceOperationOutcome>).value,
        same(failure),
      );
    });
  });
}
