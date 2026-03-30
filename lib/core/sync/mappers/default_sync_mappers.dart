import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../database/isar_service.dart';
import '../../../models/account.dart';
import '../../../models/cari_card.dart';
import '../../../models/cari_transaction.dart';
import '../../../models/category.dart';
import '../../../models/expense_plan.dart';
import '../../../models/finance_transaction.dart';
import '../../../models/income_category.dart';
import '../../../models/income_plan.dart';
import '../../../models/investment_transaction.dart';
import '../../../models/subscription_definition.dart';
import '../../../models/tracked_crypto.dart';
import '../../../models/tracked_crypto_state.dart';
import '../../../models/tracked_currency.dart';
import '../../../models/tracked_currency_state.dart';
import '../../../models/tracked_metal.dart';
import '../../../models/tracked_metal_state.dart';
import '../../../models/tracked_stock.dart';
import '../../../models/tracked_stock_state.dart';
import '../../../models/transaction_attachment.dart';
import '../../../models/transfer_transaction.dart';
import '../../../models/user_profile.dart';
import '../api/remote_sync_record.dart';
import '../sync_record.dart';
import 'sync_entity_mapper.dart';

List<SyncEntityMapper> buildDefaultSyncMappers() {
  // Tum temel domain tipleri tek bir registry uzerinden sync engine'e baglanir.
  return <SyncEntityMapper>[
    _AccountSyncMapper(),
    _CategorySyncMapper(),
    _IncomeCategorySyncMapper(),
    _FinanceTransactionSyncMapper(),
    _InvestmentTransactionSyncMapper(),
    _ExpensePlanSyncMapper(),
    _IncomePlanSyncMapper(),
    _TransferTransactionSyncMapper(),
    _UserProfileSyncMapper(),
    _TrackedCurrencySyncMapper(),
    _TrackedCurrencyStateSyncMapper(),
    _TrackedMetalSyncMapper(),
    _TrackedMetalStateSyncMapper(),
    _TrackedStockSyncMapper(),
    _TrackedStockStateSyncMapper(),
    _TrackedCryptoSyncMapper(),
    _TrackedCryptoStateSyncMapper(),
    _CariCardSyncMapper(),
    _SubscriptionDefinitionSyncMapper(),
    _CariTransactionSyncMapper(),
    _TransactionAttachmentSyncMapper(),
  ];
}

DateTime _parseDate(Object? value) => DateTime.parse(value as String).toLocal();

DateTime? _parseDateOrNull(Object? value) {
  if (value == null) return null;
  return DateTime.parse(value as String).toLocal();
}

String _encodeBytes(List<int>? value) => value == null ? '' : base64Encode(value);

List<int>? _decodeBytes(String? value) {
  if (value == null || value.isEmpty) return null;
  return base64Decode(value);
}

RemoteSyncRecord _record({
  required String entityType,
  required SyncRecord metadata,
  required Map<String, dynamic> payload,
}) {
  // Her mapper ayni remote zarf formatini kullansin diye ortak helper.
  return RemoteSyncRecord(
    entityType: entityType,
    remoteId: metadata.remoteId ?? '',
    version: metadata.version,
    updatedAt: metadata.updatedAt.toUtc(),
    deletedAt: metadata.deletedAt?.toUtc(),
    payload: payload,
  );
}

int? _resolveRequiredRef(
  SyncReferenceResolver resolver,
  Map<String, dynamic> payload,
  String payloadKey,
  String entityType,
) {
  // Iliskili kayitlar payload icinde local id yerine remoteId ile tasinir.
  final remoteId = payload[payloadKey] as String?;
  if (remoteId == null || remoteId.isEmpty) return null;
  return resolver.localIdFor(entityType, remoteId);
}

abstract class _ScalarMapper<T> implements SyncEntityMapper {
  Isar get _isar => IsarService.isar;

  @override
  Future<RemoteSyncRecord?> exportRecord({
    required SyncRecord metadata,
    required SyncReferenceResolver resolver,
  }) async {
    // Her mapper once yerel kaydi bulur, sonra onu cloud payload'ina cevirir.
    final item = await load(metadata.localId);
    if (item == null) return null;
    return _record(
      entityType: entityType,
      metadata: metadata,
      payload: await toPayload(item, resolver),
    );
  }

  Future<T?> load(int localId);

  Future<Map<String, dynamic>> toPayload(
    T item,
    SyncReferenceResolver resolver,
  );

  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  );

  @override
  Future<SyncImportResult> importRecord({
    required RemoteSyncRecord remote,
    required SyncReferenceResolver resolver,
  }) async {
    return upsertFromRemote(remote, resolver);
  }

  @override
  Future<bool> deleteLocal(int localId) async {
    return false;
  }

  Isar get isar => _isar;
}

class _AccountSyncMapper extends _ScalarMapper<Account> {
  @override
  String get entityType => 'account';

  @override
  Future<Account?> load(int localId) => isar.accounts.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    Account item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'name': item.name,
      'type': item.type,
      'investmentSubtype': item.investmentSubtype,
      'investmentSymbol': item.investmentSymbol,
      'balance': item.balance,
      'isActive': item.isActive,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null ? null : await isar.accounts.get(localId);
    final account = current ?? Account();
    if (current != null) account.id = current.id;
    account
      ..name = remote.payload['name'] as String
      ..type = remote.payload['type'] as String
      ..investmentSubtype = remote.payload['investmentSubtype'] as String?
      ..investmentSymbol = remote.payload['investmentSymbol'] as String?
      ..balance = (remote.payload['balance'] as num?)?.toDouble() ?? 0
      ..isActive = remote.payload['isActive'] as bool? ?? true
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.accounts.put(account));
    return SyncImportResult.applied(id);
  }
}

class _CategorySyncMapper extends _ScalarMapper<Category> {
  @override
  String get entityType => 'category';

  @override
  Future<Category?> load(int localId) => isar.categorys.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    Category item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'name': item.name,
      'type': item.type,
      'parentRemoteId': item.parentId == null
          ? null
          : resolver.remoteIdFor(entityType, item.parentId!),
      'isActive': item.isActive,
      'isSystemGenerated': item.isSystemGenerated,
      'systemKey': item.systemKey,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final parentRemoteId = remote.payload['parentRemoteId'] as String?;
    final parentId = parentRemoteId == null || parentRemoteId.isEmpty
        ? null
        : resolver.localIdFor(entityType, parentRemoteId);
    if (parentRemoteId != null && parentId == null) {
      return SyncImportResult.conflict('Parent category reference unresolved');
    }
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null ? null : await isar.categorys.get(localId);
    final item = current ?? Category();
    if (current != null) item.id = current.id;
    item
      ..name = remote.payload['name'] as String
      ..type = remote.payload['type'] as String
      ..parentId = parentId
      ..isActive = remote.payload['isActive'] as bool? ?? true
      ..isSystemGenerated = remote.payload['isSystemGenerated'] as bool? ?? false
      ..systemKey = remote.payload['systemKey'] as String?
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.categorys.put(item));
    return SyncImportResult.applied(id);
  }
}

class _IncomeCategorySyncMapper extends _ScalarMapper<IncomeCategory> {
  @override
  String get entityType => 'income_category';

  @override
  Future<IncomeCategory?> load(int localId) => isar.incomeCategorys.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    IncomeCategory item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'name': item.name,
      'isActive': item.isActive,
      'isSystemGenerated': item.isSystemGenerated,
      'systemKey': item.systemKey,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current =
        localId == null ? null : await isar.incomeCategorys.get(localId);
    final item = current ?? IncomeCategory();
    if (current != null) item.id = current.id;
    item
      ..name = remote.payload['name'] as String
      ..isActive = remote.payload['isActive'] as bool? ?? true
      ..isSystemGenerated = remote.payload['isSystemGenerated'] as bool? ?? false
      ..systemKey = remote.payload['systemKey'] as String?
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.incomeCategorys.put(item));
    return SyncImportResult.applied(id);
  }
}

class _SubscriptionDefinitionSyncMapper
    extends _ScalarMapper<SubscriptionDefinition> {
  @override
  String get entityType => 'subscription_definition';

  @override
  Future<SubscriptionDefinition?> load(int localId) =>
      isar.subscriptionDefinitions.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    SubscriptionDefinition item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'name': item.name,
      'type': item.type,
      'paymentType': item.paymentType,
      'duePeriod': item.duePeriod,
      'providerName': item.providerName,
      'subscriberNumber': item.subscriberNumber,
      'paymentAccountRemoteId': item.paymentAccountId == null
          ? null
          : resolver.remoteIdFor('account', item.paymentAccountId!),
      'defaultExpenseCategoryRemoteId': item.defaultExpenseCategoryId == null
          ? null
          : resolver.remoteIdFor('category', item.defaultExpenseCategoryId!),
      'defaultAmount': item.defaultAmount,
      'dueDay': item.dueDay,
      'dueMonth': item.dueMonth,
      'note': item.note,
      'isAutoPay': item.isAutoPay,
      'isActive': item.isActive,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
      'updatedAt': item.updatedAt?.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final paymentAccountRemoteId =
        remote.payload['paymentAccountRemoteId'] as String?;
    final paymentAccountId =
        paymentAccountRemoteId == null || paymentAccountRemoteId.isEmpty
            ? null
            : resolver.localIdFor('account', paymentAccountRemoteId);
    if (paymentAccountRemoteId != null && paymentAccountId == null) {
      return SyncImportResult.conflict(
        'Subscription payment account reference unresolved',
      );
    }

    final defaultCategoryRemoteId =
        remote.payload['defaultExpenseCategoryRemoteId'] as String?;
    final defaultCategoryId =
        defaultCategoryRemoteId == null || defaultCategoryRemoteId.isEmpty
            ? null
            : resolver.localIdFor('category', defaultCategoryRemoteId);
    if (defaultCategoryRemoteId != null && defaultCategoryId == null) {
      return SyncImportResult.conflict(
        'Subscription category reference unresolved',
      );
    }

    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null
        ? null
        : await isar.subscriptionDefinitions.get(localId);
    final item = current ?? SubscriptionDefinition();
    if (current != null) item.id = current.id;
    item
      ..name = remote.payload['name'] as String
      ..type = remote.payload['type'] as String
      ..paymentType = remote.payload['paymentType'] as String? ?? 'variable'
      ..duePeriod = remote.payload['duePeriod'] as String? ?? 'monthly'
      ..providerName = remote.payload['providerName'] as String
      ..subscriberNumber = remote.payload['subscriberNumber'] as String?
      ..paymentAccountId = paymentAccountId
      ..defaultExpenseCategoryId = defaultCategoryId
      ..defaultAmount = (remote.payload['defaultAmount'] as num?)?.toDouble()
      ..dueDay = remote.payload['dueDay'] as int?
      ..dueMonth = remote.payload['dueMonth'] as int?
      ..note = remote.payload['note'] as String?
      ..isAutoPay = remote.payload['isAutoPay'] as bool? ?? false
      ..isActive = remote.payload['isActive'] as bool? ?? true
      ..createdAt = _parseDate(remote.payload['createdAt'])
      ..updatedAt = _parseDateOrNull(remote.payload['updatedAt']);
    final id = await isar.writeTxn(() => isar.subscriptionDefinitions.put(item));
    return SyncImportResult.applied(id);
  }
}

class _FinanceTransactionSyncMapper extends _ScalarMapper<FinanceTransaction> {
  @override
  String get entityType => 'finance_transaction';

  @override
  Future<FinanceTransaction?> load(int localId) =>
      isar.financeTransactions.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    FinanceTransaction item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'accountRemoteId': resolver.remoteIdFor('account', item.accountId),
      'categoryRemoteId': resolver.remoteIdFor('category', item.categoryId),
      'type': item.type,
      'amount': item.amount,
      'description': item.description,
      'incomePlanRemoteId': item.incomePlanId == null
          ? null
          : resolver.remoteIdFor('income_plan', item.incomePlanId!),
      'expensePlanRemoteId': item.expensePlanId == null
          ? null
          : resolver.remoteIdFor('expense_plan', item.expensePlanId!),
      'date': item.date.toUtc().toIso8601String(),
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final accountId =
        _resolveRequiredRef(resolver, remote.payload, 'accountRemoteId', 'account');
    final categoryId = _resolveRequiredRef(
      resolver,
      remote.payload,
      'categoryRemoteId',
      'category',
    );
    if (accountId == null || categoryId == null) {
      return SyncImportResult.conflict('Finance transaction references unresolved');
    }
    final incomePlanRemoteId = remote.payload['incomePlanRemoteId'] as String?;
    final expensePlanRemoteId = remote.payload['expensePlanRemoteId'] as String?;
    final incomePlanId = incomePlanRemoteId == null || incomePlanRemoteId.isEmpty
        ? null
        : resolver.localIdFor('income_plan', incomePlanRemoteId);
    final expensePlanId =
        expensePlanRemoteId == null || expensePlanRemoteId.isEmpty
            ? null
            : resolver.localIdFor('expense_plan', expensePlanRemoteId);
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current =
        localId == null ? null : await isar.financeTransactions.get(localId);
    final item = current ?? FinanceTransaction();
    if (current != null) item.id = current.id;
    item
      ..accountId = accountId
      ..categoryId = categoryId
      ..type = remote.payload['type'] as String
      ..amount = (remote.payload['amount'] as num).toDouble()
      ..description = remote.payload['description'] as String?
      ..incomePlanId = incomePlanId
      ..expensePlanId = expensePlanId
      ..date = _parseDate(remote.payload['date'])
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.financeTransactions.put(item));
    return SyncImportResult.applied(id);
  }
}

class _InvestmentTransactionSyncMapper
    extends _ScalarMapper<InvestmentTransaction> {
  @override
  String get entityType => 'investment_transaction';

  @override
  Future<InvestmentTransaction?> load(int localId) =>
      isar.investmentTransactions.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    InvestmentTransaction item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'investmentAccountRemoteId':
          resolver.remoteIdFor('account', item.investmentAccountId),
      'cashAccountRemoteId': resolver.remoteIdFor('account', item.cashAccountId),
      'symbol': item.symbol,
      'type': item.type,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'total': item.total,
      'costBasisTotal': item.costBasisTotal,
      'realizedPnl': item.realizedPnl,
      'date': item.date.toUtc().toIso8601String(),
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final investmentAccountId = _resolveRequiredRef(
      resolver,
      remote.payload,
      'investmentAccountRemoteId',
      'account',
    );
    final cashAccountId =
        _resolveRequiredRef(resolver, remote.payload, 'cashAccountRemoteId', 'account');
    if (investmentAccountId == null || cashAccountId == null) {
      return SyncImportResult.conflict('Investment transaction references unresolved');
    }
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current =
        localId == null ? null : await isar.investmentTransactions.get(localId);
    final item = current ?? InvestmentTransaction();
    if (current != null) item.id = current.id;
    item
      ..investmentAccountId = investmentAccountId
      ..cashAccountId = cashAccountId
      ..symbol = remote.payload['symbol'] as String
      ..type = remote.payload['type'] as String
      ..quantity = (remote.payload['quantity'] as num).toDouble()
      ..unitPrice = (remote.payload['unitPrice'] as num).toDouble()
      ..total = (remote.payload['total'] as num).toDouble()
      ..costBasisTotal = (remote.payload['costBasisTotal'] as num?)?.toDouble() ?? 0
      ..realizedPnl = (remote.payload['realizedPnl'] as num?)?.toDouble() ?? 0
      ..date = _parseDate(remote.payload['date'])
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.investmentTransactions.put(item));
    return SyncImportResult.applied(id);
  }
}

class _ExpensePlanSyncMapper extends _ScalarMapper<ExpensePlan> {
  @override
  String get entityType => 'expense_plan';

  @override
  Future<ExpensePlan?> load(int localId) => isar.expensePlans.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    ExpensePlan item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'expenseCategoryRemoteId':
          resolver.remoteIdFor('category', item.expenseCategoryId),
      'accountRemoteId': resolver.remoteIdFor('account', item.accountId),
      'amount': item.amount,
      'description': item.description,
      'periodType': item.periodType,
      'frequency': item.frequency,
      'startDate': item.startDate.toUtc().toIso8601String(),
      'endDate': item.endDate?.toUtc().toIso8601String(),
      'nextDueDate': item.nextDueDate.toUtc().toIso8601String(),
      'isActive': item.isActive,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final categoryId = _resolveRequiredRef(
      resolver,
      remote.payload,
      'expenseCategoryRemoteId',
      'category',
    );
    final accountId =
        _resolveRequiredRef(resolver, remote.payload, 'accountRemoteId', 'account');
    if (categoryId == null || accountId == null) {
      return SyncImportResult.conflict('Expense plan references unresolved');
    }
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null ? null : await isar.expensePlans.get(localId);
    final item = current ?? ExpensePlan();
    if (current != null) item.id = current.id;
    item
      ..expenseCategoryId = categoryId
      ..accountId = accountId
      ..amount = (remote.payload['amount'] as num).toDouble()
      ..description = remote.payload['description'] as String?
      ..periodType = remote.payload['periodType'] as String
      ..frequency = remote.payload['frequency'] as int? ?? 1
      ..startDate = _parseDate(remote.payload['startDate'])
      ..endDate = _parseDateOrNull(remote.payload['endDate'])
      ..nextDueDate = _parseDate(remote.payload['nextDueDate'])
      ..isActive = remote.payload['isActive'] as bool? ?? true
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.expensePlans.put(item));
    return SyncImportResult.applied(id);
  }
}

class _IncomePlanSyncMapper extends _ScalarMapper<IncomePlan> {
  @override
  String get entityType => 'income_plan';

  @override
  Future<IncomePlan?> load(int localId) => isar.incomePlans.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    IncomePlan item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'incomeCategoryRemoteId':
          resolver.remoteIdFor('income_category', item.incomeCategoryId),
      'accountRemoteId': resolver.remoteIdFor('account', item.accountId),
      'amount': item.amount,
      'description': item.description,
      'periodType': item.periodType,
      'frequency': item.frequency,
      'startDate': item.startDate.toUtc().toIso8601String(),
      'endDate': item.endDate?.toUtc().toIso8601String(),
      'nextDueDate': item.nextDueDate.toUtc().toIso8601String(),
      'isActive': item.isActive,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final categoryId = _resolveRequiredRef(
      resolver,
      remote.payload,
      'incomeCategoryRemoteId',
      'income_category',
    );
    final accountId =
        _resolveRequiredRef(resolver, remote.payload, 'accountRemoteId', 'account');
    if (categoryId == null || accountId == null) {
      return SyncImportResult.conflict('Income plan references unresolved');
    }
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null ? null : await isar.incomePlans.get(localId);
    final item = current ?? IncomePlan();
    if (current != null) item.id = current.id;
    item
      ..incomeCategoryId = categoryId
      ..accountId = accountId
      ..amount = (remote.payload['amount'] as num).toDouble()
      ..description = remote.payload['description'] as String?
      ..periodType = remote.payload['periodType'] as String
      ..frequency = remote.payload['frequency'] as int? ?? 1
      ..startDate = _parseDate(remote.payload['startDate'])
      ..endDate = _parseDateOrNull(remote.payload['endDate'])
      ..nextDueDate = _parseDate(remote.payload['nextDueDate'])
      ..isActive = remote.payload['isActive'] as bool? ?? true
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.incomePlans.put(item));
    return SyncImportResult.applied(id);
  }
}

class _TransferTransactionSyncMapper extends _ScalarMapper<TransferTransaction> {
  @override
  String get entityType => 'transfer_transaction';

  @override
  Future<TransferTransaction?> load(int localId) =>
      isar.transferTransactions.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TransferTransaction item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'fromAccountRemoteId': resolver.remoteIdFor('account', item.fromAccountId),
      'toAccountRemoteId': resolver.remoteIdFor('account', item.toAccountId),
      'amount': item.amount,
      'description': item.description,
      'date': item.date.toUtc().toIso8601String(),
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final fromAccountId =
        _resolveRequiredRef(resolver, remote.payload, 'fromAccountRemoteId', 'account');
    final toAccountId =
        _resolveRequiredRef(resolver, remote.payload, 'toAccountRemoteId', 'account');
    if (fromAccountId == null || toAccountId == null) {
      return SyncImportResult.conflict('Transfer references unresolved');
    }
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current =
        localId == null ? null : await isar.transferTransactions.get(localId);
    final item = current ?? TransferTransaction();
    if (current != null) item.id = current.id;
    item
      ..fromAccountId = fromAccountId
      ..toAccountId = toAccountId
      ..amount = (remote.payload['amount'] as num).toDouble()
      ..description = remote.payload['description'] as String?
      ..date = _parseDate(remote.payload['date'])
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.transferTransactions.put(item));
    return SyncImportResult.applied(id);
  }
}

class _UserProfileSyncMapper extends _ScalarMapper<UserProfile> {
  @override
  String get entityType => 'user_profile';

  @override
  Future<UserProfile?> load(int localId) => isar.userProfiles.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    UserProfile item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'firstName': item.firstName,
      'lastName': item.lastName,
      'birthDate': item.birthDate?.toUtc().toIso8601String(),
      'email': item.email,
      'phone': item.phone,
      'photoBytes': _encodeBytes(item.photoBytes),
      'createdAt': item.createdAt.toUtc().toIso8601String(),
      'updatedAt': item.updatedAt?.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(
    RemoteSyncRecord remote,
    SyncReferenceResolver resolver,
  ) async {
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null
        ? await isar.userProfiles.where().findFirst()
        : await isar.userProfiles.get(localId);
    final item = current ?? UserProfile();
    if (current != null) item.id = current.id;
    item
      ..firstName = remote.payload['firstName'] as String
      ..lastName = remote.payload['lastName'] as String
      ..birthDate = _parseDateOrNull(remote.payload['birthDate'])
      ..email = remote.payload['email'] as String?
      ..phone = remote.payload['phone'] as String?
      ..photoBytes = _decodeBytes(remote.payload['photoBytes'] as String?)
      ..createdAt = _parseDate(remote.payload['createdAt'])
      ..updatedAt = _parseDateOrNull(remote.payload['updatedAt']);
    final id = await isar.writeTxn(() => isar.userProfiles.put(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedCurrencySyncMapper extends _ScalarMapper<TrackedCurrency> {
  @override
  String get entityType => 'tracked_currency';

  @override
  Future<TrackedCurrency?> load(int localId) => isar.trackedCurrencys.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedCurrency item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'name': item.name,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null
        ? await isar.trackedCurrencys.getByCode(code)
        : await isar.trackedCurrencys.get(localId);
    final item = current ?? TrackedCurrency();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..name = remote.payload['name'] as String
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.trackedCurrencys.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedCurrencyStateSyncMapper extends _ScalarMapper<TrackedCurrencyState> {
  @override
  String get entityType => 'tracked_currency_state';

  @override
  Future<TrackedCurrencyState?> load(int localId) =>
      isar.trackedCurrencyStates.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedCurrencyState item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'isActive': item.isActive,
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final current = await isar.trackedCurrencyStates.getByCode(code);
    final item = current ?? TrackedCurrencyState();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..isActive = remote.payload['isActive'] as bool? ?? true;
    final id =
        await isar.writeTxn(() => isar.trackedCurrencyStates.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedMetalSyncMapper extends _ScalarMapper<TrackedMetal> {
  @override
  String get entityType => 'tracked_metal';

  @override
  Future<TrackedMetal?> load(int localId) => isar.trackedMetals.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedMetal item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'name': item.name,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final current = await isar.trackedMetals.getByCode(code);
    final item = current ?? TrackedMetal();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..name = remote.payload['name'] as String
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.trackedMetals.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedMetalStateSyncMapper extends _ScalarMapper<TrackedMetalState> {
  @override
  String get entityType => 'tracked_metal_state';

  @override
  Future<TrackedMetalState?> load(int localId) =>
      isar.trackedMetalStates.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedMetalState item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'isActive': item.isActive,
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final current = await isar.trackedMetalStates.getByCode(code);
    final item = current ?? TrackedMetalState();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..isActive = remote.payload['isActive'] as bool? ?? true;
    final id = await isar.writeTxn(() => isar.trackedMetalStates.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedStockSyncMapper extends _ScalarMapper<TrackedStock> {
  @override
  String get entityType => 'tracked_stock';

  @override
  Future<TrackedStock?> load(int localId) => isar.trackedStocks.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedStock item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'name': item.name,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final current = await isar.trackedStocks.getByCode(code);
    final item = current ?? TrackedStock();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..name = remote.payload['name'] as String
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.trackedStocks.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedStockStateSyncMapper extends _ScalarMapper<TrackedStockState> {
  @override
  String get entityType => 'tracked_stock_state';

  @override
  Future<TrackedStockState?> load(int localId) =>
      isar.trackedStockStates.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedStockState item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'isActive': item.isActive,
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final current = await isar.trackedStockStates.getByCode(code);
    final item = current ?? TrackedStockState();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..isActive = remote.payload['isActive'] as bool? ?? true;
    final id = await isar.writeTxn(() => isar.trackedStockStates.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedCryptoSyncMapper extends _ScalarMapper<TrackedCrypto> {
  @override
  String get entityType => 'tracked_crypto';

  @override
  Future<TrackedCrypto?> load(int localId) => isar.trackedCryptos.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedCrypto item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'name': item.name,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final current = await isar.trackedCryptos.getByCode(code);
    final item = current ?? TrackedCrypto();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..name = remote.payload['name'] as String
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.trackedCryptos.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _TrackedCryptoStateSyncMapper extends _ScalarMapper<TrackedCryptoState> {
  @override
  String get entityType => 'tracked_crypto_state';

  @override
  Future<TrackedCryptoState?> load(int localId) =>
      isar.trackedCryptoStates.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TrackedCryptoState item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'code': item.code,
      'isActive': item.isActive,
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final code = remote.payload['code'] as String;
    final current = await isar.trackedCryptoStates.getByCode(code);
    final item = current ?? TrackedCryptoState();
    if (current != null) item.id = current.id;
    item
      ..code = code
      ..isActive = remote.payload['isActive'] as bool? ?? true;
    final id =
        await isar.writeTxn(() => isar.trackedCryptoStates.putByCode(item));
    return SyncImportResult.applied(id);
  }
}

class _CariCardSyncMapper extends _ScalarMapper<CariCard> {
  @override
  String get entityType => 'cari_card';

  @override
  Future<CariCard?> load(int localId) => isar.cariCards.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    CariCard item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'type': item.type,
      'fullName': item.fullName,
      'title': item.title,
      'phone': item.phone,
      'email': item.email,
      'note': item.note,
      'photoBytes': _encodeBytes(item.photoBytes),
      'currencyType': item.currencyType,
      'foreignMarketType': item.foreignMarketType,
      'foreignCode': item.foreignCode,
      'foreignName': item.foreignName,
      'isActive': item.isActive,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null ? null : await isar.cariCards.get(localId);
    final item = current ?? CariCard();
    if (current != null) item.id = current.id;
    item
      ..type = remote.payload['type'] as String
      ..fullName = remote.payload['fullName'] as String?
      ..title = remote.payload['title'] as String?
      ..phone = remote.payload['phone'] as String?
      ..email = remote.payload['email'] as String?
      ..note = remote.payload['note'] as String?
      ..photoBytes = _decodeBytes(remote.payload['photoBytes'] as String?)
      ..currencyType = remote.payload['currencyType'] as String? ?? 'tl'
      ..foreignMarketType = remote.payload['foreignMarketType'] as String?
      ..foreignCode = remote.payload['foreignCode'] as String?
      ..foreignName = remote.payload['foreignName'] as String?
      ..isActive = remote.payload['isActive'] as bool? ?? true
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.cariCards.put(item));
    return SyncImportResult.applied(id);
  }
}

class _CariTransactionSyncMapper extends _ScalarMapper<CariTransaction> {
  @override
  String get entityType => 'cari_transaction';

  @override
  Future<CariTransaction?> load(int localId) => isar.cariTransactions.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    CariTransaction item,
    SyncReferenceResolver resolver,
  ) async {
    return {
      'cariCardRemoteId': resolver.remoteIdFor('cari_card', item.cariCardId),
      'accountRemoteId': resolver.remoteIdFor('account', item.accountId),
      'type': item.type,
      'amount': item.amount,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'description': item.description,
      'date': item.date.toUtc().toIso8601String(),
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final cariCardId =
        _resolveRequiredRef(resolver, remote.payload, 'cariCardRemoteId', 'cari_card');
    final accountId =
        _resolveRequiredRef(resolver, remote.payload, 'accountRemoteId', 'account');
    if (cariCardId == null || accountId == null) {
      return SyncImportResult.conflict('Cari transaction references unresolved');
    }
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current =
        localId == null ? null : await isar.cariTransactions.get(localId);
    final item = current ?? CariTransaction();
    if (current != null) item.id = current.id;
    item
      ..cariCardId = cariCardId
      ..accountId = accountId
      ..type = remote.payload['type'] as String
      ..amount = (remote.payload['amount'] as num).toDouble()
      ..quantity = (remote.payload['quantity'] as num?)?.toDouble()
      ..unitPrice = (remote.payload['unitPrice'] as num?)?.toDouble()
      ..description = remote.payload['description'] as String?
      ..date = _parseDate(remote.payload['date'])
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.cariTransactions.put(item));
    return SyncImportResult.applied(id);
  }
}

class _TransactionAttachmentSyncMapper
    extends _ScalarMapper<TransactionAttachment> {
  @override
  String get entityType => 'transaction_attachment';

  @override
  Future<TransactionAttachment?> load(int localId) =>
      isar.transactionAttachments.get(localId);

  @override
  Future<Map<String, dynamic>> toPayload(
    TransactionAttachment item,
    SyncReferenceResolver resolver,
  ) async {
    final targetEntityType = switch (item.ownerType) {
      'finance' => 'finance_transaction',
      'cari' => 'cari_transaction',
      'investment' => 'investment_transaction',
      _ => '',
    };
    return {
      'ownerType': item.ownerType,
      'ownerRemoteId': targetEntityType.isEmpty
          ? null
          : resolver.remoteIdFor(targetEntityType, item.ownerId),
      'imageBytes': base64Encode(item.imageBytes),
      'createdAt': item.createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<SyncImportResult> upsertFromRemote(RemoteSyncRecord remote, SyncReferenceResolver resolver) async {
    final ownerType = remote.payload['ownerType'] as String;
    final targetEntityType = switch (ownerType) {
      'finance' => 'finance_transaction',
      'cari' => 'cari_transaction',
      'investment' => 'investment_transaction',
      _ => '',
    };
    if (targetEntityType.isEmpty) {
      return SyncImportResult.conflict('Attachment owner type unsupported');
    }
    final ownerRemoteId = remote.payload['ownerRemoteId'] as String?;
    if (ownerRemoteId == null || ownerRemoteId.isEmpty) {
      return SyncImportResult.conflict('Attachment owner reference missing');
    }
    final ownerId = resolver.localIdFor(targetEntityType, ownerRemoteId);
    if (ownerId == null) {
      return SyncImportResult.conflict('Attachment owner reference unresolved');
    }
    final localId = resolver.localIdFor(entityType, remote.remoteId);
    final current = localId == null
        ? null
        : await isar.transactionAttachments.get(localId);
    final item = current ?? TransactionAttachment();
    if (current != null) item.id = current.id;
    item
      ..ownerType = ownerType
      ..ownerId = ownerId
      ..imageBytes = base64Decode(remote.payload['imageBytes'] as String)
      ..createdAt = _parseDate(remote.payload['createdAt']);
    final id = await isar.writeTxn(() => isar.transactionAttachments.put(item));
    return SyncImportResult.applied(id);
  }
}
