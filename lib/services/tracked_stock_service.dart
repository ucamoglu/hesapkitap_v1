import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/market_rate_item.dart';
import '../models/tracked_stock.dart';
import '../models/tracked_stock_state.dart';

class TrackedStockItem {
  final TrackedStock stock;
  final bool isActive;

  const TrackedStockItem({
    required this.stock,
    required this.isActive,
  });

  String get code => stock.code;
  String get name => stock.name;
}

class TrackedStockService {
  static const Map<String, String> _bistNameMap = {
    'AEFES': 'Anadolu Efes',
    'AGHOL': 'Anadolu Grubu Holding',
    'AKBNK': 'Akbank',
    'AKFGY': 'Akfen GYO',
    'AKFYE': 'Akfen Yenilenebilir Enerji',
    'AKSA': 'Aksa Akrilik',
    'AKSEN': 'Aksa Enerji',
    'ALARK': 'Alarko Holding',
    'ALBRK': 'Albaraka Turk',
    'ALGYO': 'Alarko GYO',
    'ANHYT': 'Anadolu Hayat Emeklilik',
    'ANSGR': 'Anadolu Sigorta',
    'ARCLK': 'Arcelik',
    'ARDYZ': 'Ard Grup Bilisim',
    'ASELS': 'Aselsan',
    'ASTOR': 'Astor Enerji',
    'AYDEM': 'Aydem Yenilenebilir Enerji',
    'BAGFS': 'Bagfas',
    'BANVT': 'Banvit',
    'BERA': 'Bera Holding',
    'BIMAS': 'BIM',
    'BIOEN': 'Bioen Enerji',
    'BRISA': 'Brisa',
    'BUCIM': 'Bursa Cimento',
    'CANTE': 'Can2 Termik',
    'CCOLA': 'Coca Cola Icecek',
    'CEMAS': 'Cemas Dokum',
    'CIMSA': 'Cimsa',
    'CLEBI': 'Celebi',
    'CVKMD': 'CVK Maden',
    'DOAS': 'Dogus Otomotiv',
    'DOHOL': 'Dogan Holding',
    'ECILC': 'Eczacibasi Ilac',
    'EGEEN': 'Ege Endustri',
    'EKGYO': 'Emlak Konut GYO',
    'ENERY': 'Enerya Enerji',
    'ENJSA': 'Enerjisa Enerji',
    'ENKAI': 'Enka Insaat',
    'EREGL': 'Eregli Demir Celik',
    'ESEN': 'Esenbogaz Elektrik',
    'EUPWR': 'Europower Enerji',
    'FROTO': 'Ford Otosan',
    'GARAN': 'Garanti BBVA',
    'GESAN': 'Girişim Elektrik',
    'GLYHO': 'Global Yatirim Holding',
    'GOKNR': 'Goknur Gida',
    'GOODY': 'Good Year',
    'GRSEL': 'Gursel Turizm',
    'GSDHO': 'GSD Holding',
    'GUBRF': 'Gubre Fabrikalari',
    'GWIND': 'Galata Wind',
    'HALKB': 'Halkbank',
    'HEKTS': 'Hektaş',
    'IPEKE': 'Ipek Dogal Enerji',
    'ISCTR': 'Is Bankasi (C)',
    'ISDMR': 'Isdemir',
    'ISFIN': 'Is Finansal Kiralama',
    'ISGYO': 'Is GYO',
    'ISMEN': 'Is Yatirim',
    'IZENR': 'Izdemir Enerji',
    'KARSN': 'Karsan',
    'KCAER': 'Kocaer Celik',
    'KCHOL': 'Koc Holding',
    'KLSER': 'Kaleseramik',
    'KONTR': 'Kontrolmatik',
    'KONYA': 'Konya Cimento',
    'KOZAA': 'Koza Anadolu Metal',
    'KOZAL': 'Koza Altin',
    'KRDMD': 'Kardemir (D)',
    'LOGO': 'Logo Yazilim',
    'MAVI': 'Mavi Giyim',
    'MGROS': 'Migros',
    'MPARK': 'MLP Saglik',
    'ODAS': 'Odas Elektrik',
    'OTKAR': 'Otokar',
    'OYAKC': 'OYAK Cimento',
    'PENTA': 'Penta Teknoloji',
    'PETKM': 'Petkim',
    'PGSUS': 'Pegasus',
    'QUAGR': 'Qua Granite',
    'REEDR': 'Reeder Teknoloji',
    'SAHOL': 'Sabanci Holding',
    'SASA': 'Sasa Polyester',
    'SDTTR': 'SDT Uzay ve Savunma',
    'SELEC': 'Selcuk Ecza Deposu',
    'SISE': 'Sisecam',
    'SKBNK': 'Sekerbank',
    'SMRTG': 'Smart Gunes',
    'SOKM': 'Sok Marketler',
    'TABGD': 'Tab Gida',
    'TAVHL': 'TAV Havalimanlari',
    'TCELL': 'Turkcell',
    'THYAO': 'Turk Hava Yollari',
    'TKFEN': 'Tekfen Holding',
    'TKNSA': 'Teknosa',
    'TOASO': 'Tofas',
    'TSKB': 'TSKB',
    'TTKOM': 'Turk Telekom',
    'TTRAK': 'Turk Traktor',
    'TUPRS': 'Tupras',
    'ULKER': 'Ulker Biskuvi',
    'VAKBN': 'Vakifbank',
    'VESBE': 'Vestel Beyaz Esya',
    'VESTL': 'Vestel',
    'YEOTK': 'Yeo Teknoloji',
    'YKBNK': 'Yapi Kredi',
    'YYLGD': 'Yayla Agro',
    'ZOREN': 'Zorlu Enerji',
  };

  static List<MarketRateItem> allBistStocks() {
    final list = _bistNameMap.entries
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

  static String canonicalName(String code, String currentName) {
    final upper = code.toUpperCase();
    final mapped = _bistNameMap[upper];
    if (mapped != null) return mapped;
    return currentName.trim().isEmpty ? upper : currentName;
  }

  static Future<TrackedStockItem?> getByCode(String code) async {
    final isar = IsarService.isar;
    final stock = await isar.trackedStocks.getByCode(code.toUpperCase());
    if (stock == null) return null;
    final state = await isar.trackedStockStates.getByCode(stock.code);
    final normalized = TrackedStock()
      ..id = stock.id
      ..code = stock.code
      ..name = canonicalName(stock.code, stock.name)
      ..createdAt = stock.createdAt;
    return TrackedStockItem(
      stock: normalized,
      isActive: state?.isActive ?? true,
    );
  }

  static Future<List<TrackedStockItem>> getAll() async {
    final isar = IsarService.isar;
    final stocks = await isar.trackedStocks.where().anyId().findAll();
    final states = await isar.trackedStockStates.where().anyId().findAll();
    final stateByCode = <String, bool>{
      for (final s in states) s.code: s.isActive,
    };

    stocks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return stocks
        .map(
          (s) => TrackedStockItem(
            stock: (TrackedStock()
              ..id = s.id
              ..code = s.code
              ..name = canonicalName(s.code, s.name)
              ..createdAt = s.createdAt),
            isActive: stateByCode[s.code] ?? true,
          ),
        )
        .toList();
  }

  static Future<void> addOrUpdate(MarketRateItem item) async {
    final isar = IsarService.isar;
    final code = item.code.toUpperCase().trim();
    await isar.writeTxn(() async {
      final existing = await isar.trackedStocks.getByCode(code);
      if (existing != null) {
        existing.name = canonicalName(code, item.name);
        await isar.trackedStocks.put(existing);
      } else {
        final tracked = TrackedStock()
          ..code = code
          ..name = canonicalName(code, item.name)
          ..createdAt = DateTime.now();
        await isar.trackedStocks.putByCode(tracked);
      }

      final state = TrackedStockState()
        ..code = code
        ..isActive = true;
      await isar.trackedStockStates.putByCode(state);
    });
  }

  static Future<void> setActiveByCode(String code, bool value) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      final state = TrackedStockState()
        ..code = code.toUpperCase().trim()
        ..isActive = value;
      await isar.trackedStockStates.putByCode(state);
    });
  }

  static Future<void> removeByCode(String code) async {
    final isar = IsarService.isar;
    final clean = code.toUpperCase().trim();
    await isar.writeTxn(() async {
      await isar.trackedStocks.deleteByCode(clean);
      await isar.trackedStockStates.deleteByCode(clean);
    });
  }
}
