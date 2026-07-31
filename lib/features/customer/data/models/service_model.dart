/// Storage-layer representation of a Service.
///
/// Mirrors `ServiceEntity` field-for-field so the mapper stays trivial.
/// Lives at the data-layer boundary — never import this from domain or
/// presentation code.
///
/// See `service_entity.dart` for the linking strategy
/// (String-FK `customerUuid`) and the Status-as-String wire mapping.
///
/// See `service_isar.dart` for the Isar collection and the registered
/// indexes.
class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.customerUuid,
    required this.title,
    this.description,
    this.status = 'pending',
    this.price = 0.0,
    this.tags = const <String>[],
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerUuid;
  final String title;
  final String? description;

  /// Wire string for [ServiceEntity.status]. Kept as a String so
  /// `ServiceModel` has no domain import — see
  /// `service_entity.dart` for the enum / fromWire lookup.
  final String status;

  final double price;
  final List<String> tags;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel &&
        other.id == id &&
        other.customerUuid == customerUuid &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.price == price &&
        _listEq(other.tags, tags) &&
        other.startedAt == startedAt &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        customerUuid,
        title,
        description,
        status,
        price,
        Object.hashAll(tags),
        startedAt,
        completedAt,
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
