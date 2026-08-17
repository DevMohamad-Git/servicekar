import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/either.dart';
import 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
import 'package:servicar/features/invoice/domain/failures/invoice_failure.dart';
import 'package:servicar/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:servicar/features/invoice/domain/usecases/params/update_invoice_params.dart';
import 'package:servicar/features/invoice/domain/usecases/update_invoice_usecase.dart';
import 'package:servicar/features/invoice/domain/value_models/invoice_operation_outcome.dart';

/// Recording fake of [InvoiceRepository] — only `updateInvoice` is
/// exercised by these tests.
class RecordingInvoiceRepository implements InvoiceRepository {
  final List<InvoiceEntity> updated = [];
  final Either<InvoiceFailure, InvoiceEntity> Function(InvoiceEntity)
  onUpdate;

  RecordingInvoiceRepository({required this.onUpdate});

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> updateInvoice(
    InvoiceEntity invoice,
  ) async {
    updated.add(invoice);
    return onUpdate(invoice);
  }

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> createInvoice(
    InvoiceEntity i,
  ) async => throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, Unit>> deleteInvoice(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<InvoiceFailure, InvoiceEntity>> getById(
    String id,
  ) async => throw UnimplementedError();

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

void main() {
  UpdateInvoiceParams baseParams({
    String invoiceNumber = 'INV-001',
    double totalAmount = 1_000_000.0,
    DateTime? issueDate,
  }) => UpdateInvoiceParams(
    id: 'inv-1',
    customerUuid: 'cust-1',
    invoiceNumber: invoiceNumber,
    issueDate: issueDate ?? DateTime.utc(2026, 1, 1),
    totalAmount: totalAmount,
  );

  group('UpdateInvoiceUseCase — validation gates', () {
    test(
      'empty invoiceNumber → InvoiceValidationFailure(field=invoiceNumber)',
      () async {
        final repo = RecordingInvoiceRepository(
          onUpdate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
        );
        final useCase = UpdateInvoiceUseCase(repo);

        final result = await useCase(baseParams(invoiceNumber: '   '));
        expect(result.isLeft, isTrue);
        final failure =
            (result as Left<InvoiceFailure, InvoiceOperationOutcome>)
                .value;
        expect(failure, isA<InvoiceValidationFailure>());
        expect(
          (failure as InvoiceValidationFailure).field,
          'invoiceNumber',
        );
        expect(repo.updated, isEmpty);
      },
    );

    test(
      'negative totalAmount → InvoiceValidationFailure(field=totalAmount)',
      () async {
        final repo = RecordingInvoiceRepository(
          onUpdate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
        );
        final useCase = UpdateInvoiceUseCase(repo);

        final result = await useCase(baseParams(totalAmount: -1.0));
        expect(result.isLeft, isTrue);
        final failure =
            (result as Left<InvoiceFailure, InvoiceOperationOutcome>)
                .value;
        expect(failure, isA<InvoiceValidationFailure>());
        expect((failure as InvoiceValidationFailure).field, 'totalAmount');
        expect(repo.updated, isEmpty);
      },
    );

    test('zero totalAmount is accepted (zero-invoice per the brief)',
        () async {
      final repo = RecordingInvoiceRepository(
        onUpdate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final useCase = UpdateInvoiceUseCase(repo);

      final result = await useCase(baseParams(totalAmount: 0.0));
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<InvoiceFailure, InvoiceOperationOutcome>)
              .value;
      expect(outcome.invoice.totalAmount, 0.0);
      expect(outcome.warnings, isEmpty);
      expect(repo.updated.single.totalAmount, 0.0);
    });

    test('empty id → InvoiceValidationFailure(field=id)', () async {
      final repo = RecordingInvoiceRepository(
        onUpdate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final useCase = UpdateInvoiceUseCase(repo);

      final params = UpdateInvoiceParams(
        id: '   ',
        customerUuid: 'cust-1',
        invoiceNumber: 'INV-001',
        issueDate: DateTime.utc(2026, 1, 1),
      );
      final result = await useCase(params);
      expect(result.isLeft, isTrue);
      final failure =
          (result as Left<InvoiceFailure, InvoiceOperationOutcome>).value;
      expect(failure, isA<InvoiceValidationFailure>());
      expect((failure as InvoiceValidationFailure).field, 'id');
      expect(repo.updated, isEmpty);
    });

    test('valid input → delegates to the repository unchanged',
        () async {
      final repo = RecordingInvoiceRepository(
        onUpdate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
      );
      final useCase = UpdateInvoiceUseCase(repo);

      final result = await useCase(baseParams());
      expect(result.isRight, isTrue);
      final outcome =
          (result as Right<InvoiceFailure, InvoiceOperationOutcome>)
              .value;
      expect(outcome.invoice.invoiceNumber, 'INV-001');
      expect(outcome.invoice.customerUuid, 'cust-1');
      expect(repo.updated, hasLength(1));
      expect(repo.updated.single.id, 'inv-1');
      expect(outcome.warnings, isEmpty);
    });

    test(
      'future-dated issueDate → emits a warning (not a failure)',
      () async {
        final repo = RecordingInvoiceRepository(
          onUpdate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
        );
        final useCase = UpdateInvoiceUseCase(repo);

        final future = DateTime.now().add(const Duration(days: 30));
        final result = await useCase(baseParams(issueDate: future));
        expect(result.isRight, isTrue);
        final outcome =
            (result as Right<InvoiceFailure, InvoiceOperationOutcome>)
                .value;
        expect(outcome.invoice.issueDate, future);
        expect(outcome.warnings, hasLength(1));
        expect(outcome.warnings.single.field, 'issueDate');
        expect(outcome.warnings.single.message, contains('future'));
      },
    );

    test(
      'Repository.storage failure propagates with operation=updateInvoice',
      () async {
        const failure = InvoiceStorageFailure(
          operation: 'updateInvoice',
          message: 'simulated',
        );
        final repo = RecordingInvoiceRepository(
          onUpdate: (_) => const Left<InvoiceFailure, InvoiceEntity>(failure),
        );
        final useCase = UpdateInvoiceUseCase(repo);

        final result = await useCase(baseParams());
        expect(result.isLeft, isTrue);
        expect(
          (result as Left<InvoiceFailure, InvoiceOperationOutcome>).value,
          same(failure),
        );
      },
    );

    test(
      'Update does NOT re-verify customer existence (trusts FK)',
      () async {
        // The repo is configured to succeed *unconditionally* and
        // we pass a customerUuid that no real customer row can
        // resolve against. The use case accepts the FK verbatim
        // because the original register already gated on it; the
        // customer-repository fake is intentionally NEVER asked.
        final repo = RecordingInvoiceRepository(
          onUpdate: (i) => Right<InvoiceFailure, InvoiceEntity>(i),
        );
        final useCase = UpdateInvoiceUseCase(repo);

        final params = UpdateInvoiceParams(
          id: 'inv-1',
          customerUuid: 'cust-does-not-exist-anywhere',
          invoiceNumber: 'INV-001',
          issueDate: DateTime.utc(2026, 1, 1),
        );
        final result = await useCase(params);
        expect(result.isRight, isTrue);
        expect(
          (result as Right<InvoiceFailure, InvoiceOperationOutcome>)
              .value
              .invoice
              .customerUuid,
          'cust-does-not-exist-anywhere',
        );
        expect(repo.updated, hasLength(1));
      },
    );
  });
}
