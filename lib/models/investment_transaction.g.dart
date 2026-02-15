// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_transaction.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvestmentTransactionCollection on Isar {
  IsarCollection<InvestmentTransaction> get investmentTransactions =>
      this.collection();
}

const InvestmentTransactionSchema = CollectionSchema(
  name: r'InvestmentTransaction',
  id: -7798956507813211226,
  properties: {
    r'cashAccountId': PropertySchema(
      id: 0,
      name: r'cashAccountId',
      type: IsarType.long,
    ),
    r'costBasisTotal': PropertySchema(
      id: 1,
      name: r'costBasisTotal',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 3,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'investmentAccountId': PropertySchema(
      id: 4,
      name: r'investmentAccountId',
      type: IsarType.long,
    ),
    r'quantity': PropertySchema(
      id: 5,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'realizedPnl': PropertySchema(
      id: 6,
      name: r'realizedPnl',
      type: IsarType.double,
    ),
    r'symbol': PropertySchema(
      id: 7,
      name: r'symbol',
      type: IsarType.string,
    ),
    r'total': PropertySchema(
      id: 8,
      name: r'total',
      type: IsarType.double,
    ),
    r'type': PropertySchema(
      id: 9,
      name: r'type',
      type: IsarType.string,
    ),
    r'unitPrice': PropertySchema(
      id: 10,
      name: r'unitPrice',
      type: IsarType.double,
    )
  },
  estimateSize: _investmentTransactionEstimateSize,
  serialize: _investmentTransactionSerialize,
  deserialize: _investmentTransactionDeserialize,
  deserializeProp: _investmentTransactionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _investmentTransactionGetId,
  getLinks: _investmentTransactionGetLinks,
  attach: _investmentTransactionAttach,
  version: '3.1.0+1',
);

int _investmentTransactionEstimateSize(
  InvestmentTransaction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.symbol.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _investmentTransactionSerialize(
  InvestmentTransaction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cashAccountId);
  writer.writeDouble(offsets[1], object.costBasisTotal);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.date);
  writer.writeLong(offsets[4], object.investmentAccountId);
  writer.writeDouble(offsets[5], object.quantity);
  writer.writeDouble(offsets[6], object.realizedPnl);
  writer.writeString(offsets[7], object.symbol);
  writer.writeDouble(offsets[8], object.total);
  writer.writeString(offsets[9], object.type);
  writer.writeDouble(offsets[10], object.unitPrice);
}

InvestmentTransaction _investmentTransactionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InvestmentTransaction();
  object.cashAccountId = reader.readLong(offsets[0]);
  object.costBasisTotal = reader.readDouble(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.date = reader.readDateTime(offsets[3]);
  object.id = id;
  object.investmentAccountId = reader.readLong(offsets[4]);
  object.quantity = reader.readDouble(offsets[5]);
  object.realizedPnl = reader.readDouble(offsets[6]);
  object.symbol = reader.readString(offsets[7]);
  object.total = reader.readDouble(offsets[8]);
  object.type = reader.readString(offsets[9]);
  object.unitPrice = reader.readDouble(offsets[10]);
  return object;
}

P _investmentTransactionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _investmentTransactionGetId(InvestmentTransaction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _investmentTransactionGetLinks(
    InvestmentTransaction object) {
  return [];
}

void _investmentTransactionAttach(
    IsarCollection<dynamic> col, Id id, InvestmentTransaction object) {
  object.id = id;
}

extension InvestmentTransactionQueryWhereSort
    on QueryBuilder<InvestmentTransaction, InvestmentTransaction, QWhere> {
  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InvestmentTransactionQueryWhere on QueryBuilder<InvestmentTransaction,
    InvestmentTransaction, QWhereClause> {
  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterWhereClause>
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterWhereClause>
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

extension InvestmentTransactionQueryFilter on QueryBuilder<
    InvestmentTransaction, InvestmentTransaction, QFilterCondition> {
  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> cashAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> cashAccountIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cashAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> cashAccountIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cashAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> cashAccountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cashAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> costBasisTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costBasisTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> costBasisTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costBasisTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> costBasisTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costBasisTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> costBasisTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costBasisTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> investmentAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investmentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> investmentAccountIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'investmentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> investmentAccountIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'investmentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> investmentAccountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'investmentAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> quantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> quantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> quantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> quantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> realizedPnlEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realizedPnl',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> realizedPnlGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'realizedPnl',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> realizedPnlLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'realizedPnl',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> realizedPnlBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'realizedPnl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'symbol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
          QAfterFilterCondition>
      symbolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
          QAfterFilterCondition>
      symbolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'symbol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> symbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> totalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> totalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> totalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> totalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
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

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> unitPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> unitPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> unitPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction,
      QAfterFilterCondition> unitPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension InvestmentTransactionQueryObject on QueryBuilder<
    InvestmentTransaction, InvestmentTransaction, QFilterCondition> {}

extension InvestmentTransactionQueryLinks on QueryBuilder<InvestmentTransaction,
    InvestmentTransaction, QFilterCondition> {}

extension InvestmentTransactionQuerySortBy
    on QueryBuilder<InvestmentTransaction, InvestmentTransaction, QSortBy> {
  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByCashAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashAccountId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByCashAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashAccountId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByCostBasisTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costBasisTotal', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByCostBasisTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costBasisTotal', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByInvestmentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentAccountId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByInvestmentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentAccountId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByRealizedPnl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedPnl', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByRealizedPnlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedPnl', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByUnitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      sortByUnitPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.desc);
    });
  }
}

extension InvestmentTransactionQuerySortThenBy
    on QueryBuilder<InvestmentTransaction, InvestmentTransaction, QSortThenBy> {
  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByCashAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashAccountId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByCashAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashAccountId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByCostBasisTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costBasisTotal', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByCostBasisTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costBasisTotal', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByInvestmentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentAccountId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByInvestmentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentAccountId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByRealizedPnl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedPnl', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByRealizedPnlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedPnl', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByUnitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.asc);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QAfterSortBy>
      thenByUnitPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.desc);
    });
  }
}

extension InvestmentTransactionQueryWhereDistinct
    on QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct> {
  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByCashAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cashAccountId');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByCostBasisTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costBasisTotal');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByInvestmentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investmentAccountId');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByRealizedPnl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'realizedPnl');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctBySymbol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symbol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentTransaction, InvestmentTransaction, QDistinct>
      distinctByUnitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitPrice');
    });
  }
}

extension InvestmentTransactionQueryProperty on QueryBuilder<
    InvestmentTransaction, InvestmentTransaction, QQueryProperty> {
  QueryBuilder<InvestmentTransaction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InvestmentTransaction, int, QQueryOperations>
      cashAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cashAccountId');
    });
  }

  QueryBuilder<InvestmentTransaction, double, QQueryOperations>
      costBasisTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costBasisTotal');
    });
  }

  QueryBuilder<InvestmentTransaction, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InvestmentTransaction, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<InvestmentTransaction, int, QQueryOperations>
      investmentAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investmentAccountId');
    });
  }

  QueryBuilder<InvestmentTransaction, double, QQueryOperations>
      quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<InvestmentTransaction, double, QQueryOperations>
      realizedPnlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'realizedPnl');
    });
  }

  QueryBuilder<InvestmentTransaction, String, QQueryOperations>
      symbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symbol');
    });
  }

  QueryBuilder<InvestmentTransaction, double, QQueryOperations>
      totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<InvestmentTransaction, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<InvestmentTransaction, double, QQueryOperations>
      unitPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitPrice');
    });
  }
}
