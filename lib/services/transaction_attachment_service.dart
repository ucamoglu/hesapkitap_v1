import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/transaction_attachment.dart';

class TransactionAttachmentService {
  static Future<void> addMany({
    required String ownerType,
    required int ownerId,
    required List<List<int>> images,
  }) async {
    if (images.isEmpty) return;

    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      for (final bytes in images) {
        if (bytes.isEmpty) continue;
        final item = TransactionAttachment()
          ..ownerType = ownerType
          ..ownerId = ownerId
          ..imageBytes = bytes
          ..createdAt = DateTime.now();
        await isar.transactionAttachments.put(item);
      }
    });
  }

  static Future<List<TransactionAttachment>> getByOwner({
    required String ownerType,
    required int ownerId,
  }) async {
    final isar = IsarService.isar;
    final items = await isar.transactionAttachments
        .where()
        .filter()
        .ownerTypeEqualTo(ownerType)
        .and()
        .ownerIdEqualTo(ownerId)
        .findAll();
    return items.where((e) => e.imageBytes.isNotEmpty).toList();
  }

  static Future<Map<String, int>> getCountMap() async {
    final isar = IsarService.isar;
    final all = await isar.transactionAttachments.where().findAll();
    final map = <String, int>{};
    for (final a in all) {
      if (a.imageBytes.isEmpty) continue;
      final key = '${a.ownerType}:${a.ownerId}';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  static Future<void> deleteByOwner({
    required String ownerType,
    required int ownerId,
  }) async {
    final isar = IsarService.isar;
    final ids = await isar.transactionAttachments
        .where()
        .filter()
        .ownerTypeEqualTo(ownerType)
        .and()
        .ownerIdEqualTo(ownerId)
        .idProperty()
        .findAll();

    if (ids.isEmpty) return;

    await isar.writeTxn(() async {
      for (final id in ids) {
        await isar.transactionAttachments.delete(id);
      }
    });
  }
}
