/// Pure-Dart domain customer. Lives in the inner-most layer of Clean
/// Architecture: no Flutter, no Isar, no JSON, no I/O. Persisted via the
/// data layer's `CustomerModel` (see `data/mappers/customer_mapper.dart`).
///
/// This file intentionally does **not** use `@freezed`: the scaffold
/// defaults to plain immutable Dart so it can be analyzed and run
/// without `dart run build_runner build`. Once the project's
/// `analyzer ^9.0.0` vs. `json_serializable ^6.14.0` mismatch is
/// resolved (the build script currently fails to compile), migrate
/// to:
///
/// ```dart
/// @freezed
/// abstract class CustomerEntity with _$CustomerEntity {
///   const factory CustomerEntity({
///     required String id,
///     // ...
///   }) = _CustomerEntity;
/// }
/// ```
///
/// ─── Profile surface ───────────────────────────────────────────────
/// The "Customer Profile" is the central entity that the customer
/// detail screen will eventually render. The set of fields below is
/// the *minimum* required to support that screen without forcing a
/// second schema migration later:
///
///   * Required identity — [id], [fullName], [phoneNumber].
///   * Optional profile detail — [email], [address], [notes].
///   * Profile picture — [profileImagePath] (nullable; the avatar
///     surface reads the path at render time and never embeds bytes).
///   * Optional profile facts — [nationalId], [birthday], [gender]
///     ("male" / "female" / "other" for now; locked at the data
///     layer to a tiny enum-shaped String until i18n comes in).
///   * Operator-defined chips — [tags].
///   * Timestamps — [createdAt], [updatedAt].
///
/// ─── [balance] field ────────────────────────────────────────────────
/// `balance` was the project's first cached debt summary. The new DB
/// foundation derives the *real* debt as `sum(invoice.totalAmount) -
/// sum(payment.amount)` grouped by `customerUuid`; the cached field
/// is therefore stale-prone and is marked `@deprecated` so call sites
/// see the warning before they migrate. We intentionally do NOT delete
/// the field here because:
///   1. The repository, use cases, tests, and presentation widgets
///      (e.g. `customer_balance_widget.dart`) currently consume it.
///   2. The task scope is "design the DB foundation" — removing the
///      field would force touching the repo, the use cases, and at
///      least the dashboard widget, all of which are explicitly out
///      of scope per the task brief.
///
/// Future refactor (off-scope here): compute the derived debt in a
/// dedicated use case (`GetCustomerDebtUseCase`), delete this field,
/// and migrate every `customer.balance` callsite.
class CustomerEntity {
  const CustomerEntity({
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

  /// Stable identifier. UUID v4 is the recommended default; the data
  /// layer generates it when creating a new record.
  final String id;

  /// Display name (first + last, or company name).
  final String fullName;

  /// Primary phone number. Will normalize to E.164 once validation
  /// matures in the use-case layer.
  final String phoneNumber;

  /// Optional email address.
  final String? email;

  /// Optional postal address.
  final String? address;

  /// Optional free-form notes added by the operator.
  final String? notes;

  /// Optional profile-image reference.
  ///
  /// Stored as a *reference / path* — never as raw image bytes —
  /// per the project rule "Profile image should be stored as a
  /// reference/path, not as raw image bytes in the database." The
  /// reference is the OS-neutral *relative* path under the app's
  /// documents directory (e.g. `customers/<uuid>/avatar.jpg`) so
  /// future migrations between local-storage and remote-storage
  /// strategies don't tie the DB to a physical location.
  final String? profileImagePath;

  /// Optional national ID (government-issued number). Used by the
  /// profile header and any future KYC/KYB flow.
  final String? nationalId;

  /// Optional birthday, used for greetings / age band filters.
  final DateTime? birthday;

  /// Optional gender. Stored as a String ("male" / "female" / "other")
  /// to keep i18n push-button-switchable; a future feature will
  /// graduate it to a typed enum with localized labels.
  final String? gender;

  /// Outstanding balance owed by (or to) the customer, in the local
  /// currency. Positive = customer owes the business.
  ///
  /// @deprecated — see the class-level header for the migration plan.
  @Deprecated(
    'Derived from invoices/payments; this cached summary is '
    'stale-prone. Use the future GetCustomerDebtUseCase instead.',
  )
  final double balance;

  /// Operator-defined tags for grouping/filtering (e.g. `vip`, `cash`).
  /// Defensive-copied in [copyWith] so the entity stays immutable.
  final List<String> tags;

  /// Server or local persistence timestamp; null until persisted.
  final DateTime? createdAt;

  /// Last update timestamp; null until persisted.
  final DateTime? updatedAt;

  CustomerEntity copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    Object? email = _sentinel,
    Object? address = _sentinel,
    Object? notes = _sentinel,
    Object? profileImagePath = _sentinel,
    Object? nationalId = _sentinel,
    Object? birthday = _sentinel,
    Object? gender = _sentinel,
    Object? balance = _sentinel,
    List<String>? tags,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: identical(email, _sentinel) ? this.email : email as String?,
      address:
          identical(address, _sentinel) ? this.address : address as String?,
      notes: identical(notes, _sentinel) ? this.notes : notes as String?,
      profileImagePath: identical(profileImagePath, _sentinel)
          ? this.profileImagePath
          : profileImagePath as String?,
      nationalId: identical(nationalId, _sentinel)
          ? this.nationalId
          : nationalId as String?,
      birthday: identical(birthday, _sentinel)
          ? this.birthday
          : birthday as DateTime?,
      gender:
          identical(gender, _sentinel) ? this.gender : gender as String?,
      balance: identical(balance, _sentinel)
          ? this.balance
          : balance as double,
      tags: tags ?? this.tags,
      createdAt:
          identical(createdAt, _sentinel) ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          identical(updatedAt, _sentinel) ? this.updatedAt : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerEntity &&
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

  @override
  String toString() =>
      'CustomerEntity(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, '
      'balance: $balance, tags: $tags, profileImagePath: $profileImagePath)';
}

const Object _sentinel = Object();

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
