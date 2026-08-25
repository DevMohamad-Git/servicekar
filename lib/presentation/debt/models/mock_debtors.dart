/// UI-only mock data for the debtors-list page.
///
/// Deliberately separate from the domain layer: the page is UI-first
/// and must not depend on Isar entities, repositories or balance
/// calculation. When the Logic/Data phase lands, this file is replaced
/// by a real presentation model mapped from the owning feature —
/// nothing else in the page should change.
library;

/// Presentation model for one debtor row on the debtors page.
class MockDebtor {
  const MockDebtor({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.debtAmount,
    required this.lastServiceDate,
  });

  /// Stable identifier (also used as the selection key).
  final String id;

  final String fullName;
  final String phoneNumber;

  /// Outstanding amount in Toman (always positive here).
  final double debtAmount;

  final DateTime lastServiceDate;
}

/// Pre-built mock debtors shown in the list. Amounts are chosen so the
/// default «بیشترین بدهی» ordering visibly differs from «کمترین بدهی».
final List<MockDebtor> mockDebtors = <MockDebtor>[
  MockDebtor(
    id: 'customer-4',
    fullName: 'حسین یوسفی',
    phoneNumber: '09012345678',
    debtAmount: 5400000,
    lastServiceDate: DateTime.now().subtract(const Duration(days: 33)),
  ),
  MockDebtor(
    id: 'customer-1',
    fullName: 'علی رضایی',
    phoneNumber: '09121234567',
    debtAmount: 2450000,
    lastServiceDate: DateTime.now().subtract(const Duration(days: 15)),
  ),
  MockDebtor(
    id: 'customer-6',
    fullName: 'رضا کریمی',
    phoneNumber: '09121112233',
    debtAmount: 1750000,
    lastServiceDate: DateTime.now().subtract(const Duration(days: 6)),
  ),
  MockDebtor(
    id: 'customer-3',
    fullName: 'سارا محمدی',
    phoneNumber: '09198765432',
    debtAmount: 1200000,
    lastServiceDate: DateTime.now().subtract(const Duration(days: 60)),
  ),
  MockDebtor(
    id: 'customer-2',
    fullName: 'محمد احمدی',
    phoneNumber: '09359876543',
    debtAmount: 850000,
    lastServiceDate: DateTime.now().subtract(const Duration(days: 90)),
  ),
  MockDebtor(
    id: 'customer-5',
    fullName: 'مرضیه حسینی',
    phoneNumber: '09301112233',
    debtAmount: 320000,
    lastServiceDate: DateTime.now().subtract(const Duration(days: 120)),
  ),
];
