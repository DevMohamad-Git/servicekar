import '../../../../customer/domain/entities/payment_entity.dart';

/// Parameter model for [UpdatePaymentUseCase.call].
///
/// Carries the full payment snapshot to replay through the
/// repository. The matching `id` is required because it's the
/// repository's lookup key. Same validation rules as
/// [RegisterPaymentParams].
class UpdatePaymentParams {
  const UpdatePaymentParams({
    required this.id,
    required this.customerUuid,
    required this.amount,
    required this.paidAt,
    this.invoiceUuid,
    this.method = PaymentMethod.cash,
    this.note,
  });

  /// Business-stable identifier. Required — the repository key.
  final String id;

  /// FK to [CustomerEntity.id]. The use case does NOT re-verify
  /// the customer exists here (the original register already did)
  /// — update is allowed to rename / re-categorize payments
  /// without touching the FK.
  final String customerUuid;

  /// Optional FK to [InvoiceEntity.id]. May now be null on
  /// update (detaching a payment from its invoice, e.g. after
  /// the invoice was voided) or non-null (re-attaching it).
  /// Whatever is supplied must, if non-null, exist in storage —
  /// the use case verifies it.
  final String? invoiceUuid;

  /// Revised [PaymentEntity.amount]. Must be ≥ 0.
  final double amount;

  /// Revised [PaymentEntity.paidAt]. Must be non-null and not in
  /// the future.
  final DateTime paidAt;

  /// Revised [PaymentEntity.method].
  final PaymentMethod method;

  /// Revised [PaymentEntity.note].
  final String? note;
}
