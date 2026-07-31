import '../entities/balance_status.dart';

/// Pure-Dart value object returned by
/// [CalculateCustomerBalanceUseCase].
///
/// Carries the raw derived totals alongside the resolved
/// [BalanceStatus] so the UI does not have to re-run the
/// classification. The two totals are exposed separately so
/// dashboards can show "you owe 1,200,000 / paid 800,000" without
/// violating the "no balance stored on Customer/Invoice/Payment"
/// rule — those numbers live here, computed once per query.
class CustomerBalanceResult {
  const CustomerBalanceResult({
    required this.customerUuid,
    required this.invoicesTotal,
    required this.paymentsTotal,
    required this.balance,
    required this.status,
    required this.invoiceCount,
    required this.paymentCount,
  });

  /// FK copied from the input — useful for cascading UI caches
  /// keyed by customer.
  final String customerUuid;

  /// Sum of all `invoice.totalAmount` for this customer at read
  /// time. Positive.
  final double invoicesTotal;

  /// Sum of all `payment.amount` for this customer at read time.
  /// Positive (per the "amount >= 0" rule on RegisterPayment).
  final double paymentsTotal;

  /// `paymentsTotal - invoicesTotal`. < 0 → debtor, == 0 →
  /// settled, > 0 → creditor.
  final double balance;

  /// Status derived from [balance] via [BalanceClassifier].
  final BalanceStatus status;

  /// Number of invoice rows that composed [invoicesTotal]. Exposed
  /// for UI affordances ("12 open invoices") and tests.
  final int invoiceCount;

  /// Number of payment rows that composed [paymentsTotal]. Exposed
  /// for UI affordances ("8 payments received") and tests.
  final int paymentCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerBalanceResult &&
          other.customerUuid == customerUuid &&
          other.invoicesTotal == invoicesTotal &&
          other.paymentsTotal == paymentsTotal &&
          other.balance == balance &&
          other.status == status &&
          other.invoiceCount == invoiceCount &&
          other.paymentCount == paymentCount);

  @override
  int get hashCode => Object.hash(
    customerUuid,
    invoicesTotal,
    paymentsTotal,
    balance,
    status,
    invoiceCount,
    paymentCount,
  );

  @override
  String toString() =>
      'CustomerBalanceResult('
      'customer: $customerUuid, '
      'invoices: $invoicesTotal × $invoiceCount, '
      'payments: $paymentsTotal × $paymentCount, '
      'balance: $balance, '
      'status: ${status.label})';
}
