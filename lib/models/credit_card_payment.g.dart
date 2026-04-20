// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_payment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreditCardPaymentCollection on Isar {
  IsarCollection<CreditCardPayment> get creditCardPayments => this.collection();
}

const CreditCardPaymentSchema = CollectionSchema(
  name: r'CreditCardPayment',
  id: 8121804431852059097,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'bankAccountId': PropertySchema(
      id: 1,
      name: r'bankAccountId',
      type: IsarType.long,
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
    r'note': PropertySchema(
      id: 5,
      name: r'note',
      type: IsarType.string,
    ),
    r'paymentDate': PropertySchema(
      id: 6,
      name: r'paymentDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _creditCardPaymentEstimateSize,
  serialize: _creditCardPaymentSerialize,
  deserialize: _creditCardPaymentDeserialize,
  deserializeProp: _creditCardPaymentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _creditCardPaymentGetId,
  getLinks: _creditCardPaymentGetLinks,
  attach: _creditCardPaymentAttach,
  version: '3.1.0+1',
);

int _creditCardPaymentEstimateSize(
  CreditCardPayment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _creditCardPaymentSerialize(
  CreditCardPayment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeLong(offsets[1], object.bankAccountId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.creditCardAccountId);
  writer.writeLong(offsets[4], object.creditCardStatementId);
  writer.writeString(offsets[5], object.note);
  writer.writeDateTime(offsets[6], object.paymentDate);
}

CreditCardPayment _creditCardPaymentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreditCardPayment();
  object.amount = reader.readDouble(offsets[0]);
  object.bankAccountId = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.creditCardAccountId = reader.readLong(offsets[3]);
  object.creditCardStatementId = reader.readLong(offsets[4]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[5]);
  object.paymentDate = reader.readDateTime(offsets[6]);
  return object;
}

P _creditCardPaymentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creditCardPaymentGetId(CreditCardPayment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creditCardPaymentGetLinks(
    CreditCardPayment object) {
  return [];
}

void _creditCardPaymentAttach(
    IsarCollection<dynamic> col, Id id, CreditCardPayment object) {
  object.id = id;
}

extension CreditCardPaymentQueryWhereSort
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QWhere> {
  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CreditCardPaymentQueryWhere
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QWhereClause> {
  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterWhereClause>
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterWhereClause>
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

extension CreditCardPaymentQueryFilter
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QFilterCondition> {
  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      amountEqualTo(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      amountGreaterThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      amountLessThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      amountBetween(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      bankAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bankAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      bankAccountIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bankAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      bankAccountIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bankAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      bankAccountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bankAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditCardAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardAccountIdGreaterThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardAccountIdLessThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardAccountIdBetween(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardStatementIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditCardStatementId',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardStatementIdGreaterThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardStatementIdLessThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      creditCardStatementIdBetween(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteEqualTo(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteGreaterThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteLessThan(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteBetween(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteStartsWith(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteEndsWith(
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

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      paymentDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      paymentDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      paymentDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterFilterCondition>
      paymentDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CreditCardPaymentQueryObject
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QFilterCondition> {}

extension CreditCardPaymentQueryLinks
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QFilterCondition> {}

extension CreditCardPaymentQuerySortBy
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QSortBy> {
  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByBankAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByBankAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByCreditCardAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByCreditCardStatementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByCreditCardStatementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      sortByPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.desc);
    });
  }
}

extension CreditCardPaymentQuerySortThenBy
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QSortThenBy> {
  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByBankAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByBankAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByCreditCardAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardAccountId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByCreditCardStatementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByCreditCardStatementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardStatementId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QAfterSortBy>
      thenByPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentDate', Sort.desc);
    });
  }
}

extension CreditCardPaymentQueryWhereDistinct
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct> {
  QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct>
      distinctByBankAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bankAccountId');
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct>
      distinctByCreditCardAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creditCardAccountId');
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct>
      distinctByCreditCardStatementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creditCardStatementId');
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardPayment, CreditCardPayment, QDistinct>
      distinctByPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentDate');
    });
  }
}

extension CreditCardPaymentQueryProperty
    on QueryBuilder<CreditCardPayment, CreditCardPayment, QQueryProperty> {
  QueryBuilder<CreditCardPayment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreditCardPayment, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<CreditCardPayment, int, QQueryOperations>
      bankAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bankAccountId');
    });
  }

  QueryBuilder<CreditCardPayment, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CreditCardPayment, int, QQueryOperations>
      creditCardAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creditCardAccountId');
    });
  }

  QueryBuilder<CreditCardPayment, int, QQueryOperations>
      creditCardStatementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creditCardStatementId');
    });
  }

  QueryBuilder<CreditCardPayment, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<CreditCardPayment, DateTime, QQueryOperations>
      paymentDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentDate');
    });
  }
}
