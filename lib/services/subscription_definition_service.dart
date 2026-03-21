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
  ];

  static void _validate(SubscriptionDefinition item) {
    item.name = item.name.trim();
    item.providerName = item.providerName.trim();
    item.subscriberNumber = item.subscriberNumber?.trim().isEmpty == true
        ? null
        : item.subscriberNumber?.trim();
    item.note = item.note?.trim().isEmpty == true ? null : item.note?.trim();

    if (item.name.isEmpty) {
      throw Exception('Abonelik adı zorunludur.');
    }
    if (item.providerName.isEmpty) {
      throw Exception('Sağlayıcı / kurum zorunludur.');
    }
    if (!allowedTypes.contains(item.type)) {
      throw Exception('Geçersiz abonelik türü.');
    }
    final dueDay = item.dueDay;
    if (dueDay != null && (dueDay < 1 || dueDay > 31)) {
      throw Exception('Son ödeme günü 1 ile 31 arasında olmalıdır.');
    }
  }

  static Future<List<SubscriptionDefinition>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.subscriptionDefinitions.where().findAll();
    items.sort((a, b) {
      final activeCompare = (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0);
      if (activeCompare != 0) return activeCompare;
      return a.name.compareTo(b.name);
    });
    return items;
  }

  static Future<void> add(SubscriptionDefinition item) async {
    final isar = IsarService.isar;
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
