/// Storage-layer representation of a customer.
///
/// Mirrors `CustomerEntity` field-for-field so the mapper stays trivial.
/// Lives at the data-layer boundary — never import this from domain or
/// presentation code.
///
/// Like the entity, this class avoids `@freezed` for now so the
/// scaffold compiles without codegen. See `customer_entity.dart` for
/// the migration recipe.
///
/// The Isar collection lives in `customer_isar.dart` and its
/// `Model ↔ Isar` converters live in
/// `lib/features/customer/data/mappers/customer_isar_mapper.dart`.
///
/// ─── Profile surface (mirrors [CustomerEntity]) ─────────────────
/// `profileImagePath`, `nationalId`, `birthday`, `gender` mirror the
/// entity's profile fields so the data layer swallows them as-is.
/// `balance` is preserved-with-deprecation for the same reason
/// documented on [CustomerEntity] — see that file for the migration
/// plan.
class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.notes,
    this.profileImagePath,
    this.nationalId,
    this.birthday,
    this.gender,
    @Deprecated(
      'Derived from invoices/payments; this cached summary is '
      'stale-prone. Use the future GetCustomerDebtUseCase instead.',
    )
    this.balance = 0.0,
    this.tags = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? notes;
  final String? profileImagePath;
  final String? nationalId;
  final DateTime? birthday;
  final String? gender;

  /// @deprecated — see class header for the migration plan.
  @Deprecated(
    'Derived from invoices/payments; this cached summary is '
    'stale-prone. Use the future GetCustomerDebtUseCase instead.',
  )
  final double balance;

  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerModel &&
        other.id == id &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.address == address &&
        other.notes == notes &&
        other.profileImagePath == profileImagePath &&
        other.nationalId == nationalId &&
        other.birthday == birthday &&
        other.gender == gender &&
        other.balance == balance &&
        _listEq(other.tags, tags) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        fullName,
        phoneNumber,
        email,
        address,
        notes,
        profileImagePath,
        nationalId,
        birthday,
        gender,
        balance,
        Object.hashAll(tags),
        createdAt,
        updatedAt,
      );
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
