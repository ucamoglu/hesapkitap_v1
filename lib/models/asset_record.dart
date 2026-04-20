import 'package:isar/isar.dart';

part 'asset_record.g.dart';

@collection
class AssetRecord {
  AssetRecord();

  Id id = Isar.autoIncrement;

  late String assetType;
  String name = '';
  String? areaSquareMeters;
  String? address;
  String? brand;
  String? model;
  String? plate;
  String? description;
  late double acquisitionValue;
  String? currentValueInput;
  String paymentMethod = 'single';
  double? primaryPaymentAmount;
  int? secondaryExpenseAccountId;
  double? secondaryPaymentAmount;
  int? secondaryPurchaseFinanceTransactionId;
  int? creditCardInstallmentCount;
  double? saleValue;
  late DateTime acquisitionDate;
  DateTime? saleDate;
  late int expenseAccountId;
  late int expenseCategoryId;
  int? incomeAccountId;
  int? incomeCategoryId;
  int? purchaseFinanceTransactionId;
  int? saleFinanceTransactionId;
  bool isActive = true;
  bool isSold = false;
  late DateTime createdAt;
  late DateTime updatedAt;

  double? get currentValue {
    final raw = currentValueInput?.trim();
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String get displayName {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) return trimmedName;
    final vehicle = [brand?.trim(), model?.trim()]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .join(' ');
    if (vehicle.isNotEmpty) return vehicle;
    return assetTypeLabel;
  }

  String get assetTypeLabel {
    switch (assetType) {
      case 'housing':
        return 'Konut';
      case 'workplace':
        return 'İşyeri';
      case 'land':
        return 'Arsa';
      case 'field':
        return 'Arazi';
      case 'vehicle':
        return 'Araç';
      case 'fixture':
        return 'Demirbaş';
      default:
        return assetType;
    }
  }

  double get effectiveDashboardValue => currentValue ?? acquisitionValue;

  double? get profitOrLoss {
    final soldValue = saleValue;
    if (soldValue == null) return null;
    return soldValue - acquisitionValue;
  }

  AssetRecord copyWith({
    Id? id,
    String? assetType,
    String? name,
    String? areaSquareMeters,
    String? address,
    String? brand,
    String? model,
    String? plate,
    String? description,
    double? acquisitionValue,
    String? currentValueInput,
    String? paymentMethod,
    double? primaryPaymentAmount,
    int? secondaryExpenseAccountId,
    double? secondaryPaymentAmount,
    int? secondaryPurchaseFinanceTransactionId,
    int? creditCardInstallmentCount,
    double? saleValue,
    DateTime? acquisitionDate,
    DateTime? saleDate,
    int? expenseAccountId,
    int? expenseCategoryId,
    int? incomeAccountId,
    int? incomeCategoryId,
    int? purchaseFinanceTransactionId,
    int? saleFinanceTransactionId,
    bool? isActive,
    bool? isSold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetRecord()
      ..id = id ?? this.id
      ..assetType = assetType ?? this.assetType
      ..name = name ?? this.name
      ..areaSquareMeters = areaSquareMeters ?? this.areaSquareMeters
      ..address = address ?? this.address
      ..brand = brand ?? this.brand
      ..model = model ?? this.model
      ..plate = plate ?? this.plate
      ..description = description ?? this.description
      ..acquisitionValue = acquisitionValue ?? this.acquisitionValue
      ..currentValueInput = currentValueInput ?? this.currentValueInput
      ..paymentMethod = paymentMethod ?? this.paymentMethod
      ..primaryPaymentAmount = primaryPaymentAmount ?? this.primaryPaymentAmount
      ..secondaryExpenseAccountId =
          secondaryExpenseAccountId ?? this.secondaryExpenseAccountId
      ..secondaryPaymentAmount =
          secondaryPaymentAmount ?? this.secondaryPaymentAmount
      ..secondaryPurchaseFinanceTransactionId =
          secondaryPurchaseFinanceTransactionId ??
              this.secondaryPurchaseFinanceTransactionId
      ..creditCardInstallmentCount =
          creditCardInstallmentCount ?? this.creditCardInstallmentCount
      ..saleValue = saleValue ?? this.saleValue
      ..acquisitionDate = acquisitionDate ?? this.acquisitionDate
      ..saleDate = saleDate ?? this.saleDate
      ..expenseAccountId = expenseAccountId ?? this.expenseAccountId
      ..expenseCategoryId = expenseCategoryId ?? this.expenseCategoryId
      ..incomeAccountId = incomeAccountId ?? this.incomeAccountId
      ..incomeCategoryId = incomeCategoryId ?? this.incomeCategoryId
      ..purchaseFinanceTransactionId =
          purchaseFinanceTransactionId ?? this.purchaseFinanceTransactionId
      ..saleFinanceTransactionId =
          saleFinanceTransactionId ?? this.saleFinanceTransactionId
      ..isActive = isActive ?? this.isActive
      ..isSold = isSold ?? this.isSold
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetType': assetType,
      'name': name,
      'areaSquareMeters': areaSquareMeters,
      'address': address,
      'brand': brand,
      'model': model,
      'plate': plate,
      'description': description,
      'acquisitionValue': acquisitionValue,
      'currentValueInput': currentValueInput,
      'paymentMethod': paymentMethod,
      'primaryPaymentAmount': primaryPaymentAmount,
      'secondaryExpenseAccountId': secondaryExpenseAccountId,
      'secondaryPaymentAmount': secondaryPaymentAmount,
      'secondaryPurchaseFinanceTransactionId': secondaryPurchaseFinanceTransactionId,
      'creditCardInstallmentCount': creditCardInstallmentCount,
      'saleValue': saleValue,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'saleDate': saleDate?.toIso8601String(),
      'expenseAccountId': expenseAccountId,
      'expenseCategoryId': expenseCategoryId,
      'incomeAccountId': incomeAccountId,
      'incomeCategoryId': incomeCategoryId,
      'purchaseFinanceTransactionId': purchaseFinanceTransactionId,
      'saleFinanceTransactionId': saleFinanceTransactionId,
      'isActive': isActive,
      'isSold': isSold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AssetRecord.fromJson(Map<String, dynamic> json) {
    return AssetRecord()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..assetType = json['assetType'] as String
      ..name = json['name'] as String? ?? ''
      ..areaSquareMeters = json['areaSquareMeters'] as String?
      ..address = json['address'] as String?
      ..brand = json['brand'] as String?
      ..model = json['model'] as String?
      ..plate = json['plate'] as String?
      ..description = json['description'] as String?
      ..acquisitionValue = (json['acquisitionValue'] as num).toDouble()
      ..currentValueInput = json['currentValueInput'] as String?
      ..paymentMethod = json['paymentMethod'] as String? ?? 'single'
      ..primaryPaymentAmount = (json['primaryPaymentAmount'] as num?)?.toDouble()
      ..secondaryExpenseAccountId = json['secondaryExpenseAccountId'] as int?
      ..secondaryPaymentAmount =
          (json['secondaryPaymentAmount'] as num?)?.toDouble()
      ..secondaryPurchaseFinanceTransactionId =
          json['secondaryPurchaseFinanceTransactionId'] as int?
      ..creditCardInstallmentCount =
          json['creditCardInstallmentCount'] as int?
      ..saleValue = (json['saleValue'] as num?)?.toDouble()
      ..acquisitionDate = DateTime.parse(json['acquisitionDate'] as String)
      ..saleDate = json['saleDate'] == null
          ? null
          : DateTime.parse(json['saleDate'] as String)
      ..expenseAccountId = json['expenseAccountId'] as int
      ..expenseCategoryId = json['expenseCategoryId'] as int
      ..incomeAccountId = json['incomeAccountId'] as int?
      ..incomeCategoryId = json['incomeCategoryId'] as int?
      ..purchaseFinanceTransactionId =
          json['purchaseFinanceTransactionId'] as int?
      ..saleFinanceTransactionId = json['saleFinanceTransactionId'] as int?
      ..isActive = json['isActive'] as bool? ?? true
      ..isSold = json['isSold'] as bool? ?? false
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String);
  }
}
