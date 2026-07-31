/// Base type for every failure raised by the Balance feature.
///
/// `sealed` so the analyzer enforces exhaustive switches at the
/// call site. Domain layer is pure Dart — no Freezed/Riverpod/Isar
/// imports here.
sealed class BalanceFailure {
  const BalanceFailure();

  /// Human-readable message for logging / debug UIs.
  String get message;
}

/// The customer referenced by the balance lookup does not exist.
///
/// Distinct from any storage-side "we cannot read this right now"
/// because we have a clear yes/no on the row presence — the
/// parent lookup returned `CustomerNotFoundFailure` and we did
/// not propagate it for layering reasons.
final class BalanceCustomerUnknownFailure extends BalanceFailure {
  const BalanceCustomerUnknownFailure({required this.customerUuid});

  final String customerUuid;

  @override
  String get message =>
      'Cannot compute balance for unknown customer: '
      '$customerUuid';
}

/// Underlying storage (Isar) failed to read the invoice totals for
/// the customer during balance derivation.
final class BalanceInvoiceLookupFailure extends BalanceFailure {
  const BalanceInvoiceLookupFailure({required this.detail});

  final String detail;

  @override
  String get message => 'Balance: failed to read invoice totals: $detail';
}

/// Underlying storage (Isar) failed to read the payment totals for
/// the customer during balance derivation.
final class BalancePaymentLookupFailure extends BalanceFailure {
  const BalancePaymentLookupFailure({required this.detail});

  final String detail;

  @override
  String get message => 'Balance: failed to read payment totals: $detail';
}
