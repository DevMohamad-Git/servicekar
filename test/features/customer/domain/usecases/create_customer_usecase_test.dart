import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/customer/domain/usecases/create_customer_usecase.dart';

/// Records every `createCustomer` call and returns whatever outcome
/// the test wants. Other methods stay unimplemented — this exercise
/// only exercises the create path.
///
/// Design note: `onCreate` is intentionally synchronous (`Either<...>`
/// return value rather than `Future<Either<...>>`). The repository's
/// `createCustomer` is `async` so the bridge back into the use case
/// happens with a normal implicit `Future` lift.
class RecordingCustomerRepository implements CustomerRepository {
  final List<CustomerEntity> created = [];
  final Either<CustomerFailure, CustomerEntity> Function(CustomerEntity)
  onCreate;

  RecordingCustomerRepository({required this.onCreate});

  @override
  Future<Either<CustomerFailure, CustomerEntity>> createCustomer(
    CustomerEntity customer,
  ) async {
    created.add(customer);
    return onCreate(customer);
  }

  @override
  Future<Either<CustomerFailure, CustomerEntity>> updateCustomer(
    CustomerEntity c,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, Unit>> deleteCustomer(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async => throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> getCustomers() async =>
      throw UnimplementedError();

  @override
  Future<Either<CustomerFailure, List<CustomerEntity>>> searchCustomers(
    String q,
  ) async => throw UnimplementedError();
}

/// Sample-use-case test: covers the validation gates and the
/// delegation contract. Does not exercise feature wiring.
void main() {
  group('CreateCustomerUseCase', () {
    test(
      'empty fullName → CustomerValidationFailure(field=fullName)',
      () async {
        // Recording factory would be called only if validation passes;
        // assert below that it is NOT called.
        final repo = RecordingCustomerRepository(
          onCreate: (CustomerEntity c) =>
              Right<CustomerFailure, CustomerEntity>(c),
        );
        final useCase = CreateCustomerUseCase(repo);

        final result = await useCase(
          const CustomerEntity(
            id: 'x',
            fullName: '   ',
            phoneNumber: '+98 912 000 0000',
          ),
        );

        expect(result.isLeft, isTrue);
        final failure = (result as Left<CustomerFailure, CustomerEntity>).value;
        expect(failure, isA<CustomerValidationFailure>());
        expect((failure as CustomerValidationFailure).field, 'fullName');
        // Repository must NOT have been touched.
        expect(repo.created, isEmpty);
      },
    );

    test(
      'empty phoneNumber → CustomerValidationFailure(field=phoneNumber)',
      () async {
        final repo = RecordingCustomerRepository(
          onCreate: (CustomerEntity c) =>
              Right<CustomerFailure, CustomerEntity>(c),
        );
        final useCase = CreateCustomerUseCase(repo);

        final result = await useCase(
          const CustomerEntity(id: 'x', fullName: 'Alice', phoneNumber: '   '),
        );

        expect(result.isLeft, isTrue);
        final failure = (result as Left<CustomerFailure, CustomerEntity>).value;
        expect(failure, isA<CustomerValidationFailure>());
        expect((failure as CustomerValidationFailure).field, 'phoneNumber');
        expect(repo.created, isEmpty);
      },
    );

    test('valid input → delegates to the repository unchanged', () async {
      const input = CustomerEntity(
        id: 'c1',
        fullName: 'Alice',
        phoneNumber: '+98 912 000 0000',
      );
      final repo = RecordingCustomerRepository(
        onCreate: (CustomerEntity c) =>
            Right<CustomerFailure, CustomerEntity>(c),
      );
      final useCase = CreateCustomerUseCase(repo);

      final result = await useCase(input);

      expect(result.isRight, isTrue);
      final saved = (result as Right<CustomerFailure, CustomerEntity>).value;
      expect(saved.fullName, 'Alice');
      // Repository was called exactly once with the same entity.
      expect(repo.created, hasLength(1));
      expect(repo.created.single.id, 'c1');
    });

    test(
      'repository failure propagates untouched through the use case',
      () async {
        const failure = CustomerStorageFailure(
          operation: 'createCustomer',
          message: 'simulated',
        );
        final repo = RecordingCustomerRepository(
          onCreate: (_) => const Left<CustomerFailure, CustomerEntity>(failure),
        );
        final useCase = CreateCustomerUseCase(repo);

        final result = await useCase(
          const CustomerEntity(
            id: 'c1',
            fullName: 'Alice',
            phoneNumber: '+98 912 000 0000',
          ),
        );

        expect(result.isLeft, isTrue);
        expect(
          (result as Left<CustomerFailure, CustomerEntity>).value,
          same(failure),
        );
      },
    );
  });
}
