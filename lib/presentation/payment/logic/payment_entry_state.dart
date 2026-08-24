/// UI-only mock data and form state for the payment-entry page.
///
/// Mirrors `ServiceEntryFormState`: the page is UI-first and uses only
/// local/mock state with no persistence. Customers come from the same
/// [mockCustomers] list the service-entry page uses so both entry
/// screens share one selection flow.
library;

import '../../customer/widgets/customer_account_summary_widget.dart';
import '../../service/logic/service_entry_state.dart';
import '../../../../features/customer/domain/entities/payment_entity.dart';

/// All local form state for the payment-entry page.
class PaymentEntryFormState {
  PaymentEntryFormState({
    this.selectedCustomer,
    this.amount = 0,
    this.method = PaymentMethod.cash,
    this.trackingNumber,
    this.paymentDate,
    this.note,
  });

  MockCustomer? selectedCustomer;

  /// Raw integer amount in Toman — never a formatted presentation string.
  /// The comma-grouped text lives only in the text field's controller.
  int amount;

  PaymentMethod method;

  /// Optional transfer reference number; only meaningful when
  /// [method] is [PaymentMethod.card].
  String? trackingNumber;

  DateTime? paymentDate;
  String? note;

  /// Whether the form has enough data to submit:
  ///   * A customer is selected;
  ///   * A positive amount is entered;
  ///   * A payment date is picked.
  bool get canSubmit =>
      selectedCustomer != null && amount > 0 && paymentDate != null;
}

/// Page-level submission state.
enum PaymentEntrySubmitState { idle, submitting, success, error }

/// Mock account summary shown after a customer is selected.
///
/// Pure presentation placeholder for the real
/// `CalculateCustomerBalanceUseCase` wiring — it reuses the exact
/// presentation type (`CustomerAccountStatus`) that
/// `CustomerAccountSummaryWidget` renders on the customer details page,
/// so swapping in the live provider later changes no UI code here.
class MockCustomerBalance {
  const MockCustomerBalance({
    required this.status,
    required this.amount,
    required this.lastUpdated,
  });

  final CustomerAccountStatus status;

  /// Absolute outstanding amount in Toman (the [status] carries the
  /// direction).
  final double amount;

  final String lastUpdated;
}

/// Deterministic mock balances keyed by [MockCustomer.id], covering the
/// shared mock-customer list with one example per status.
const Map<String, MockCustomerBalance> _mockBalancesByCustomerId =
    <String, MockCustomerBalance>{
  'customer-1': MockCustomerBalance(
    status: CustomerAccountStatus.debtor,
    amount: 2500000,
    lastUpdated: 'امروز، ۹:۱۵',
  ),
  'customer-2': MockCustomerBalance(
    status: CustomerAccountStatus.settled,
    amount: 0,
    lastUpdated: 'دیروز، ۱۸:۴۰',
  ),
  'customer-3': MockCustomerBalance(
    status: CustomerAccountStatus.creditor,
    amount: 500000,
    lastUpdated: 'امروز، ۱۱:۳۰',
  ),
};

/// Returns the mock balance for a customer; unknown ids default to a
/// settled account so every entry in the shared list renders sanely.
MockCustomerBalance mockBalanceFor(MockCustomer customer) =>
    _mockBalancesByCustomerId[customer.id] ??
    const MockCustomerBalance(
      status: CustomerAccountStatus.settled,
      amount: 0,
      lastUpdated: 'امروز، ۹:۱۵',
    );
