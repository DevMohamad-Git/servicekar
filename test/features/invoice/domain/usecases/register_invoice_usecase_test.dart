import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/customer_entity.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
import 'package:servicar/features/customer/domain/failures/customer_failure.dart';
import 'package:servicar/features/customer/domain/repositories/customer_repository.dart';
import 'package:servicar/features/invoice/domain/failures/invoice_failure.dart';
import 'package:servicar/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:servicar/features/invoice/domain/usecases/params/register_invoice_params.dart';
import 'package:servicar/features/invoice/domain/usecases/register_invoice_usecase.dart';
import 'package:servicar/features/invoice/domain/value_models/invoice_operation_outcome.dart';

/// Recording fake of [InvoiceRepository] — only `createInvoice` is
/// exercised by these tests. Everything else throws
/// [UnimplementedError] so any unintended delegation fails loudly.
class RecordingInvoiceRepository implements InvoiceRepository {
  final List<InvoiceEntity> created = [];
  final Either<InvoiceFailure, InvoiceEntity> Function(InvoiceEntity) onCreate;

  RecordingInvoiceRepository({required this.onCreate});

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> createInvoice(
    InvoiceEntity invoice,
  ) async {
    created.add(invoice);
    return onCreate(invoice);
  }

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> updateInvoice(
    InvoiceEntity i,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, Unit>> deleteInvoice(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, List<InvoiceEntity>>> getByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, double>> getTotalByCustomer(
    String uuid,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, int>> getInvoiceCount() async =>
      throw UnimplementedError();
}

/// Recording fake of [CustomerRepository] — only `getCustomerById` is
/// exercised by these tests.
class RecordingCustomerRepository implements CustomerRepository {
  final Map<String, CustomerEntity> _store;
  RecordingCustomerRepository([Map<String, CustomerEntity>? seed])
    : _store = {...?seed};

  factory RecordingCustomerRepository.withExisting(
    Iterable<CustomerEntity> existing,
  ) => RecordingCustomerRepository({for (final c in existing) c.id: c});

  @override
  Future<Either<CustomerFailure, CustomerEntity>> getCustomerById(
    String id,
  ) async {
    final c = _store[id];
    if (c == null) return Left(CustomerNotFoundFailure(id: id));
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
      const Left(CustomerNotFoundFailure(id: 'unsupported'));

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

  RegisterInvoiceParams baseParams({
    String invoiceNumber = 'INV-001',
    double totalAmount = 1_000_000.0,
    DateTime? issueDate,
  }) => RegisterInvoiceParams(
    id: 'inv-1',
    customerUuid: okCustomer.id,
    invoiceNumber: invoiceNumber,
    issueDate: issueDate ?? DateTime.utc(2026, 1, 1),
    totalAmount: totalAmount,
  );

  group('RegisterInvoiceUseCase — validation gates', () {
    test(
      'empty invoiceNumber → InvoiceValidationFailure(field=invoiceNumber)',
      () async {
        final repo = RecordingInvoiceRepository(
          onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
        );
        final useCase = RegisterInvoiceUseCase(
          invoiceRepository: repo,
          customerRepository: okCustomerRepo,
        );

        final result = await useCase(baseParams(invoiceNumber: '   '));
        expect(result.isLeft, isTrue);
        final failure =
            (result as Left<InvoiceFailure, InvoiceOperationOutcome>).value;
        expect(failure, isA<InvoiceValidationFailure>());
        expect((failure as InvoiceValidationFailure).field, 'invoiceNumber');
        expect(repo.created, isEmpty);
      },
    );

    test(
      'negative totalAmount → InvoiceValidationFailure(field=totalAmount)',
      () async {
        final repo = RecordingInvoiceRepository(
          onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
        );
        final useCase = RegisterInvoiceUseCase(
          invoiceRepository: repo,
          customerRepository: okCustomerRepo,
        );

        final result = await useCase(baseParams(totalAmount: -1.0));
        expect(result.isLeft, isTrue);
        final failure =
            (result as Left<InvoiceFailure, InvoiceOperationOutcome>).value;
        expect(failure, isA<InvoiceValidationFailure>());
        expect((failure as InvoiceValidationFailure).field, 'totalAmount');
        expect(repo.created, isEmpty);
      },
    );

    test('zero totalAmount is accepted (zero-invoice per the brief)', () async {
      final repo = RecordingInvoiceRepository(
        onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final useCase = RegisterInvoiceUseCase(
        invoiceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final result = await useCase(baseParams(totalAmount: 0.0));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<InvoiceFailure, InvoiceOperationOutcome>).value;
      expect(outcome.invoice.totalAmount, 0.0);
      expect(outcome.warnings, isEmpty);
      expect(repo.created.single.totalAmount, 0.0);
    });

    test(
      'NaN totalAmount → InvoiceValidationFailure(field=totalAmount)',
      () async {
        final repo = RecordingInvoiceRepository(
          onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
        );
        final useCase = RegisterInvoiceUseCase(
          invoiceRepository: repo,
          customerRepository: okCustomerRepo,
        );

        final result = await useCase(
          RegisterInvoiceParams(
            id: 'inv-1',
            customerUuid: okCustomer.id,
            invoiceNumber: 'INV-001',
            issueDate: DateTime.utc(2026, 1, 1),
            // double.nan is the only way to inject NaN here; the use
            // case rejects before delegating to the repository.
            totalAmount: double.nan,
          ),
        );
        expect(result.isLeft, isTrue);
        final failure =
            (result as Left<InvoiceFailure, InvoiceOperationOutcome>).value;
        expect(failure, isA<InvoiceValidationFailure>());
        expect((failure as InvoiceValidationFailure).field, 'totalAmount');
        expect(repo.created, isEmpty);
      },
    );

    test('CustomerMissingFailure when FK does not resolve', () async {
      final repo = RecordingInvoiceRepository(
        onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final emptyCustomerRepo = RecordingCustomerRepository();
      final useCase = RegisterInvoiceUseCase(
        invoiceRepository: repo,
        customerRepository: emptyCustomerRepo,
      );

      final result = await useCase(baseParams());
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<InvoiceFailure, InvoiceOperationOutcome>).value;
      expect(failure, isA<InvoiceCustomerMissingFailure>());
      expect((failure as InvoiceCustomerMissingFailure).reason, 'notFound');
      expect(repo.created, isEmpty);
    });

    test('valid input → delegates to the repository unchanged', () async {
      final repo = RecordingInvoiceRepository(
        onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final useCase = RegisterInvoiceUseCase(
        invoiceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final result = await useCase(baseParams());
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<InvoiceFailure, InvoiceOperationOutcome>).value;
      expect(outcome.invoice.invoiceNumber, 'INV-001');
      expect(outcome.invoice.customerUuid, okCustomer.id);
      expect(outcome.invoice.totalAmount, 1_000_000.0);
      expect(repo.created, hasLength(1));
      expect(repo.created.single.id, 'inv-1');
      expect(outcome.warnings, isEmpty);
    });

    test('future-dated issueDate → emits a warning (not a failure)', () async {
      final repo = RecordingInvoiceRepository(
        onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final useCase = RegisterInvoiceUseCase(
        invoiceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final future = DateTime.now().add(const Duration(days: 30));
      final result = await useCase(baseParams(issueDate: future));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<InvoiceFailure, InvoiceOperationOutcome>).value;
      expect(outcome.invoice.issueDate, future);
      expect(outcome.warnings, hasLength(1));
      expect(outcome.warnings.single.field, 'issueDate');
      expect(outcome.warnings.single.message, contains('future'));
    });

    test('past-dated issueDate → no warning', () async {
      final repo = RecordingInvoiceRepository(
        onCreate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final useCase = RegisterInvoiceUseCase(
        invoiceRepository: repo,
        customerRepository: okCustomerRepo,
      );

      final past = DateTime.now().subtract(const Duration(days: 1));
      final result = await useCase(baseParams(issueDate: past));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<InvoiceFailure, InvoiceOperationOutcome>).value;
      expect(outcome.warnings, isEmpty);
    });

    test(
      'Repository.storage failure propagates with operation=createInvoice',
      () async {
        const failure = InvoiceStorageFailure(
          operation: 'createInvoice',
          message: 'simulated',
        );
        final repo = RecordingInvoiceRepository(
          onCreate: (_) => const Left<InvoiceFailure, InvoiceEntity>(failure),
        );
        final useCase = RegisterInvoiceUseCase(
          invoiceRepository: repo,
          customerRepository: okCustomerRepo,
        );

        final result = await useCase(baseParams());
        expect(result.isLeft, isTrue);
        expect(
          (result as Left<InvoiceFailure, InvoiceOperationOutcome>).value,
          same(failure),
        );
      },
    );
  });
}
