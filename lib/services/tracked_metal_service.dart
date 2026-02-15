import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/market_rate_item.dart';
import '../models/tracked_metal.dart';
import '../models/tracked_metal_state.dart';

class TrackedMetalItem {
  final TrackedMetal metal;
  final bool isActive;

  const TrackedMetalItem({
    required this.metal,
    required this.isActive,
  });

  String get code => metal.code;
  String get name => metal.name;
}

class TrackedMetalService {
  static const Map<String, String> _displayNameMap = {
    'HA': 'Has Altın',
    'HG': 'Hamit Altın',
    'GA': 'Gram Altın',
    'GAG': 'Gram Gümüş',
    'C': 'Çeyrek Altın',
    'Y': 'Yarım Altın',
    'T': 'Tam Altın',
    'XAU': 'Altın',
    'XAG': 'Gümüş',
    'XPT': 'Platin',
    'XPD': 'Paladyum',
    'KULCEALTIN': 'Külçe Altın',
  };

  static String canonicalName(String code, String currentName) {
    final upper = code.toUpperCase();
    final mapped = _displayNameMap[upper];
    if (mapped != null) return mapped;
    return currentName.trim().isEmpty ? upper : currentName;
  }

  static Future<TrackedMetalItem?> getByCode(String code) async {
    final isar = IsarService.isar;
    final metal = await isar.trackedMetals.getByCode(code);
    if (metal == null) return null;
    final state = await isar.trackedMetalStates.getByCode(code);
    final name = canonicalName(metal.code, metal.name);
    return TrackedMetalItem(
      metal: (TrackedMetal()
        ..id = metal.id
        ..code = metal.code
        ..name = name
        ..createdAt = metal.createdAt),
      isActive: state?.isActive ?? true,
    );
  }

  static Future<List<TrackedMetalItem>> getAll() async {
    final isar = IsarService.isar;
    final metals = await isar.trackedMetals.where().anyId().findAll();
    final states = await isar.trackedMetalStates.where().anyId().findAll();
    final stateByCode = <String, bool>{for (final s in states) s.code: s.isActive};
    metals.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return metals
        .map(
          (m) => TrackedMetalItem(
            metal: (TrackedMetal()
              ..id = m.id
              ..code = m.code
              ..name = canonicalName(m.code, m.name)
              ..createdAt = m.createdAt),
            isActive: stateByCode[m.code] ?? true,
          ),
        )
        .toList();
  }

  static Future<void> addOrUpdate(MarketRateItem item) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      final existing = await isar.trackedMetals.getByCode(item.code);
      if (existing != null) {
        existing.name = canonicalName(item.code, item.name);
        await isar.trackedMetals.put(existing);
      } else {
        final tracked = TrackedMetal()
          ..code = item.code
          ..name = canonicalName(item.code, item.name)
          ..createdAt = DateTime.now();
        await isar.trackedMetals.putByCode(tracked);
      }

      final state = TrackedMetalState()
        ..code = item.code
        ..isActive = true;
      await isar.trackedMetalStates.putByCode(state);
    });
  }

  static Future<void> setActiveByCode(String code, bool value) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      final state = TrackedMetalState()
        ..code = code
        ..isActive = value;
      await isar.trackedMetalStates.putByCode(state);
    });
  }

  static Future<void> removeByCode(String code) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.trackedMetals.deleteByCode(code);
      await isar.trackedMetalStates.deleteByCode(code);
    });
  }
}
