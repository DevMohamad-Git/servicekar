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
class CustomerEntity {
  const CustomerEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.notes,
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

  /// Outstanding balance owed by (or to) the customer, in the local
  /// currency. Positive = customer owes the business.
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
    double? balance,
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
      balance: balance ?? this.balance,
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
        balance,
        Object.hashAll(tags),
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'CustomerEntity(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, '
      'balance: $balance, tags: $tags)';
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
