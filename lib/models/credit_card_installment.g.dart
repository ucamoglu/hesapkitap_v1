// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_installment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreditCardInstallmentCollection on Isar {
  IsarCollection<CreditCardInstallment> get creditCardInstallments =>
      this.collection();
}

const CreditCardInstallmentSchema = CollectionSchema(
  name: r'CreditCardInstallment',
  id: -7534474541683013309,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'creditCardAccountId': PropertySchema(
      id: 2,
      name: r'creditCardAccountId',
      type: IsarType.long,
    ),
    r'dueDate': PropertySchema(
      id: 3,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'financeTransactionId': PropertySchema(
      id: 4,
      name: r'financeTransactionId',
      type: IsarType.long,
    ),
    r'installmentCount': PropertySchema(
      id: 5,
      name: r'installmentCount',
      type: IsarType.long,
    ),
    r'installmentDate': PropertySchema(
      id: 6,
      name: r'installmentDate',
      type: IsarType.dateTime,
    ),
    r'installmentNumber': PropertySchema(
      id: 7,
      name: r'installmentNumber',
      type: IsarType.long,
    ),
    r'investmentTransactionId': PropertySchema(
      id: 8,
      name: r'investmentTransactionId',
      type: IsarType.long,
    ),
    r'statementDate': PropertySchema(
      id: 9,
      name: r'statementDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _creditCardInstallmentEstimateSize,
  serialize: _creditCardInstallmentSerialize,
  deserialize: _creditCardInstallmentDeserialize,
  deserializeProp: _creditCardInstallmentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _creditCardInstallmentGetId,
  getLinks: _creditCardInstallmentGetLinks,
  attach: _creditCardInstallmentAttach,
  version: '3.1.0+1',
);

int _creditCardInstallmentEstimateSize(
  CreditCardInstallment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _creditCardInstallmentSerialize(
  CreditCardInstallment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.creditCardAccountId);
  writer.writeDateTime(offsets[3], object.dueDate);
  writer.writeLong(offsets[4], object.financeTransactionId);
  writer.writeLong(offsets[5], object.installmentCount);
  writer.writeDateTime(offsets[6], object.installmentDate);
  writer.writeLong(offsets[7], object.installmentNumber);
  writer.writeLong(offsets[8], object.investmentTransactionId);
  writer.writeDateTime(offsets[9], object.statementDate);
}

CreditCardInstallment _creditCardInstallmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreditCardInstallment();
  object.amount = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.creditCardAccountId = reader.readLong(offsets[2]);
  object.dueDate = reader.readDateTime(offsets[3]);
  object.financeTransactionId = reader.readLongOrNull(offsets[4]);
  object.id = id;
  object.installmentCount = reader.readLong(offsets[5]);
  object.installmentDate = reader.readDateTime(offsets[6]);
  object.installmentNumber = reader.readLong(offsets[7]);
  object.investmentTransactionId = reader.readLongOrNull(offsets[8]);
  object.statementDate = reader.readDateTime(offsets[9]);
  return object;
}

P _creditCardInstallmentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creditCardInstallmentGetId(CreditCardInstallment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creditCardInstallmentGetLinks(
    CreditCardInstallment object) {
  return [];
}

void _creditCardInstallmentAttach(
    IsarCollection<dynamic> col, Id id, CreditCardInstallment object) {
  object.id = id;
}

extension CreditCardInstallmentQueryWhereSort
    on QueryBuilder<CreditCardInstallment, CreditCardInstallment, QWhere> {
  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CreditCardInstallmentQueryWhere on QueryBuilder<CreditCardInstallment,
    CreditCardInstallment, QWhereClause> {
  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterWhereClause>
      idBetween(
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

extension CreditCardInstallmentQueryFilter on QueryBuilder<
    CreditCardInstallment, CreditCardInstallment, QFilterCondition> {
  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> creditCardAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditCardAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> dueDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> dueDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> dueDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> dueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> financeTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financeTransactionId',
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> financeTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financeTransactionId',
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> financeTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financeTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
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

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installmentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installmentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installmentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installmentCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installmentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installmentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installmentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installmentDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installmentNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installmentNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installmentNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> installmentNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installmentNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> investmentTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'investmentTransactionId',
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> investmentTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'investmentTransactionId',
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> investmentTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investmentTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> investmentTransactionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'investmentTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> investmentTransactionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'investmentTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> investmentTransactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'investmentTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> statementDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> statementDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> statementDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment,
      QAfterFilterCondition> statementDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statementDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CreditCardInstallmentQueryObject on QueryBuilder<
    CreditCardInstallment, CreditCardInstallment, QFilterCondition> {}

extension CreditCardInstallmentQueryLinks on QueryBuilder<CreditCardInstallment,
    CreditCardInstallment, QFilterCondition> {}

extension CreditCardInstallmentQuerySortBy
    on QueryBuilder<CreditCardInstallment, CreditCardInstallment, QSortBy> {
  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByCreditCardAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInstallmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentCount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInstallmentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentCount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInstallmentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInstallmentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentDate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInstallmentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInvestmentTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentTransactionId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByInvestmentTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentTransactionId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByStatementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statementDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      sortByStatementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statementDate', Sort.desc);
    });
  }
}

extension CreditCardInstallmentQuerySortThenBy
    on QueryBuilder<CreditCardInstallment, CreditCardInstallment, QSortThenBy> {
  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByCreditCardAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financeTransactionId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInstallmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentCount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInstallmentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentCount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInstallmentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInstallmentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentDate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInstallmentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInvestmentTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentTransactionId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByInvestmentTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentTransactionId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByStatementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statementDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QAfterSortBy>
      thenByStatementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statementDate', Sort.desc);
    });
  }
}

extension CreditCardInstallmentQueryWhereDistinct
    on QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct> {
  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creditCardAccountId');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financeTransactionId');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByInstallmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installmentCount');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByInstallmentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installmentDate');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installmentNumber');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByInvestmentTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investmentTransactionId');
    });
  }

  QueryBuilder<CreditCardInstallment, CreditCardInstallment, QDistinct>
      distinctByStatementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statementDate');
    });
  }
}

extension CreditCardInstallmentQueryProperty on QueryBuilder<
    CreditCardInstallment, CreditCardInstallment, QQueryProperty> {
  QueryBuilder<CreditCardInstallment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreditCardInstallment, double, QQueryOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<CreditCardInstallment, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CreditCardInstallment, int, QQueryOperations>
      creditCardAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creditCardAccountId');
    });
  }

  QueryBuilder<CreditCardInstallment, DateTime, QQueryOperations>
      dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<CreditCardInstallment, int?, QQueryOperations>
      financeTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financeTransactionId');
    });
  }

  QueryBuilder<CreditCardInstallment, int, QQueryOperations>
      installmentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentCount');
    });
  }

  QueryBuilder<CreditCardInstallment, DateTime, QQueryOperations>
      installmentDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentDate');
    });
  }

  QueryBuilder<CreditCardInstallment, int, QQueryOperations>
      installmentNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentNumber');
    });
  }

  QueryBuilder<CreditCardInstallment, int?, QQueryOperations>
      investmentTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investmentTransactionId');
    });
  }

  QueryBuilder<CreditCardInstallment, DateTime, QQueryOperations>
      statementDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statementDate');
    });
  }
}
