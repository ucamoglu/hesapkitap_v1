// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_statement_adjustment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreditCardStatementAdjustmentCollection on Isar {
  IsarCollection<CreditCardStatementAdjustment>
      get creditCardStatementAdjustments => this.collection();
}

const CreditCardStatementAdjustmentSchema = CollectionSchema(
  name: r'CreditCardStatementAdjustment',
  id: 1937063126427908130,
  properties: {
    r'adjustmentDate': PropertySchema(
      id: 0,
      name: r'adjustmentDate',
      type: IsarType.dateTime,
    ),
    r'amount': PropertySchema(
      id: 1,
      name: r'amount',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'creditCardAccountId': PropertySchema(
      id: 3,
      name: r'creditCardAccountId',
      type: IsarType.long,
    ),
    r'creditCardStatementId': PropertySchema(
      id: 4,
      name: r'creditCardStatementId',
      type: IsarType.long,
    ),
    r'direction': PropertySchema(
      id: 5,
      name: r'direction',
      type: IsarType.string,
    ),
    r'financeTransactionId': PropertySchema(
      id: 6,
      name: r'financeTransactionId',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 7,
      name: r'note',
      type: IsarType.string,
    )
  },
  estimateSize: _creditCardStatementAdjustmentEstimateSize,
  serialize: _creditCardStatementAdjustmentSerialize,
  deserialize: _creditCardStatementAdjustmentDeserialize,
  deserializeProp: _creditCardStatementAdjustmentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _creditCardStatementAdjustmentGetId,
  getLinks: _creditCardStatementAdjustmentGetLinks,
  attach: _creditCardStatementAdjustmentAttach,
  version: '3.1.0+1',
);

int _creditCardStatementAdjustmentEstimateSize(
  CreditCardStatementAdjustment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.direction.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _creditCardStatementAdjustmentSerialize(
  CreditCardStatementAdjustment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.adjustmentDate);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.creditCardAccountId);
  writer.writeLong(offsets[4], object.creditCardStatementId);
  writer.writeString(offsets[5], object.direction);
  writer.writeLong(offsets[6], object.financeTransactionId);
  writer.writeString(offsets[7], object.note);
}

CreditCardStatementAdjustment _creditCardStatementAdjustmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreditCardStatementAdjustment();
  object.adjustmentDate = reader.readDateTime(offsets[0]);
  object.amount = reader.readDouble(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.creditCardAccountId = reader.readLong(offsets[3]);
  object.creditCardStatementId = reader.readLong(offsets[4]);
  object.direction = reader.readString(offsets[5]);
  object.financeTransactionId = reader.readLongOrNull(offsets[6]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[7]);
  return object;
}

P _creditCardStatementAdjustmentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creditCardStatementAdjustmentGetId(CreditCardStatementAdjustment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creditCardStatementAdjustmentGetLinks(
    CreditCardStatementAdjustment object) {
  return [];
}

void _creditCardStatementAdjustmentAttach(
    IsarCollection<dynamic> col, Id id, CreditCardStatementAdjustment object) {
  object.id = id;
}

extension CreditCardStatementAdjustmentQueryWhereSort on QueryBuilder<
    CreditCardStatementAdjustment, CreditCardStatementAdjustment, QWhere> {
  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CreditCardStatementAdjustmentQueryWhere on QueryBuilder<
    CreditCardStatementAdjustment,
    CreditCardStatementAdjustment,
    QWhereClause> {
  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

extension CreditCardStatementAdjustmentQueryFilter on QueryBuilder<
    CreditCardStatementAdjustment,
    CreditCardStatementAdjustment,
    QFilterCondition> {
  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> adjustmentDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adjustmentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> adjustmentDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'adjustmentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> adjustmentDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'adjustmentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> adjustmentDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'adjustmentDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditCardAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardAccountIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creditCardAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardAccountIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creditCardAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardAccountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creditCardAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardStatementIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditCardStatementId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardStatementIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creditCardStatementId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardStatementIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creditCardStatementId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> creditCardStatementIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creditCardStatementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'direction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
          QAfterFilterCondition>
      directionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
          QAfterFilterCondition>
      directionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'direction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direction',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> directionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'direction',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> financeTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financeTransactionId',
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> financeTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financeTransactionId',
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> financeTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financeTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> financeTransactionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'financeTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> financeTransactionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'financeTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> financeTransactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'financeTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
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

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }
}

extension CreditCardStatementAdjustmentQueryObject on QueryBuilder<
    CreditCardStatementAdjustment,
    CreditCardStatementAdjustment,
    QFilterCondition> {}

extension CreditCardStatementAdjustmentQueryLinks on QueryBuilder<
    CreditCardStatementAdjustment,
    CreditCardStatementAdjustment,
    QFilterCondition> {}

extension CreditCardStatementAdjustmentQuerySortBy on QueryBuilder<
    CreditCardStatementAdjustment, CreditCardStatementAdjustment, QSortBy> {
  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByAdjustmentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByAdjustmentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentDate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByCreditCardAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByCreditCardStatementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByCreditCardStatementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension CreditCardStatementAdjustmentQuerySortThenBy on QueryBuilder<
    CreditCardStatementAdjustment, CreditCardStatementAdjustment, QSortThenBy> {
  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByAdjustmentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByAdjustmentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustmentDate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByCreditCardAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByCreditCardStatementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByCreditCardStatementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension CreditCardStatementAdjustmentQueryWhereDistinct on QueryBuilder<
    CreditCardStatementAdjustment, CreditCardStatementAdjustment, QDistinct> {
  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByAdjustmentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adjustmentDate');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creditCardAccountId');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByCreditCardStatementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creditCardStatementId');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByDirection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financeTransactionId');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, CreditCardStatementAdjustment,
      QDistinct> distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }
}

extension CreditCardStatementAdjustmentQueryProperty on QueryBuilder<
    CreditCardStatementAdjustment,
    CreditCardStatementAdjustment,
    QQueryProperty> {
  QueryBuilder<CreditCardStatementAdjustment, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, DateTime, QQueryOperations>
      adjustmentDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adjustmentDate');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, double, QQueryOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, int, QQueryOperations>
      creditCardAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creditCardAccountId');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, int, QQueryOperations>
      creditCardStatementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creditCardStatementId');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, String, QQueryOperations>
      directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, int?, QQueryOperations>
      financeTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financeTransactionId');
    });
  }

  QueryBuilder<CreditCardStatementAdjustment, String?, QQueryOperations>
      noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }
}
