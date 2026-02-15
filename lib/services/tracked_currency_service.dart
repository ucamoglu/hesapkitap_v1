import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/market_rate_item.dart';
import '../models/tracked_currency.dart';
import '../models/tracked_currency_state.dart';

class TrackedCurrencyItem {
  final TrackedCurrency currency;
  final bool isActive;

  const TrackedCurrencyItem({
    required this.currency,
    required this.isActive,
  });

  String get code => currency.code;
  String get name => currency.name;
}

class TrackedCurrencyService {
  static Future<TrackedCurrencyItem?> getByCode(String code) async {
    final isar = IsarService.isar;
    final currency = await isar.trackedCurrencys.getByCode(code);
    if (currency == null) return null;
    final state = await isar.trackedCurrencyStates.getByCode(code);
    return TrackedCurrencyItem(
      currency: currency,
      isActive: state?.isActive ?? true,
    );
  }

  static Future<List<TrackedCurrencyItem>> getAll() async {
    final isar = IsarService.isar;
    final currencies = await isar.trackedCurrencys.where().anyId().findAll();
    final states = await isar.trackedCurrencyStates.where().anyId().findAll();
    final stateByCode = <String, bool>{for (final s in states) s.code: s.isActive};

    currencies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return currencies
        .map(
          (c) => TrackedCurrencyItem(
            currency: c,
            isActive: stateByCode[c.code] ?? true,
          ),
        )
        .toList();
  }

  static Future<void> addOrUpdate(MarketRateItem item) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      final existing = await isar.trackedCurrencys.getByCode(item.code);
      if (existing != null) {
        existing.name = item.name;
        await isar.trackedCurrencys.put(existing);
        final state = TrackedCurrencyState()
          ..code = item.code
          ..isActive = true;
        await isar.trackedCurrencyStates.putByCode(state);
        return;
      }

      final tracked = TrackedCurrency()
        ..code = item.code
        ..name = item.name
        ..createdAt = DateTime.now();
      await isar.trackedCurrencys.putByCode(tracked);
      final state = TrackedCurrencyState()
        ..code = item.code
        ..isActive = true;
      await isar.trackedCurrencyStates.putByCode(state);
    });
  }

  static Future<void> setActiveByCode(String code, bool value) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      final state = TrackedCurrencyState()
        ..code = code
        ..isActive = value;
      await isar.trackedCurrencyStates.putByCode(state);
    });
  }

  static Future<void> removeByCode(String code) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.trackedCurrencys.deleteByCode(code);
      await isar.trackedCurrencyStates.deleteByCode(code);
    });
  }
}
