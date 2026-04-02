// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAssetRecordCollection on Isar {
  IsarCollection<AssetRecord> get assetRecords => this.collection();
}

const AssetRecordSchema = CollectionSchema(
  name: r'AssetRecord',
  id: 1642715038020727127,
  properties: {
    r'acquisitionDate': PropertySchema(
      id: 0,
      name: r'acquisitionDate',
      type: IsarType.dateTime,
    ),
    r'acquisitionValue': PropertySchema(
      id: 1,
      name: r'acquisitionValue',
      type: IsarType.double,
    ),
    r'address': PropertySchema(
      id: 2,
      name: r'address',
      type: IsarType.string,
    ),
    r'areaSquareMeters': PropertySchema(
      id: 3,
      name: r'areaSquareMeters',
      type: IsarType.string,
    ),
    r'assetType': PropertySchema(
      id: 4,
      name: r'assetType',
      type: IsarType.string,
    ),
    r'assetTypeLabel': PropertySchema(
      id: 5,
      name: r'assetTypeLabel',
      type: IsarType.string,
    ),
    r'brand': PropertySchema(
      id: 6,
      name: r'brand',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 7,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'creditCardInstallmentCount': PropertySchema(
      id: 8,
      name: r'creditCardInstallmentCount',
      type: IsarType.long,
    ),
    r'currentValue': PropertySchema(
      id: 9,
      name: r'currentValue',
      type: IsarType.double,
    ),
    r'currentValueInput': PropertySchema(
      id: 10,
      name: r'currentValueInput',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 11,
      name: r'description',
      type: IsarType.string,
    ),
    r'displayName': PropertySchema(
      id: 12,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'effectiveDashboardValue': PropertySchema(
      id: 13,
      name: r'effectiveDashboardValue',
      type: IsarType.double,
    ),
    r'expenseAccountId': PropertySchema(
      id: 14,
      name: r'expenseAccountId',
      type: IsarType.long,
    ),
    r'expenseCategoryId': PropertySchema(
      id: 15,
      name: r'expenseCategoryId',
      type: IsarType.long,
    ),
    r'incomeAccountId': PropertySchema(
      id: 16,
      name: r'incomeAccountId',
      type: IsarType.long,
    ),
    r'incomeCategoryId': PropertySchema(
      id: 17,
      name: r'incomeCategoryId',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 18,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isSold': PropertySchema(
      id: 19,
      name: r'isSold',
      type: IsarType.bool,
    ),
    r'model': PropertySchema(
      id: 20,
      name: r'model',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 21,
      name: r'name',
      type: IsarType.string,
    ),
    r'paymentMethod': PropertySchema(
      id: 22,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'primaryPaymentAmount': PropertySchema(
      id: 23,
      name: r'primaryPaymentAmount',
      type: IsarType.double,
    ),
    r'profitOrLoss': PropertySchema(
      id: 24,
      name: r'profitOrLoss',
      type: IsarType.double,
    ),
    r'purchaseFinanceTransactionId': PropertySchema(
      id: 25,
      name: r'purchaseFinanceTransactionId',
      type: IsarType.long,
    ),
    r'saleDate': PropertySchema(
      id: 26,
      name: r'saleDate',
      type: IsarType.dateTime,
    ),
    r'saleFinanceTransactionId': PropertySchema(
      id: 27,
      name: r'saleFinanceTransactionId',
      type: IsarType.long,
    ),
    r'saleValue': PropertySchema(
      id: 28,
      name: r'saleValue',
      type: IsarType.double,
    ),
    r'secondaryExpenseAccountId': PropertySchema(
      id: 29,
      name: r'secondaryExpenseAccountId',
      type: IsarType.long,
    ),
    r'secondaryPaymentAmount': PropertySchema(
      id: 30,
      name: r'secondaryPaymentAmount',
      type: IsarType.double,
    ),
    r'secondaryPurchaseFinanceTransactionId': PropertySchema(
      id: 31,
      name: r'secondaryPurchaseFinanceTransactionId',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 32,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _assetRecordEstimateSize,
  serialize: _assetRecordSerialize,
  deserialize: _assetRecordDeserialize,
  deserializeProp: _assetRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _assetRecordGetId,
  getLinks: _assetRecordGetLinks,
  attach: _assetRecordAttach,
  version: '3.1.0+1',
);

int _assetRecordEstimateSize(
  AssetRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.address;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.areaSquareMeters;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.assetType.length * 3;
  bytesCount += 3 + object.assetTypeLabel.length * 3;
  {
    final value = object.brand;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentValueInput;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.displayName.length * 3;
  {
    final value = object.model;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.paymentMethod.length * 3;
  return bytesCount;
}

void _assetRecordSerialize(
  AssetRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.acquisitionDate);
  writer.writeDouble(offsets[1], object.acquisitionValue);
  writer.writeString(offsets[2], object.address);
  writer.writeString(offsets[3], object.areaSquareMeters);
  writer.writeString(offsets[4], object.assetType);
  writer.writeString(offsets[5], object.assetTypeLabel);
  writer.writeString(offsets[6], object.brand);
  writer.writeDateTime(offsets[7], object.createdAt);
  writer.writeLong(offsets[8], object.creditCardInstallmentCount);
  writer.writeDouble(offsets[9], object.currentValue);
  writer.writeString(offsets[10], object.currentValueInput);
  writer.writeString(offsets[11], object.description);
  writer.writeString(offsets[12], object.displayName);
  writer.writeDouble(offsets[13], object.effectiveDashboardValue);
  writer.writeLong(offsets[14], object.expenseAccountId);
  writer.writeLong(offsets[15], object.expenseCategoryId);
  writer.writeLong(offsets[16], object.incomeAccountId);
  writer.writeLong(offsets[17], object.incomeCategoryId);
  writer.writeBool(offsets[18], object.isActive);
  writer.writeBool(offsets[19], object.isSold);
  writer.writeString(offsets[20], object.model);
  writer.writeString(offsets[21], object.name);
  writer.writeString(offsets[22], object.paymentMethod);
  writer.writeDouble(offsets[23], object.primaryPaymentAmount);
  writer.writeDouble(offsets[24], object.profitOrLoss);
  writer.writeLong(offsets[25], object.purchaseFinanceTransactionId);
  writer.writeDateTime(offsets[26], object.saleDate);
  writer.writeLong(offsets[27], object.saleFinanceTransactionId);
  writer.writeDouble(offsets[28], object.saleValue);
  writer.writeLong(offsets[29], object.secondaryExpenseAccountId);
  writer.writeDouble(offsets[30], object.secondaryPaymentAmount);
  writer.writeLong(offsets[31], object.secondaryPurchaseFinanceTransactionId);
  writer.writeDateTime(offsets[32], object.updatedAt);
}

AssetRecord _assetRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AssetRecord();
  object.acquisitionDate = reader.readDateTime(offsets[0]);
  object.acquisitionValue = reader.readDouble(offsets[1]);
  object.address = reader.readStringOrNull(offsets[2]);
  object.areaSquareMeters = reader.readStringOrNull(offsets[3]);
  object.assetType = reader.readString(offsets[4]);
  object.brand = reader.readStringOrNull(offsets[6]);
  object.createdAt = reader.readDateTime(offsets[7]);
  object.creditCardInstallmentCount = reader.readLongOrNull(offsets[8]);
  object.currentValueInput = reader.readStringOrNull(offsets[10]);
  object.description = reader.readStringOrNull(offsets[11]);
  object.expenseAccountId = reader.readLong(offsets[14]);
  object.expenseCategoryId = reader.readLong(offsets[15]);
  object.id = id;
  object.incomeAccountId = reader.readLongOrNull(offsets[16]);
  object.incomeCategoryId = reader.readLongOrNull(offsets[17]);
  object.isActive = reader.readBool(offsets[18]);
  object.isSold = reader.readBool(offsets[19]);
  object.model = reader.readStringOrNull(offsets[20]);
  object.name = reader.readString(offsets[21]);
  object.paymentMethod = reader.readString(offsets[22]);
  object.primaryPaymentAmount = reader.readDoubleOrNull(offsets[23]);
  object.purchaseFinanceTransactionId = reader.readLongOrNull(offsets[25]);
  object.saleDate = reader.readDateTimeOrNull(offsets[26]);
  object.saleFinanceTransactionId = reader.readLongOrNull(offsets[27]);
  object.saleValue = reader.readDoubleOrNull(offsets[28]);
  object.secondaryExpenseAccountId = reader.readLongOrNull(offsets[29]);
  object.secondaryPaymentAmount = reader.readDoubleOrNull(offsets[30]);
  object.secondaryPurchaseFinanceTransactionId =
      reader.readLongOrNull(offsets[31]);
  object.updatedAt = reader.readDateTime(offsets[32]);
  return object;
}

P _assetRecordDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readDoubleOrNull(offset)) as P;
    case 24:
      return (reader.readDoubleOrNull(offset)) as P;
    case 25:
      return (reader.readLongOrNull(offset)) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (reader.readLongOrNull(offset)) as P;
    case 28:
      return (reader.readDoubleOrNull(offset)) as P;
    case 29:
      return (reader.readLongOrNull(offset)) as P;
    case 30:
      return (reader.readDoubleOrNull(offset)) as P;
    case 31:
      return (reader.readLongOrNull(offset)) as P;
    case 32:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _assetRecordGetId(AssetRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _assetRecordGetLinks(AssetRecord object) {
  return [];
}

void _assetRecordAttach(
    IsarCollection<dynamic> col, Id id, AssetRecord object) {
  object.id = id;
}

extension AssetRecordQueryWhereSort
    on QueryBuilder<AssetRecord, AssetRecord, QWhere> {
  QueryBuilder<AssetRecord, AssetRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AssetRecordQueryWhere
    on QueryBuilder<AssetRecord, AssetRecord, QWhereClause> {
  QueryBuilder<AssetRecord, AssetRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterWhereClause> idBetween(
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

extension AssetRecordQueryFilter
    on QueryBuilder<AssetRecord, AssetRecord, QFilterCondition> {
  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acquisitionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'acquisitionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'acquisitionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'acquisitionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acquisitionValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'acquisitionValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'acquisitionValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      acquisitionValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'acquisitionValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      addressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      addressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> addressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      addressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> addressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> addressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'address',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      addressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> addressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> addressContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> addressMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'address',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      addressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      addressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'areaSquareMeters',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'areaSquareMeters',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaSquareMeters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'areaSquareMeters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'areaSquareMeters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'areaSquareMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'areaSquareMeters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'areaSquareMeters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'areaSquareMeters',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'areaSquareMeters',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaSquareMeters',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      areaSquareMetersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'areaSquareMeters',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assetType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetType',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assetType',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetTypeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetTypeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetTypeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetTypeLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assetTypeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assetTypeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assetTypeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assetTypeLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetTypeLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      assetTypeLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assetTypeLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'brand',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      brandIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'brand',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      brandGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'brand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> brandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      brandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      creditCardInstallmentCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'creditCardInstallmentCount',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      creditCardInstallmentCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'creditCardInstallmentCount',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      creditCardInstallmentCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditCardInstallmentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      creditCardInstallmentCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creditCardInstallmentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      creditCardInstallmentCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creditCardInstallmentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      creditCardInstallmentCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creditCardInstallmentCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentValue',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentValue',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentValueInput',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentValueInput',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentValueInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentValueInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentValueInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentValueInput',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentValueInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentValueInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentValueInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentValueInput',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentValueInput',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      currentValueInputIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentValueInput',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      effectiveDashboardValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveDashboardValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      effectiveDashboardValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveDashboardValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      effectiveDashboardValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveDashboardValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      effectiveDashboardValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveDashboardValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseAccountIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expenseAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseAccountIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expenseAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseAccountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expenseAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseCategoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseCategoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expenseCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseCategoryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expenseCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      expenseCategoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expenseCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeAccountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'incomeAccountId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeAccountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'incomeAccountId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeAccountIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'incomeAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeAccountIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'incomeAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeAccountIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'incomeAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeAccountIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'incomeAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'incomeCategoryId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'incomeCategoryId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'incomeCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'incomeCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'incomeCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      incomeCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'incomeCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> isSoldEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSold',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'model',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      modelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'model',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      modelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'model',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'model',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      primaryPaymentAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'primaryPaymentAmount',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      primaryPaymentAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'primaryPaymentAmount',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      primaryPaymentAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryPaymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      primaryPaymentAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryPaymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      primaryPaymentAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryPaymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      primaryPaymentAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryPaymentAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      profitOrLossIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profitOrLoss',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      profitOrLossIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profitOrLoss',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      profitOrLossEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profitOrLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      profitOrLossGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profitOrLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      profitOrLossLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profitOrLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      profitOrLossBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profitOrLoss',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      purchaseFinanceTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purchaseFinanceTransactionId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      purchaseFinanceTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purchaseFinanceTransactionId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      purchaseFinanceTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      purchaseFinanceTransactionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      purchaseFinanceTransactionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      purchaseFinanceTransactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseFinanceTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saleDate',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saleDate',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> saleDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saleDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saleDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition> saleDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saleDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleFinanceTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saleFinanceTransactionId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleFinanceTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saleFinanceTransactionId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleFinanceTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleFinanceTransactionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saleFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleFinanceTransactionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saleFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleFinanceTransactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saleFinanceTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saleValue',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saleValue',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saleValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saleValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      saleValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saleValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryExpenseAccountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondaryExpenseAccountId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryExpenseAccountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondaryExpenseAccountId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryExpenseAccountIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryExpenseAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryExpenseAccountIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryExpenseAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryExpenseAccountIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryExpenseAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryExpenseAccountIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryExpenseAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPaymentAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondaryPaymentAmount',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPaymentAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondaryPaymentAmount',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPaymentAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryPaymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPaymentAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryPaymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPaymentAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryPaymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPaymentAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryPaymentAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPurchaseFinanceTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondaryPurchaseFinanceTransactionId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPurchaseFinanceTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondaryPurchaseFinanceTransactionId',
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPurchaseFinanceTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryPurchaseFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPurchaseFinanceTransactionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryPurchaseFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPurchaseFinanceTransactionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryPurchaseFinanceTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      secondaryPurchaseFinanceTransactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryPurchaseFinanceTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<AssetRecord, AssetRecord, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

extension AssetRecordQueryObject
    on QueryBuilder<AssetRecord, AssetRecord, QFilterCondition> {}

extension AssetRecordQueryLinks
    on QueryBuilder<AssetRecord, AssetRecord, QFilterCondition> {}

extension AssetRecordQuerySortBy
    on QueryBuilder<AssetRecord, AssetRecord, QSortBy> {
  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByAcquisitionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionDate', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByAcquisitionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionDate', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByAcquisitionValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByAcquisitionValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByAreaSquareMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByAreaSquareMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByAssetTypeLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeLabel', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByAssetTypeLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeLabel', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByCreditCardInstallmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardInstallmentCount', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByCreditCardInstallmentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardInstallmentCount', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByCurrentValueInput() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValueInput', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByCurrentValueInputDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValueInput', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByEffectiveDashboardValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDashboardValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByEffectiveDashboardValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDashboardValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByExpenseAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseAccountId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByExpenseAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseAccountId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByExpenseCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseCategoryId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByExpenseCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseCategoryId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByIncomeAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeAccountId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByIncomeAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeAccountId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByIncomeCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeCategoryId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByIncomeCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeCategoryId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByIsSold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSold', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByIsSoldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSold', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByPrimaryPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPaymentAmount', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByPrimaryPaymentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPaymentAmount', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByProfitOrLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitOrLoss', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByProfitOrLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitOrLoss', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByPurchaseFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseFinanceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortByPurchaseFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseFinanceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortBySaleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortBySaleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySaleFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleFinanceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySaleFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleFinanceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortBySaleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortBySaleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySecondaryExpenseAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryExpenseAccountId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySecondaryExpenseAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryExpenseAccountId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySecondaryPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryPaymentAmount', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySecondaryPaymentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryPaymentAmount', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySecondaryPurchaseFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
          r'secondaryPurchaseFinanceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      sortBySecondaryPurchaseFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
          r'secondaryPurchaseFinanceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AssetRecordQuerySortThenBy
    on QueryBuilder<AssetRecord, AssetRecord, QSortThenBy> {
  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByAcquisitionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionDate', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByAcquisitionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionDate', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByAcquisitionValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByAcquisitionValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acquisitionValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByAreaSquareMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByAreaSquareMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByAssetTypeLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeLabel', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByAssetTypeLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeLabel', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByCreditCardInstallmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardInstallmentCount', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByCreditCardInstallmentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditCardInstallmentCount', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByCurrentValueInput() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValueInput', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByCurrentValueInputDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValueInput', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByEffectiveDashboardValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDashboardValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByEffectiveDashboardValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDashboardValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByExpenseAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseAccountId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByExpenseAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseAccountId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByExpenseCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseCategoryId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByExpenseCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseCategoryId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByIncomeAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeAccountId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByIncomeAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeAccountId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByIncomeCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeCategoryId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByIncomeCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeCategoryId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByIsSold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSold', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByIsSoldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSold', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByPrimaryPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPaymentAmount', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByPrimaryPaymentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPaymentAmount', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByProfitOrLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitOrLoss', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByProfitOrLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitOrLoss', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByPurchaseFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseFinanceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenByPurchaseFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseFinanceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenBySaleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenBySaleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySaleFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleFinanceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySaleFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleFinanceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenBySaleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleValue', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenBySaleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleValue', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySecondaryExpenseAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryExpenseAccountId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySecondaryExpenseAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryExpenseAccountId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySecondaryPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryPaymentAmount', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySecondaryPaymentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryPaymentAmount', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySecondaryPurchaseFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
          r'secondaryPurchaseFinanceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy>
      thenBySecondaryPurchaseFinanceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
          r'secondaryPurchaseFinanceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AssetRecordQueryWhereDistinct
    on QueryBuilder<AssetRecord, AssetRecord, QDistinct> {
  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByAcquisitionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acquisitionDate');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByAcquisitionValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acquisitionValue');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'address', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByAreaSquareMeters(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'areaSquareMeters',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByAssetType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByAssetTypeLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetTypeLabel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByBrand(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brand', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByCreditCardInstallmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creditCardInstallmentCount');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValue');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByCurrentValueInput(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValueInput',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByEffectiveDashboardValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveDashboardValue');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByExpenseAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expenseAccountId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByExpenseCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expenseCategoryId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByIncomeAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incomeAccountId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByIncomeCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incomeCategoryId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByIsSold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSold');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByPaymentMethod(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByPrimaryPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryPaymentAmount');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByProfitOrLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profitOrLoss');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctByPurchaseFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseFinanceTransactionId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctBySaleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saleDate');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctBySaleFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saleFinanceTransactionId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctBySaleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saleValue');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctBySecondaryExpenseAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secondaryExpenseAccountId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctBySecondaryPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secondaryPaymentAmount');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct>
      distinctBySecondaryPurchaseFinanceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secondaryPurchaseFinanceTransactionId');
    });
  }

  QueryBuilder<AssetRecord, AssetRecord, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AssetRecordQueryProperty
    on QueryBuilder<AssetRecord, AssetRecord, QQueryProperty> {
  QueryBuilder<AssetRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AssetRecord, DateTime, QQueryOperations>
      acquisitionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acquisitionDate');
    });
  }

  QueryBuilder<AssetRecord, double, QQueryOperations>
      acquisitionValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acquisitionValue');
    });
  }

  QueryBuilder<AssetRecord, String?, QQueryOperations> addressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'address');
    });
  }

  QueryBuilder<AssetRecord, String?, QQueryOperations>
      areaSquareMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'areaSquareMeters');
    });
  }

  QueryBuilder<AssetRecord, String, QQueryOperations> assetTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetType');
    });
  }

  QueryBuilder<AssetRecord, String, QQueryOperations> assetTypeLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetTypeLabel');
    });
  }

  QueryBuilder<AssetRecord, String?, QQueryOperations> brandProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brand');
    });
  }

  QueryBuilder<AssetRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AssetRecord, int?, QQueryOperations>
      creditCardInstallmentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creditCardInstallmentCount');
    });
  }

  QueryBuilder<AssetRecord, double?, QQueryOperations> currentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValue');
    });
  }

  QueryBuilder<AssetRecord, String?, QQueryOperations>
      currentValueInputProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValueInput');
    });
  }

  QueryBuilder<AssetRecord, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<AssetRecord, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<AssetRecord, double, QQueryOperations>
      effectiveDashboardValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveDashboardValue');
    });
  }

  QueryBuilder<AssetRecord, int, QQueryOperations> expenseAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseAccountId');
    });
  }

  QueryBuilder<AssetRecord, int, QQueryOperations> expenseCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseCategoryId');
    });
  }

  QueryBuilder<AssetRecord, int?, QQueryOperations> incomeAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incomeAccountId');
    });
  }

  QueryBuilder<AssetRecord, int?, QQueryOperations> incomeCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incomeCategoryId');
    });
  }

  QueryBuilder<AssetRecord, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<AssetRecord, bool, QQueryOperations> isSoldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSold');
    });
  }

  QueryBuilder<AssetRecord, String?, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<AssetRecord, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AssetRecord, String, QQueryOperations> paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<AssetRecord, double?, QQueryOperations>
      primaryPaymentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryPaymentAmount');
    });
  }

  QueryBuilder<AssetRecord, double?, QQueryOperations> profitOrLossProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profitOrLoss');
    });
  }

  QueryBuilder<AssetRecord, int?, QQueryOperations>
      purchaseFinanceTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseFinanceTransactionId');
    });
  }

  QueryBuilder<AssetRecord, DateTime?, QQueryOperations> saleDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saleDate');
    });
  }

  QueryBuilder<AssetRecord, int?, QQueryOperations>
      saleFinanceTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saleFinanceTransactionId');
    });
  }

  QueryBuilder<AssetRecord, double?, QQueryOperations> saleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saleValue');
    });
  }

  QueryBuilder<AssetRecord, int?, QQueryOperations>
      secondaryExpenseAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryExpenseAccountId');
    });
  }

  QueryBuilder<AssetRecord, double?, QQueryOperations>
      secondaryPaymentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryPaymentAmount');
    });
  }

  QueryBuilder<AssetRecord, int?, QQueryOperations>
      secondaryPurchaseFinanceTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryPurchaseFinanceTransactionId');
    });
  }

  QueryBuilder<AssetRecord, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
