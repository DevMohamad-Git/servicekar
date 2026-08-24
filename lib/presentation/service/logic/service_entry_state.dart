/// UI-only mock data and form-state enums for the service-entry page.
///
/// These types are deliberately separate from the domain layer: the page
/// is UI-first and uses only local/mock state with no persistence.
library;

/// Service-type options shown in the dropdown.
enum ServiceType {
  periodic,
  repair,
  installation;

  String labelLocalized(String translation) => switch (this) {
    ServiceType.periodic => translation,
    ServiceType.repair => translation,
    ServiceType.installation => translation,
  };
}

/// Mock customer representation for the customer-selection section.
class MockCustomer {
  const MockCustomer({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  final String id;
  final String name;
  final String phoneNumber;
}

/// Pre-built mock customers shown in the selection list and search.
const List<MockCustomer> mockCustomers = <MockCustomer>[
  MockCustomer(id: 'customer-1', name: 'علی رضایی', phoneNumber: '09121234567'),
  MockCustomer(
    id: 'customer-2',
    name: 'محمد احمدی',
    phoneNumber: '09359876543',
  ),
  MockCustomer(
    id: 'customer-3',
    name: 'سارا محمدی',
    phoneNumber: '09198765432',
  ),
  MockCustomer(
    id: 'customer-4',
    name: 'حسین یوسفی',
    phoneNumber: '09012345678',
  ),
  MockCustomer(
    id: 'customer-5',
    name: 'مرضیه حسینی',
    phoneNumber: '09301112233',
  ),
  MockCustomer(id: 'customer-6', name: 'رضا کریمی', phoneNumber: '09121112233'),
];

/// All local form state for the service-entry page.
class ServiceEntryFormState {
  ServiceEntryFormState({
    this.selectedCustomer,
    this.serviceType,
    this.description,
    this.serviceFee,
    this.partsFee,
    this.serviceDate,
    this.reminderEnabled = false,
    this.nextServiceDate,
    this.photos = const [],
  });

  MockCustomer? selectedCustomer;
  ServiceType? serviceType;
  String? description;
  String? serviceFee;
  String? partsFee;
  DateTime? serviceDate;
  bool reminderEnabled;
  DateTime? nextServiceDate;
  List<MockServicePhoto> photos;

  /// Whether the form has enough data to submit.
  ///
  /// All of the following are required before the submit button lights up:
  ///   * A customer is selected;
  ///   * A service fee (هزینه اجرت) is entered;
  ///   * A parts fee (هزینه قطعات) is entered;
  ///   * A service date is picked.
  bool get canSubmit =>
      selectedCustomer != null &&
      serviceFee != null &&
      serviceFee!.trim().isNotEmpty &&
      partsFee != null &&
      partsFee!.trim().isNotEmpty &&
      serviceDate != null;
}

/// Service photo captured/picked through image_picker.
class MockServicePhoto {
  const MockServicePhoto({required this.id, this.path});

  final String id;

  /// Local file path returned by the picker; null only for placeholder
  /// previews in tests.
  final String? path;

  bool get hasImage => path != null && path!.trim().isNotEmpty;
}

/// Page-level submission state.
enum ServiceEntrySubmitState { idle, submitting, success, error }
