/// Result category of a customer's financial balance.
///
/// Derived purely from the numeric balance
/// (`paymentsTotal - invoicesTotal`):
///
///   * balance  >  0 — the customer has paid MORE than the open
///                       invoices cover. The business owes the
///                       customer — `creditor`.
///   * balance  =  0 — the open invoices are exactly settled.
///                       `settled`.
///   * balance  <  0 — the customer still owes money against the
///                       open invoices. `debtor`.
///
/// The enum carries no numeric field because the *derived number*
/// is the canonical signal; placing it here is a UI-affordance
/// (`BalanceStatus.creditor` reads better than `balance > 0`).
enum BalanceStatus {
  debtor,
  settled,
  creditor;

  /// Human-readable English label. Localized at the presentation
  /// layer via `AppLocalizations`.
  String get label => switch (this) {
    BalanceStatus.debtor => 'Debtor',
    BalanceStatus.settled => 'Settled',
    BalanceStatus.creditor => 'Creditor',
  };
}

/// Pure-Dart classifier used by [CalculateCustomerBalanceUseCase].
///
/// A tiny epsilon (`1e-9`) absorbs the floating-point noise that
/// would otherwise turn `paymentsTotal == invoicesTotal` into
/// `creditor` on the last cent. Tests use round-totals so the
/// epsilon never flips the result, but production code faces
/// real-world cents/truncation.
class BalanceClassifier {
  const BalanceClassifier();

  /// Treat differences below [epsilon] as zero.
  static const double epsilon = 1e-9;

  /// Map a raw [balance] number to its [BalanceStatus].
  ///
  /// Returns [BalanceStatus.settled] when |balance| < [epsilon],
  /// [BalanceStatus.creditor] when strictly positive, and
  /// [BalanceStatus.debtor] when strictly negative.
  BalanceStatus classify(double balance) {
    if (balance.abs() < epsilon) return BalanceStatus.settled;
    return balance > 0 ? BalanceStatus.creditor : BalanceStatus.debtor;
  }
}
