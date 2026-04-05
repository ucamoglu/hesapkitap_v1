import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/asset_record.dart';
import 'credit_card_installment_service.dart';
import 'finance_transaction_service.dart';

class AssetRecordService {
  static const _fileName = 'asset_records_v1.json';

  static Future<List<AssetRecord>> getAll() async {
    await _migrateLegacyJsonIfNeeded();
    final isar = IsarService.isar;
    final items = await isar.assetRecords.where().anyId().findAll();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<List<AssetRecord>> getActive() async {
    final items = await getAll();
    return items.where((item) => item.isActive).toList();
  }

  static Future<AssetRecord?> getById(int id) async {
    final items = await getAll();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static Future<int> addPurchase({
    required String assetType,
    required String name,
    String? areaSquareMeters,
    String? address,
    String? brand,
    String? model,
    String? plate,
    String? description,
    String? currentValueInput,
    required double acquisitionValue,
    required DateTime acquisitionDate,
    required int expenseAccountId,
    required int expenseCategoryId,
    String paymentMethod = 'single',
    double? primaryPaymentAmount,
    int? secondaryExpenseAccountId,
    double? secondaryPaymentAmount,
    int? installmentCount,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now();
    final isar = IsarService.isar;
    final primaryAccount = await isar.accounts.get(expenseAccountId);
    if (primaryAccount == null) {
      throw Exception('Ödeme hesabı bulunamadı.');
    }
    final secondaryAccount = secondaryExpenseAccountId == null
        ? null
        : await isar.accounts.get(secondaryExpenseAccountId);
    if (secondaryExpenseAccountId != null && secondaryAccount == null) {
      throw Exception('İkinci ödeme hesabı bulunamadı.');
    }
    if (paymentMethod != 'single' && paymentMethod != 'split') {
      throw Exception('Geçersiz ödeme yöntemi.');
    }

    double primaryAmount;
    double? secondaryAmount;
    if (paymentMethod == 'single') {
      primaryAmount = acquisitionValue;
      secondaryAmount = null;
      if (secondaryExpenseAccountId != null || secondaryPaymentAmount != null) {
        throw Exception('Tek ödemede ikinci hesap kullanılamaz.');
      }
    } else {
      primaryAmount = primaryPaymentAmount ?? 0;
      secondaryAmount = secondaryPaymentAmount ?? 0;
      if (secondaryAccount == null) {
        throw Exception('Çift ödemede ikinci hesap zorunludur.');
      }
      if (expenseAccountId == secondaryExpenseAccountId) {
        throw Exception('İki farklı ödeme hesabı seçiniz.');
      }
      if (primaryAmount <= 0 || secondaryAmount <= 0) {
        throw Exception('Çift ödemede iki tutar da sıfırdan büyük olmalıdır.');
      }
      final total = primaryAmount + secondaryAmount;
      if ((total - acquisitionValue).abs() > 0.005) {
        throw Exception('Ödeme tutarlarının toplamı edinim değerine eşit olmalıdır.');
      }
      final hasSingleCreditCard = primaryAccount.isCreditCard != secondaryAccount.isCreditCard;
      if (!hasSingleCreditCard) {
        throw Exception('Çift ödemede biri kredi kartı, diğeri nakit/banka hesabı olmalıdır.');
      }
    }

    final creditCardAccount = primaryAccount.isCreditCard
        ? primaryAccount
        : (secondaryAccount?.isCreditCard == true ? secondaryAccount : null);
    final creditCardAmount = primaryAccount.isCreditCard
        ? primaryAmount
        : secondaryAmount;
    if (installmentCount != null &&
        (creditCardAccount == null ||
            creditCardAmount == null ||
            creditCardAmount <= 0 ||
            installmentCount < 2 ||
            installmentCount > 24)) {
      throw Exception('Taksit sadece kredi kartı ödeme payında 2 ile 24 arasında olabilir.');
    }

    final primaryFinanceId = await FinanceTransactionService.addExpenseAndGetId(
      accountId: expenseAccountId,
      categoryId: expenseCategoryId,
      amount: primaryAmount,
      date: acquisitionDate,
      latitude: latitude,
      longitude: longitude,
      description: description,
      syncCreditCardStatement:
          !(primaryAccount.isCreditCard && installmentCount != null),
    );
    int? secondaryFinanceId;
    if (paymentMethod == 'split' && secondaryAccount != null && secondaryAmount != null) {
      secondaryFinanceId = await FinanceTransactionService.addExpenseAndGetId(
        accountId: secondaryAccount.id,
        categoryId: expenseCategoryId,
        amount: secondaryAmount,
        date: acquisitionDate,
        latitude: latitude,
        longitude: longitude,
        description: description,
        syncCreditCardStatement:
            !(secondaryAccount.isCreditCard && installmentCount != null),
      );
    }
    final record = AssetRecord()
      ..assetType = assetType
      ..name = name.trim()
      ..areaSquareMeters = _normalize(areaSquareMeters)
      ..address = _normalize(address)
      ..brand = _normalize(brand)
      ..model = _normalize(model)
      ..plate = _normalize(plate)
      ..description = _normalize(description)
      ..currentValueInput = _normalize(currentValueInput)
      ..paymentMethod = paymentMethod
      ..primaryPaymentAmount = primaryAmount
      ..secondaryExpenseAccountId = secondaryExpenseAccountId
      ..secondaryPaymentAmount = secondaryAmount
      ..secondaryPurchaseFinanceTransactionId = secondaryFinanceId
      ..creditCardInstallmentCount = installmentCount
      ..acquisitionValue = acquisitionValue
      ..acquisitionDate = acquisitionDate
      ..expenseAccountId = expenseAccountId
      ..expenseCategoryId = expenseCategoryId
      ..purchaseFinanceTransactionId = primaryFinanceId
      ..isActive = true
      ..isSold = false
      ..createdAt = now
      ..updatedAt = now;
    final id = await isar.writeTxn(() => isar.assetRecords.put(record));
    final creditCardFinanceId = primaryAccount.isCreditCard
        ? primaryFinanceId
        : secondaryFinanceId;
    if (installmentCount != null &&
        creditCardAccount != null &&
        creditCardAmount != null &&
        creditCardFinanceId != null) {
      await CreditCardInstallmentService.createInstallmentsForExpense(
        financeTransactionId: creditCardFinanceId,
        creditCardAccount: creditCardAccount,
        transactionDate: acquisitionDate,
        totalAmount: creditCardAmount,
        installmentCount: installmentCount,
      );
    }
    return id;
  }

  static Future<void> sell({
    required int assetId,
    required int incomeAccountId,
    required int incomeCategoryId,
    required double saleValue,
    required DateTime saleDate,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    await _migrateLegacyJsonIfNeeded();
    final isar = IsarService.isar;
    final current = await isar.assetRecords.get(assetId);
    if (current == null) {
      throw Exception('Varlık kaydı bulunamadı.');
    }
    if (!current.isActive) {
      throw Exception('Pasif varlık satılamaz.');
    }
    final financeId = await FinanceTransactionService.addIncomeAndGetId(
      accountId: incomeAccountId,
      categoryId: incomeCategoryId,
      amount: saleValue,
      date: saleDate,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );
    current
      ..saleValue = saleValue
      ..saleDate = saleDate
      ..incomeAccountId = incomeAccountId
      ..incomeCategoryId = incomeCategoryId
      ..saleFinanceTransactionId = financeId
      ..isActive = false
      ..isSold = true
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.assetRecords.put(current));
  }

  static Future<void> updateDefinition({
    required int assetId,
    required String assetType,
    required String name,
    String? areaSquareMeters,
    String? address,
    String? brand,
    String? model,
    String? plate,
    String? description,
    String? currentValueInput,
    required bool isActive,
  }) async {
    await _migrateLegacyJsonIfNeeded();
    final isar = IsarService.isar;
    final current = await isar.assetRecords.get(assetId);
    if (current == null) {
      throw Exception('Varlık kaydı bulunamadı.');
    }
    final normalizedCurrentValue = _normalize(currentValueInput);
    if (!isActive && normalizedCurrentValue != null) {
      throw Exception('Pasif varlık için güncel değer girilemez.');
    }
    current
      ..assetType = assetType
      ..name = name.trim()
      ..areaSquareMeters = _normalize(areaSquareMeters)
      ..address = _normalize(address)
      ..brand = _normalize(brand)
      ..model = _normalize(model)
      ..plate = _normalize(plate)
      ..description = _normalize(description)
      ..currentValueInput = normalizedCurrentValue
      ..isActive = isActive
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.assetRecords.put(current));
  }

  static Future<void> setActive(int assetId, bool value) async {
    await _migrateLegacyJsonIfNeeded();
    final isar = IsarService.isar;
    final item = await isar.assetRecords.get(assetId);
    if (item == null) return;
    item
      ..isActive = value
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.assetRecords.put(item));
  }

  static String? _normalize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static Future<void> _migrateLegacyJsonIfNeeded() async {
    final isar = IsarService.isar;
    final existingCount = await isar.assetRecords.where().count();
    if (existingCount > 0) return;
    final file = await _file();
    if (!await file.exists()) return;
    final raw = jsonDecode(await file.readAsString());
    if (raw is! List) return;
    final items = raw
        .whereType<Map>()
        .map((item) => AssetRecord.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    if (items.isEmpty) {
      await file.delete();
      return;
    }
    await isar.writeTxn(() async {
      for (final item in items) {
        await isar.assetRecords.put(item);
      }
    });
    await file.delete();
  }

  static Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$_fileName');
  }
}
