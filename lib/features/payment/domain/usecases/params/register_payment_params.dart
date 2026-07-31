import '../../../../customer/domain/entities/payment_entity.dart';

/// Parameter model for [RegisterPaymentUseCase.call].
///
/// Bundles every operator-supplied field required to register a
/// payment for an existing customer (and an optionally-referenced
/// invoice). Centralising the parameter shape keeps the use-case
/// signature stable as we add fields.
///
/// Mirrors the `service_providers.dart` parameter bundle pattern
/// for the Service feature.
class RegisterPaymentParams {
  const RegisterPaymentParams({
    required this.id,
    required this.customerUuid,
    required this.amount,
    required this.paidAt,
    this.invoiceUuid,
    this.method = PaymentMethod.cash,
    this.note,
  });

  /// Business-stable identifier. UUID v4 is the recommended
  /// default; the data layer round-trips it through
  /// `PaymentIsar.uuid`'s unique + `replace: true` index.
  final String id;

  /// FK to a [CustomerEntity.id]. Required: every Payment
  /// belongs to a Customer. The use case verifies the FK resolves
  /// at call time via [PaymentRepository].
  final String customerUuid;

  /// Optional FK to an [InvoiceEntity.id]. Required only for
  /// invoice-tied payments. **Optional** in this entity — a
  /// `null` invoiceUuid models the "on-account advance" payment
  /// documented on [PaymentEntity.invoiceUuid]. When supplied,
  /// the use case verifies the referenced invoice exists.
  final String? invoiceUuid;

  /// Non-negative cash value received. Use case rejects any
  /// negative value; `0.0` is accepted (the "free / complimentary"
  /// case — overpayment separately handled by the balance
  /// derivation, never by rejecting the write here).
  final double amount;

  /// When the payment was *received*. Use case enforces
  /// `paidAt.isAfter(now)` → reject. Allows null? **No** —
  /// [PaymentEntity.paidAt] is `late` (required). We mirror that
  /// here.
  final DateTime paidAt;

  /// Channel of receipt. Defaults to cash (matches
  /// [PaymentEntity.method]).
  final PaymentMethod method;

  /// Optional operator note (e.g. "transfer ref 12345").
  final String? note;
}
