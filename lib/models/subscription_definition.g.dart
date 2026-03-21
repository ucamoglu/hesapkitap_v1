// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_definition.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubscriptionDefinitionCollection on Isar {
  IsarCollection<SubscriptionDefinition> get subscriptionDefinitions =>
      this.collection();
}

const SubscriptionDefinitionSchema = CollectionSchema(
  name: r'SubscriptionDefinition',
  id: -6870450413793725790,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'defaultExpenseCategoryId': PropertySchema(
      id: 1,
      name: r'defaultExpenseCategoryId',
      type: IsarType.long,
    ),
    r'dueDay': PropertySchema(
      id: 2,
      name: r'dueDay',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 3,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isAutoPay': PropertySchema(
      id: 4,
      name: r'isAutoPay',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'note': PropertySchema(
      id: 6,
      name: r'note',
      type: IsarType.string,
    ),
    r'paymentAccountId': PropertySchema(
      id: 7,
      name: r'paymentAccountId',
      type: IsarType.long,
    ),
    r'providerName': PropertySchema(
      id: 8,
      name: r'providerName',
      type: IsarType.string,
    ),
    r'subscriberNumber': PropertySchema(
      id: 9,
      name: r'subscriberNumber',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 10,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _subscriptionDefinitionEstimateSize,
  serialize: _subscriptionDefinitionSerialize,
  deserialize: _subscriptionDefinitionDeserialize,
  deserializeProp: _subscriptionDefinitionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _subscriptionDefinitionGetId,
  getLinks: _subscriptionDefinitionGetLinks,
  attach: _subscriptionDefinitionAttach,
  version: '3.1.0+1',
);

int _subscriptionDefinitionEstimateSize(
  SubscriptionDefinition object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.providerName.length * 3;
  {
    final value = object.subscriberNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _subscriptionDefinitionSerialize(
  SubscriptionDefinition object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.defaultExpenseCategoryId);
  writer.writeLong(offsets[2], object.dueDay);
  writer.writeBool(offsets[3], object.isActive);
  writer.writeBool(offsets[4], object.isAutoPay);
  writer.writeString(offsets[5], object.name);
  writer.writeString(offsets[6], object.note);
  writer.writeLong(offsets[7], object.paymentAccountId);
  writer.writeString(offsets[8], object.providerName);
  writer.writeString(offsets[9], object.subscriberNumber);
  writer.writeString(offsets[10], object.type);
  writer.writeDateTime(offsets[11], object.updatedAt);
}

SubscriptionDefinition _subscriptionDefinitionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubscriptionDefinition();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.defaultExpenseCategoryId = reader.readLongOrNull(offsets[1]);
  object.dueDay = reader.readLongOrNull(offsets[2]);
  object.id = id;
  object.isActive = reader.readBool(offsets[3]);
  object.isAutoPay = reader.readBool(offsets[4]);
  object.name = reader.readString(offsets[5]);
  object.note = reader.readStringOrNull(offsets[6]);
  object.paymentAccountId = reader.readLongOrNull(offsets[7]);
  object.providerName = reader.readString(offsets[8]);
  object.subscriberNumber = reader.readStringOrNull(offsets[9]);
  object.type = reader.readString(offsets[10]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[11]);
  return object;
}

P _subscriptionDefinitionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subscriptionDefinitionGetId(SubscriptionDefinition object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subscriptionDefinitionGetLinks(
    SubscriptionDefinition object) {
  return [];
}

void _subscriptionDefinitionAttach(
    IsarCollection<dynamic> col, Id id, SubscriptionDefinition object) {
  object.id = id;
}

extension SubscriptionDefinitionQueryWhereSort
    on QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QWhere> {
  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubscriptionDefinitionQueryWhere on QueryBuilder<
    SubscriptionDefinition, SubscriptionDefinition, QWhereClause> {
  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubscriptionDefinitionQueryFilter on QueryBuilder<
    SubscriptionDefinition, SubscriptionDefinition, QFilterCondition> {
  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> defaultExpenseCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'defaultExpenseCategoryId',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> defaultExpenseCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'defaultExpenseCategoryId',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> defaultExpenseCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultExpenseCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> defaultExpenseCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultExpenseCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> defaultExpenseCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultExpenseCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> defaultExpenseCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultExpenseCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> dueDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueDay',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> dueDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueDay',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> dueDayEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDay',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> dueDayGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDay',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> dueDayLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDay',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> dueDayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> isAutoPayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAutoPay',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> paymentAccountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentAccountId',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> paymentAccountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentAccountId',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> paymentAccountIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> paymentAccountIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> paymentAccountIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> paymentAccountIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      providerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      providerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> providerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subscriberNumber',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subscriberNumber',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriberNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subscriberNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subscriberNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subscriberNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subscriberNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subscriberNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      subscriberNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subscriberNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      subscriberNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subscriberNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriberNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> subscriberNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subscriberNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubscriptionDefinitionQueryObject on QueryBuilder<
    SubscriptionDefinition, SubscriptionDefinition, QFilterCondition> {}

extension SubscriptionDefinitionQueryLinks on QueryBuilder<
    SubscriptionDefinition, SubscriptionDefinition, QFilterCondition> {}

extension SubscriptionDefinitionQuerySortBy
    on QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QSortBy> {
  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByDefaultExpenseCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultExpenseCategoryId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByDefaultExpenseCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultExpenseCategoryId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByDueDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByDueDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByIsAutoPay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoPay', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByIsAutoPayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoPay', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByPaymentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortBySubscriberNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriberNumber', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortBySubscriberNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriberNumber', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SubscriptionDefinitionQuerySortThenBy on QueryBuilder<
    SubscriptionDefinition, SubscriptionDefinition, QSortThenBy> {
  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByDefaultExpenseCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultExpenseCategoryId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByDefaultExpenseCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultExpenseCategoryId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByDueDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByDueDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByIsAutoPay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoPay', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByIsAutoPayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoPay', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByPaymentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenBySubscriberNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriberNumber', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenBySubscriberNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriberNumber', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SubscriptionDefinitionQueryWhereDistinct
    on QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct> {
  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByDefaultExpenseCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultExpenseCategoryId');
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByDueDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDay');
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByIsAutoPay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAutoPay');
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentAccountId');
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByProviderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctBySubscriberNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscriberNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionDefinition, SubscriptionDefinition, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SubscriptionDefinitionQueryProperty on QueryBuilder<
    SubscriptionDefinition, SubscriptionDefinition, QQueryProperty> {
  QueryBuilder<SubscriptionDefinition, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubscriptionDefinition, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SubscriptionDefinition, int?, QQueryOperations>
      defaultExpenseCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultExpenseCategoryId');
    });
  }

  QueryBuilder<SubscriptionDefinition, int?, QQueryOperations>
      dueDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDay');
    });
  }

  QueryBuilder<SubscriptionDefinition, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<SubscriptionDefinition, bool, QQueryOperations>
      isAutoPayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAutoPay');
    });
  }

  QueryBuilder<SubscriptionDefinition, String, QQueryOperations>
      nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SubscriptionDefinition, String?, QQueryOperations>
      noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<SubscriptionDefinition, int?, QQueryOperations>
      paymentAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentAccountId');
    });
  }

  QueryBuilder<SubscriptionDefinition, String, QQueryOperations>
      providerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerName');
    });
  }

  QueryBuilder<SubscriptionDefinition, String?, QQueryOperations>
      subscriberNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscriberNumber');
    });
  }

  QueryBuilder<SubscriptionDefinition, String, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<SubscriptionDefinition, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
