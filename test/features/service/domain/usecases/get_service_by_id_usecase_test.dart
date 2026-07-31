import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';
import 'package:servicar/features/service/domain/repositories/service_repository.dart';
import 'package:servicar/features/service/domain/usecases/get_service_by_id_usecase.dart';

/// Recording [ServiceRepository] — only `getServiceById` is exercised
/// by this test; everything else throws so any unintended delegation
/// fails loudly.
class RecordingServiceRepository implements ServiceRepository {
  Either<ServiceFailure, ServiceEntity> Function(String) onGetById;

  RecordingServiceRepository({required this.onGetById});

  @override
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(String id) async =>
      onGetById(id);

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
  Future<Either<ServiceFailure, Unit>> deleteService(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String customerUuid,
  ) async =>
      throw UnimplementedError();
}

void main() {
  const okEntity = ServiceEntity(
    id: 'srv-1',
    customerUuid: 'cust-1',
    title: 'Oil change',
  );

  group('GetServiceByIdUseCase — gate', () {
    test('empty id → ServiceValidationFailure(field=id)', () async {
      final repo = RecordingServiceRepository(
        onGetById: (id) => throw StateError('should not reach repo: $id'),
      );
      final useCase = GetServiceByIdUseCase(repo);

      final result = await useCase('   ');
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceEntity>).value;
      expect(failure, isA<ServiceValidationFailure>());
      expect((failure as ServiceValidationFailure).field, 'id');
    });

    test('valid id → delegates to repository unchanged', () async {
      final repo = RecordingServiceRepository(
        onGetById: (id) => Right<ServiceFailure, ServiceEntity>(okEntity),
      );
      final useCase = GetServiceByIdUseCase(repo);

      final result = await useCase('srv-1');
      expect(result.isRight, isTrue);
      expect(
        (result as Right<ServiceFailure, ServiceEntity>).value.id,
        'srv-1',
      );
    });

    test('repository NotFound propagates untouched', () async {
      final repo = RecordingServiceRepository(
        onGetById: (id) => Left<ServiceFailure, ServiceEntity>(
          ServiceNotFoundFailure(id: id),
        ),
      );
      final useCase = GetServiceByIdUseCase(repo);

      final result = await useCase('missing');
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceEntity>).value;
      expect(failure, isA<ServiceNotFoundFailure>());
      expect((failure as ServiceNotFoundFailure).id, 'missing');
    });
  });
}
