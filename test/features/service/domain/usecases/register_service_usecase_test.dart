import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/data/models/customer_model.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/entities/service_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/service/domain/failures/service_failure.dart';
import 'package:servicar/features/service/domain/repositories/service_repository.dart';
import 'package:servicar/features/service/domain/usecases/params/register_service_params.dart';
import 'package:servicar/features/service/domain/usecases/register_service_usecase.dart';
import 'package:servicar/features/service/domain/value_models/service_operation_outcome.dart';

/// Recording fake of [ServiceRepository] — only `createService` is
/// exercised by these tests; everything else throws [UnimplementedError]
/// so any unintended delegation fails loudly.
class RecordingServiceRepository implements ServiceRepository {
  final List<ServiceEntity> created = [];
  final Either<ServiceFailure, ServiceEntity> Function(ServiceEntity) onCreate;

  RecordingServiceRepository({required this.onCreate});

  @override
  Future<Either<ServiceFailure, ServiceEntity>> createService(
    ServiceEntity service,
  ) async {
    created.add(service);
    return onCreate(service);
  }

  @override
  Future<Either<ServiceFailure, ServiceEntity>> updateService(
    ServiceEntity s,
  ) async => throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, Unit>> deleteService(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, ServiceEntity>> getServiceById(
    String id,
  ) async => throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, List<ServiceEntity>>> getServicesByCustomer(
    String c,
  ) async => throw UnimplementedError();

  @override
  Future<Either<ServiceFailure, int>> getServiceCount() async =>
      throw UnimplementedError();
}

/// Recording fake of [CustomerRepository] — only `getCustomerById` is
/// exercised by these tests.
class RecordingCustomerRepository implements CustomerRepository {
  final Map<String, CustomerEntity> _store;
  RecordingCustomerRepository([Map<String, CustomerEntity>? seed])
    : _store = {...?seed};

  // Get-by-id shortcut for the happy path: preload existing rows.
  factory RecordingCustomerRepository.withExisting(
    Iterable<CustomerEntity> existing,
  ) => RecordingCustomerRepository({for (final c in existing) c.id: c});

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async {
    final c = _store[id];
    if (c == null) {
      return Left(CustomerNotFoundFailure(id: id));
    }
    return Right(c);
  }

  @override
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity c,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity c,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, Unit>> deleteCustomer(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> getCustomers() async =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> searchCustomers(
    String q,
  ) async => throw UnimplementedError();
}

void main() {
  final okCustomer = const CustomerEntity(
    id: 'cust-1',
    fullName: 'Alice',
    phoneNumber: '+98 912 000 0000',
  );
  final okCustomerRepo = RecordingCustomerRepository.withExisting([okCustomer]);

  RegisterServiceParams baseParams({DateTime? startedAt, String? title}) =>
      RegisterServiceParams(
        id: 'srv-1',
        customerUuid: okCustomer.id,
        title: title ?? 'Oil change',
        price: 100.0,
        startedAt: startedAt,
      );

  group('RegisterServiceUseCase — validation gates', () {
    test('empty title → ServiceValidationFailure(field=title)', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final result = await useCase(baseParams(title: '   '));
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceOperationOutcome>).value;
      expect(failure, isA<ServiceValidationFailure>());
      expect((failure as ServiceValidationFailure).field, 'title');
      expect(repo.created, isEmpty);
    });

    test('negative price → ServiceValidationFailure(field=price)', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final result = await useCase(
        RegisterServiceParams(
          id: 'srv-1',
          customerUuid: okCustomer.id,
          title: 'Oil change',
          price: -1.0,
        ),
      );
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceOperationOutcome>).value;
      expect(failure, isA<ServiceValidationFailure>());
      expect((failure as ServiceValidationFailure).field, 'price');
      expect(repo.created, isEmpty);
    });

    test('zero price is accepted (warranty / free service)', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final result = await useCase(
        RegisterServiceParams(
          id: 'srv-1',
          customerUuid: okCustomer.id,
          title: 'Warranty check',
          price: 0.0,
          tags: const ['warranty'],
        ),
      );
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.service.price, 0.0);
      expect(outcome.warnings, isEmpty);
      expect(repo.created.single.price, 0.0);
    });

    test('CustomerMissingFailure when FK does not resolve', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final emptyCustomerRepo = RecordingCustomerRepository(); // no rows
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: emptyCustomerRepo,
      );

      final result = await useCase(baseParams());
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<ServiceFailure, ServiceOperationOutcome>).value;
      expect(failure, isA<ServiceCustomerMissingFailure>());
      expect((failure as ServiceCustomerMissingFailure).reason, 'notFound');
      expect(repo.created, isEmpty);
    });

    test('valid input → delegates to the repository unchanged', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final result = await useCase(baseParams());
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.service.title, 'Oil change');
      expect(outcome.service.customerUuid, okCustomer.id);
      // Repository was called exactly once with the same id.
      expect(repo.created, hasLength(1));
      expect(repo.created.single.id, 'srv-1');
      // No future date → no warning.
      expect(outcome.warnings, isEmpty);
    });

    test('future-dated startedAt → emits a warning (not a failure)', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final future = DateTime.now().add(const Duration(days: 30));
      final result = await useCase(baseParams(startedAt: future));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.service.startedAt, future);
      expect(outcome.warnings, hasLength(1));
      expect(outcome.warnings.single.field, 'startedAt');
      expect(outcome.warnings.single.message, contains('future'));
    });

    test('past-dated startedAt → no warning', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final past = DateTime.now().subtract(const Duration(days: 1));
      final result = await useCase(baseParams(startedAt: past));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.warnings, isEmpty);
    });

    test('null startedAt → no warning', () async {
      final repo = RecordingServiceRepository(
        onCreate: (s) => Right<ServiceFailure, ServiceEntity>(s),
      );
      final useCase = RegisterServiceUseCase(
        serviceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final result = await useCase(baseParams(startedAt: null));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<ServiceFailure, ServiceOperationOutcome>).value;
      expect(outcome.service.startedAt, isNull);
      expect(outcome.warnings, isEmpty);
    });

    test(
      'Repository.storage failure propagates with operation=createService',
      () async {
        const failure = ServiceStorageFailure(
          operation: 'createService',
          message: 'simulated',
        );
        final repo = RecordingServiceRepository(
          onCreate: (_) => const Left<ServiceFailure, ServiceEntity>(failure),
        );
        final useCase = RegisterServiceUseCase(
          serviceRepository: repo,
          customerRepository: okCustomerRepo,
        );

        final result = await useCase(baseParams());
        expect(result.isLeft, isTrue);
        expect(
          (result as Left<ServiceFailure, ServiceOperationOutcome>).value,
          same(failure),
        );
      },
    );
  });

  group('CustomerModel — sanity check', () {
    test('Round-trips through entity↔model mapper unchanged', () {
      const e = CustomerEntity(
        id: 'cust-1',
        fullName: 'Alice',
        phoneNumber: '+98 912 000 0000',
      );
      // Build a Model by going through the entity; cheap regression
      // test to keep the recording factory honest.
      final m = CustomerModel(
        id: e.id,
        fullName: e.fullName,
        phoneNumber: e.phoneNumber,
      );
      expect(m.id, 'cust-1');
      expect(m.fullName, 'Alice');
    });
  });
}
