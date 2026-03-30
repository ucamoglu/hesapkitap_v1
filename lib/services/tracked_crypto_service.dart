import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/market_rate_item.dart';
import '../models/tracked_crypto.dart';
import '../models/tracked_crypto_state.dart';

class TrackedCryptoItem {
  final TrackedCrypto crypto;
  final bool isActive;

  const TrackedCryptoItem({
    required this.crypto,
    required this.isActive,
  });

  String get code => crypto.code;
  String get name => crypto.name;
}

class TrackedCryptoService {
  static const Map<String, String> _nameMap = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'BNB': 'BNB',
    'XRP': 'XRP',
    'ADA': 'Cardano',
    'SOL': 'Solana',
    'DOGE': 'Dogecoin',
    'TRX': 'Tron',
    'AVAX': 'Avalanche',
    'DOT': 'Polkadot',
    'LINK': 'Chainlink',
    'LTC': 'Litecoin',
    'MATIC': 'Polygon',
    'UNI': 'Uniswap',
    'ATOM': 'Cosmos',
    'APT': 'Aptos',
    'ARB': 'Arbitrum',
    'OP': 'Optimism',
    'NEAR': 'Near Protocol',
    'FIL': 'Filecoin',
  };

  /// Ekranda secilebilecek sabit kripto katalogunu uretir.
  static List<MarketRateItem> allCryptos() {
    final list = _nameMap.entries
        .map(
          (e) => MarketRateItem(
            code: e.key,
            name: e.value,
            buy: 0,
            sell: 0,
          ),
        )
        .toList();
    list.sort((a, b) => a.code.compareTo(b.code));
    return list;
  }

  /// Koddan kanonik gorunen adi uretir; veri kaynagi farklarini normalize eder.
  static String canonicalName(String code, String currentName) {
    final upper = code.toUpperCase();
    final mapped = _nameMap[upper];
    if (mapped != null) return mapped;
    return currentName.trim().isEmpty ? upper : currentName;
  }

  /// Kod bazinda tek bir takip kaydini ve aktiflik durumunu getirir.
  static Future<TrackedCryptoItem?> getByCode(String code) async {
    final isar = IsarService.isar;
    final crypto = await isar.trackedCryptos.getByCode(code.toUpperCase());
    if (crypto == null) return null;
    final state = await isar.trackedCryptoStates.getByCode(crypto.code);
    final normalized = TrackedCrypto()
      ..id = crypto.id
      ..code = crypto.code
      ..name = canonicalName(crypto.code, crypto.name)
      ..createdAt = crypto.createdAt;
    return TrackedCryptoItem(
      crypto: normalized,
      isActive: state?.isActive ?? true,
    );
  }

  /// Tum kripto takip kayitlarini aktiflik durumlariyla birlestirir.
  static Future<List<TrackedCryptoItem>> getAll() async {
    final isar = IsarService.isar;
    final cryptos = await isar.trackedCryptos.where().anyId().findAll();
    final states = await isar.trackedCryptoStates.where().anyId().findAll();
    final stateByCode = <String, bool>{
      for (final s in states) s.code: s.isActive,
    };
    cryptos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cryptos
        .map(
          (c) => TrackedCryptoItem(
            crypto: (TrackedCrypto()
              ..id = c.id
              ..code = c.code
              ..name = canonicalName(c.code, c.name)
              ..createdAt = c.createdAt),
            isActive: stateByCode[c.code] ?? true,
          ),
        )
        .toList();
  }

  /// Sadece aktif kripto takip kayitlarini dondurur.
  static Future<List<TrackedCryptoItem>> getActive() async {
    final items = await getAll();
    return items.where((item) => item.isActive).toList(growable: false);
  }

  /// Takip kaydini ekler veya adini gunceller; state kaydini da aktif yapar.
  static Future<void> addOrUpdate(MarketRateItem item) async {
    final isar = IsarService.isar;
    final code = item.code.toUpperCase().trim();
    await isar.writeTxn(() async {
      final existing = await isar.trackedCryptos.getByCode(code);
      if (existing != null) {
        existing.name = canonicalName(code, item.name);
        await isar.trackedCryptos.put(existing);
      } else {
        final tracked = TrackedCrypto()
          ..code = code
          ..name = canonicalName(code, item.name)
          ..createdAt = DateTime.now();
        await isar.trackedCryptos.putByCode(tracked);
      }

      final state = TrackedCryptoState()
        ..code = code
        ..isActive = true;
      await isar.trackedCryptoStates.putByCode(state);
    });
  }

  /// Kripto kaydinin UI aktiflik durumunu degistirir.
  static Future<void> setActiveByCode(String code, bool value) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      final state = TrackedCryptoState()
        ..code = code.toUpperCase().trim()
        ..isActive = value;
      await isar.trackedCryptoStates.putByCode(state);
    });
  }

  /// Takip kaydini ve state bilgisini birlikte siler.
  static Future<void> removeByCode(String code) async {
    final isar = IsarService.isar;
    final clean = code.toUpperCase().trim();
    await isar.writeTxn(() async {
      await isar.trackedCryptos.deleteByCode(clean);
      await isar.trackedCryptoStates.deleteByCode(clean);
    });
  }
}
