import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/subscription_definition.dart';

class SubscriptionDefinitionService {
  static const allowedTypes = <String>[
    'electricity',
    'water',
    'natural_gas',
    'phone',
    'internet',
    'mobile_line',
    'streaming',
    'digital_service',
    'insurance',
    'dues',
    'maintenance',
    'loan',
    'rent',
    'other',
  ];
  static const allowedPaymentTypes = <String>[
    'fixed',
    'variable',
  ];
  static const allowedDuePeriods = <String>[
    'monthly',
    'yearly',
  ];

  static void _validate(SubscriptionDefinition item) {
    item.name = item.name.trim();
    item.paymentType = item.paymentType.trim().toLowerCase();
    item.duePeriod = item.duePeriod.trim().toLowerCase();
    item.providerName = item.providerName.trim();
    item.subscriberNumber = item.subscriberNumber?.trim().isEmpty == true
        ? null
        : item.subscriberNumber?.trim();
    item.note = item.note?.trim().isEmpty == true ? null : item.note?.trim();

    if (item.name.isEmpty) {
      throw Exception('Sabit gider adı zorunludur.');
    }
    if (item.providerName.isEmpty) {
      throw Exception('Sağlayıcı / kurum zorunludur.');
    }
    if (!allowedTypes.contains(item.type)) {
      throw Exception('Geçersiz sabit odeme türü.');
    }
    if (!allowedPaymentTypes.contains(item.paymentType)) {
      throw Exception('Geçersiz ödeme türü.');
    }
    if (!allowedDuePeriods.contains(item.duePeriod)) {
      throw Exception('Geçersiz son ödeme periyodu.');
    }
    final defaultAmount = item.defaultAmount;
    if (defaultAmount != null && defaultAmount <= 0) {
      throw Exception('Varsayılan tutar 0\'dan büyük olmalıdır.');
    }
    if (item.paymentType == 'fixed' && defaultAmount == null) {
      throw Exception('Sabit tutarlı giderde varsayılan tutar zorunludur.');
    }
    if (item.paymentType == 'variable') {
      item.defaultAmount = null;
    }
    final dueDay = item.dueDay;
    if (dueDay != null && (dueDay < 1 || dueDay > 31)) {
      throw Exception('Son ödeme günü 1 ile 31 arasında olmalıdır.');
    }
    final dueMonth = item.dueMonth;
    if (dueMonth != null && (dueMonth < 1 || dueMonth > 12)) {
      throw Exception('Son ödeme ayı 1 ile 12 arasında olmalıdır.');
    }
    if (item.duePeriod == 'yearly' && dueDay != null && dueMonth == null) {
      throw Exception('Yıllık son ödeme tarihi için ay seçilmelidir.');
    }
  }

  static bool isValidPaymentType(String? value) {
    if (value == null) return false;
    return allowedPaymentTypes.contains(value.trim().toLowerCase());
  }

  static bool isValidDuePeriod(String? value) {
    if (value == null) return false;
    return allowedDuePeriods.contains(value.trim().toLowerCase());
  }

  static void normalizeLegacyFields(SubscriptionDefinition item) {
    final normalizedPaymentType = item.paymentType.trim().toLowerCase();
    if (!allowedPaymentTypes.contains(normalizedPaymentType)) {
      item.paymentType = 'variable';
    } else {
      item.paymentType = normalizedPaymentType;
    }

    final normalizedDuePeriod = item.duePeriod.trim().toLowerCase();
    if (!allowedDuePeriods.contains(normalizedDuePeriod)) {
      item.duePeriod = 'monthly';
    } else {
      item.duePeriod = normalizedDuePeriod;
    }

    if (item.paymentType == 'variable') {
      item.defaultAmount = null;
    }

    final dueDay = item.dueDay;
    if (dueDay != null && (dueDay < 1 || dueDay > 31)) {
      item.dueDay = null;
    }
    final dueMonth = item.dueMonth;
    if (dueMonth != null && (dueMonth < 1 || dueMonth > 12)) {
      item.dueMonth = null;
    }
    if (item.duePeriod == 'monthly') {
      item.dueMonth = null;
    }
    if (item.dueDay == null) {
      item.dueMonth = null;
    }
  }

  static Future<List<SubscriptionDefinition>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.subscriptionDefinitions.where().findAll();
    var needsSave = false;
    for (final item in items) {
      final beforePaymentType = item.paymentType;
      final beforeDuePeriod = item.duePeriod;
      final beforeDefaultAmount = item.defaultAmount;
      final beforeDueDay = item.dueDay;
      final beforeDueMonth = item.dueMonth;
      normalizeLegacyFields(item);
      if (item.paymentType != beforePaymentType ||
          item.duePeriod != beforeDuePeriod ||
          item.defaultAmount != beforeDefaultAmount ||
          item.dueDay != beforeDueDay ||
          item.dueMonth != beforeDueMonth) {
        item.updatedAt = DateTime.now();
        needsSave = true;
      }
    }
    if (needsSave) {
      await isar.writeTxn(() async {
        for (final item in items) {
          await isar.subscriptionDefinitions.put(item);
        }
      });
    }
    items.sort((a, b) {
      final activeCompare = (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0);
      if (activeCompare != 0) return activeCompare;
      return a.name.compareTo(b.name);
    });
    return items;
  }

  static Future<List<SubscriptionDefinition>> getActive() async {
    final items = await getAll();
    return items.where((item) => item.isActive).toList(growable: false);
  }

  static Future<void> add(SubscriptionDefinition item) async {
    final isar = IsarService.isar;
    normalizeLegacyFields(item);
    _validate(item);
    item
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.subscriptionDefinitions.put(item);
    });
  }

  static Future<void> update(SubscriptionDefinition item) async {
    final isar = IsarService.isar;
    normalizeLegacyFields(item);
    _validate(item);
    item.updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.subscriptionDefinitions.put(item);
    });
  }

  static Future<void> setActive(int id, bool value) async {
    final isar = IsarService.isar;
    final item = await isar.subscriptionDefinitions.get(id);
    if (item == null) return;

    await isar.writeTxn(() async {
      item
        ..isActive = value
        ..updatedAt = DateTime.now();
      await isar.subscriptionDefinitions.put(item);
    });
  }

  static Future<void> delete(int id) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.subscriptionDefinitions.delete(id);
    });
  }
}
