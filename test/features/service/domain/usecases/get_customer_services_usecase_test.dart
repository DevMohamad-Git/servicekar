import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';
import 'package:servicar/features/service/domain/repositories/service_repository.dart';
import 'package:servicar/features/service/domain/usecases/get_customer_services_usecase.dart';

class RecordingServiceRepository implements ServiceRepository {
  Either<ServiceFailure, List<ServiceEntity>> Function(String) onList;

  RecordingServiceRepository({required this.onList});

  @override
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String customerUuid,
  ) async =>
      onList(customerUuid);

  @override
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(String id) async =>
      throw UnimplementedError();

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
}

void main() {
  group('GetCustomerServicesUseCase — gate', () {
    test(
      'empty customerUuid → ServiceValidationFailure(field=customerUuid)',
      () async {
        final repo = RecordingServiceRepository(
          onList: (c) => throw StateError('should not reach repo: $c'),
        );
        final useCase = GetCustomerServicesUseCase(repo);

        final result = await useCase('   ');
        expect(result.isLeft, isTrue);
        final failure =
            (result as Left<ServiceFailure, List<ServiceEntity>>).value;
        expect(failure, isA<ServiceValidationFailure>());
        expect((failure as ServiceValidationFailure).field, 'customerUuid');
      },
    );

    test('valid customerUuid → delegates to repository unchanged', () async {
      final repo = RecordingServiceRepository(
        onList: (_) => const Right<ServiceFailure, List<ServiceEntity>>([]),
      );
      final useCase = GetCustomerServicesUseCase(repo);

      final result = await useCase('cust-1');
      expect(result.isRight, isTrue);
      expect(
        (result as Right<ServiceFailure, List<ServiceEntity>>).value,
        isEmpty,
      );
    });

    test('repository success returns the list verbatim', () async {
      final list = const [
        ServiceEntity(id: 'a', customerUuid: 'cust-1', title: 'A'),
        ServiceEntity(id: 'b', customerUuid: 'cust-1', title: 'B'),
      ];
      final repo = RecordingServiceRepository(
        onList: (_) => Right<ServiceFailure, List<ServiceEntity>>(list),
      );
      final useCase = GetCustomerServicesUseCase(repo);

      final result = await useCase('cust-1');
      expect(result.isRight, isTrue);
      final services =
          (result as Right<ServiceFailure, List<ServiceEntity>>).value;
      expect(services.map((s) => s.id).toSet(), {'a', 'b'});
    });

    test('repository storage failure propagates', () async {
      const failure = ServiceStorageFailure(
        operation: 'getServicesByCustomer',
        message: 'simulated',
      );
      final repo = RecordingServiceRepository(
        onList: (_) => const Left<ServiceFailure, List<ServiceEntity>>(failure),
      );
      final useCase = GetCustomerServicesUseCase(repo);

      final result = await useCase('cust-1');
      expect(result.isLeft, isTrue);
      expect(
        (result as Left<ServiceFailure, List<ServiceEntity>>).value,
        same(failure),
      );
    });
  });
}
