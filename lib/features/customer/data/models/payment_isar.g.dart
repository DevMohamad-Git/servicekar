// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentIsarCollection on Isar {
  IsarCollection<PaymentIsar> get paymentIsars => this.collection();
}

const PaymentIsarSchema = CollectionSchema(
  name: r'PaymentIsar',
  id: 7428967737441487854,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.double),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customerUuid': PropertySchema(
      id: 2,
      name: r'customerUuid',
      type: IsarType.string,
    ),
    r'invoiceUuid': PropertySchema(
      id: 3,
      name: r'invoiceUuid',
      type: IsarType.string,
    ),
    r'method': PropertySchema(id: 4, name: r'method', type: IsarType.string),
    r'note': PropertySchema(id: 5, name: r'note', type: IsarType.string),
    r'paidAt': PropertySchema(id: 6, name: r'paidAt', type: IsarType.dateTime),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 8, name: r'uuid', type: IsarType.string),
  },

  estimateSize: _paymentIsarEstimateSize,
  serialize: _paymentIsarSerialize,
  deserialize: _paymentIsarDeserialize,
  deserializeProp: _paymentIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'customerUuid': IndexSchema(
      id: 1136510910109760869,
      name: r'customerUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'customerUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'invoiceUuid': IndexSchema(
      id: 5566660137320681830,
      name: r'invoiceUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'invoiceUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'paidAt': IndexSchema(
      id: -701685063105958775,
      name: r'paidAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paidAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _paymentIsarGetId,
  getLinks: _paymentIsarGetLinks,
  attach: _paymentIsarAttach,
  version: '3.3.2',
);

int _paymentIsarEstimateSize(
  PaymentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.customerUuid.length * 3;
  {
    final value = object.invoiceUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.method.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _paymentIsarSerialize(
  PaymentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.customerUuid);
  writer.writeString(offsets[3], object.invoiceUuid);
  writer.writeString(offsets[4], object.method);
  writer.writeString(offsets[5], object.note);
  writer.writeDateTime(offsets[6], object.paidAt);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeString(offsets[8], object.uuid);
}

PaymentIsar _paymentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentIsar();
  object.amount = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTimeOrNull(offsets[1]);
  object.customerUuid = reader.readString(offsets[2]);
  object.id = id;
  object.invoiceUuid = reader.readStringOrNull(offsets[3]);
  object.method = reader.readString(offsets[4]);
  object.note = reader.readStringOrNull(offsets[5]);
  object.paidAt = reader.readDateTime(offsets[6]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[7]);
  object.uuid = reader.readString(offsets[8]);
  return object;
}

P _paymentIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paymentIsarGetId(PaymentIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentIsarGetLinks(PaymentIsar object) {
  return [];
}

void _paymentIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  PaymentIsar object,
) {
  object.id = id;
}

extension PaymentIsarByIndex on IsarCollection<PaymentIsar> {
  Future<PaymentIsar?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  PaymentIsar? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<PaymentIsar?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<PaymentIsar?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(PaymentIsar object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(PaymentIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<PaymentIsar> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<PaymentIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension PaymentIsarQueryWhereSort
    on QueryBuilder<PaymentIsar, PaymentIsar, QWhere> {
  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhere> anyPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'paidAt'),
      );
    });
  }
}

extension PaymentIsarQueryWhere
    on QueryBuilder<PaymentIsar, PaymentIsar, QWhereClause> {
  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> uuidNotEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> customerUuidEqualTo(
    String customerUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'customerUuid',
          value: [customerUuid],
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause>
  customerUuidNotEqualTo(String customerUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'customerUuid',
                lower: [],
                upper: [customerUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'customerUuid',
                lower: [customerUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'customerUuid',
                lower: [customerUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'customerUuid',
                lower: [],
                upper: [customerUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause>
  invoiceUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'invoiceUuid', value: [null]),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause>
  invoiceUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'invoiceUuid',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> invoiceUuidEqualTo(
    String? invoiceUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'invoiceUuid',
          value: [invoiceUuid],
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause>
  invoiceUuidNotEqualTo(String? invoiceUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'invoiceUuid',
                lower: [],
                upper: [invoiceUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'invoiceUuid',
                lower: [invoiceUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'invoiceUuid',
                lower: [invoiceUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'invoiceUuid',
                lower: [],
                upper: [invoiceUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> paidAtEqualTo(
    DateTime paidAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'paidAt', value: [paidAt]),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> paidAtNotEqualTo(
    DateTime paidAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidAt',
                lower: [],
                upper: [paidAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidAt',
                lower: [paidAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidAt',
                lower: [paidAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidAt',
                lower: [],
                upper: [paidAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> paidAtGreaterThan(
    DateTime paidAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'paidAt',
          lower: [paidAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> paidAtLessThan(
    DateTime paidAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'paidAt',
          lower: [],
          upper: [paidAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterWhereClause> paidAtBetween(
    DateTime lowerPaidAt,
    DateTime upperPaidAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'paidAt',
          lower: [lowerPaidAt],
          includeLower: includeLower,
          upper: [upperPaidAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PaymentIsarQueryFilter
    on QueryBuilder<PaymentIsar, PaymentIsar, QFilterCondition> {
  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  createdAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  createdAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'customerUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'customerUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'customerUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'customerUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'customerUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'customerUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'customerUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'customerUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'customerUuid', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  customerUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'customerUuid', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'invoiceUuid'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'invoiceUuid'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'invoiceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'invoiceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'invoiceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'invoiceUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'invoiceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'invoiceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'invoiceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'invoiceUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'invoiceUuid', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  invoiceUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'invoiceUuid', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> methodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'method',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  methodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'method',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> methodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'method',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> methodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'method',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  methodStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'method',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> methodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'method',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> methodContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'method',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> methodMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'method',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  methodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'method', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  methodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'method', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> paidAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paidAt', value: value),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  paidAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paidAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> paidAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paidAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> paidAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paidAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension PaymentIsarQueryObject
    on QueryBuilder<PaymentIsar, PaymentIsar, QFilterCondition> {}

extension PaymentIsarQueryLinks
    on QueryBuilder<PaymentIsar, PaymentIsar, QFilterCondition> {}

extension PaymentIsarQuerySortBy
    on QueryBuilder<PaymentIsar, PaymentIsar, QSortBy> {
  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByCustomerUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerUuid', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy>
  sortByCustomerUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerUuid', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByInvoiceUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceUuid', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByInvoiceUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceUuid', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension PaymentIsarQuerySortThenBy
    on QueryBuilder<PaymentIsar, PaymentIsar, QSortThenBy> {
  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByCustomerUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerUuid', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy>
  thenByCustomerUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerUuid', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByInvoiceUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceUuid', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByInvoiceUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceUuid', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension PaymentIsarQueryWhereDistinct
    on QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> {
  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByCustomerUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByInvoiceUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'invoiceUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByMethod({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'method', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAt');
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<PaymentIsar, PaymentIsar, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension PaymentIsarQueryProperty
    on QueryBuilder<PaymentIsar, PaymentIsar, QQueryProperty> {
  QueryBuilder<PaymentIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentIsar, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PaymentIsar, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PaymentIsar, String, QQueryOperations> customerUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerUuid');
    });
  }

  QueryBuilder<PaymentIsar, String?, QQueryOperations> invoiceUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'invoiceUuid');
    });
  }

  QueryBuilder<PaymentIsar, String, QQueryOperations> methodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'method');
    });
  }

  QueryBuilder<PaymentIsar, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<PaymentIsar, DateTime, QQueryOperations> paidAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAt');
    });
  }

  QueryBuilder<PaymentIsar, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PaymentIsar, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
