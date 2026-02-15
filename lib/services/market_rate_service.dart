import 'dart:convert';
import 'dart:io';

import '../models/market_rate_item.dart';

class CurrencyRateListResult {
  final List<MarketRateItem> items;
  final DateTime fetchedAt;

  const CurrencyRateListResult({
    required this.items,
    required this.fetchedAt,
  });
}

class MetalRateListResult {
  final List<MarketRateItem> items;
  final DateTime fetchedAt;

  const MetalRateListResult({
    required this.items,
    required this.fetchedAt,
  });
}

class MarketRateService {
  static const _tcmbCurrencyUrl = 'https://www.tcmb.gov.tr/kurlar/today.xml';

  static const _currencyUrls = <String>[
    _tcmbCurrencyUrl,
  ];

  static const _metalXmlUrls = <String>[
    _tcmbCurrencyUrl,
  ];
  static const _metalFallbackUrls = <String>[
    'https://api.genelpara.com/json/?list=altin&symbol=GA,GAG,C,Y,T',
    'https://api.genelpara.com/json/?list=altin&sembol=GA,GAG,C,Y,T',
    'https://api.genelpara.com/embed/altin.json',
  ];

  static const _currencyNameMap = <String, String>{
    'USD': 'Dolar',
    'EUR': 'Euro',
    'GBP': 'Sterlin',
    'CHF': 'İsviçre Frangı',
    'AED': 'BAE Dirhemi',
  };

  static const _metalNameMap = <String, String>{
    'XAU': 'Altın',
    'XAG': 'Gümüş',
    'XPT': 'Platin',
    'XPD': 'Paladyum',
    'KULCEALTIN': 'Külçe Altın',
  };
  static const _metalFallbackNameMap = <String, String>{
    'HA': 'Has Altın',
    'HG': 'Hamit Altın',
    'GA': 'Gram Altın',
    'GAG': 'Gram Gümüş',
    'C': 'Çeyrek Altın',
    'Y': 'Yarım Altın',
    'T': 'Tam Altın',
  };

  static Future<List<MarketRateItem>> fetchStocksByCodes(
    List<String> codes,
  ) async {
    final normalized = codes
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (normalized.isEmpty) return const [];

    // stooq endpoint is free and does not require an API key.
    // BIST symbols are usually served with ".ti". Keep ".tr" as fallback.
    final stooqTi = await _fetchStocksFromStooqBySuffix(normalized, 'ti');
    final stooqGot = stooqTi.map((e) => e.code.toUpperCase()).toSet();
    final stooqMissing = normalized.where((c) => !stooqGot.contains(c)).toList();
    final stooqTr = await _fetchStocksFromStooqBySuffix(stooqMissing, 'tr');

    final stooqMerged = <String, MarketRateItem>{
      for (final i in stooqTi) i.code.toUpperCase(): i,
      for (final i in stooqTr) i.code.toUpperCase(): i,
    };

    final stillMissing = normalized
        .where((c) => !stooqMerged.containsKey(c))
        .toList();
    final yahoo = await _fetchStocksFromYahooByCodes(stillMissing);
    final yahooGot = yahoo.map((e) => e.code.toUpperCase()).toSet();
    final googleMissing = stillMissing.where((c) => !yahooGot.contains(c)).toList();
    final google = await _fetchStocksFromGoogleByCodes(googleMissing);

    final merged = <String, MarketRateItem>{
      ...stooqMerged,
      for (final i in yahoo) i.code.toUpperCase(): i,
      for (final i in google) i.code.toUpperCase(): i,
    };
    return merged.values.toList();
  }

  static Future<List<MarketRateItem>> fetchCryptosByCodes(
    List<String> codes,
  ) async {
    final normalized = codes
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (normalized.isEmpty) return const [];

    // Binance expects JSON array format for symbols param:
    // symbols=["BTCUSDT","ETHUSDT"] (URL encoded)
    try {
      final usdtSymbols = normalized.map((c) => '${c}USDT').toList();
      final symbolsJson = jsonEncode(usdtSymbols);
      final encoded = Uri.encodeQueryComponent(symbolsJson);
      final url = 'https://api.binance.com/api/v3/ticker/price?symbols=$encoded';
      final body = await _fetchString(url);
      final decoded = jsonDecode(body);
      if (decoded is List) {
        final items = _buildCryptosFromBinanceList(decoded);
        if (items.isNotEmpty) return items;
      }
    } catch (_) {}

    // Fallback: CryptoCompare public endpoint (no key required).
    try {
      final fsyms = normalized.join(',');
      final url =
          'https://min-api.cryptocompare.com/data/pricemulti?fsyms=$fsyms&tsyms=USD';
      final json = await _fetchJson(url);
      final items = <MarketRateItem>[];
      for (final code in normalized) {
        final row = json[code];
        if (row is! Map<String, dynamic>) continue;
        final price = _parseNum(row['USD']);
        if (price == null || price <= 0) continue;
        items.add(
          MarketRateItem(
            code: code,
            name: code,
            buy: price,
            sell: price,
          ),
        );
      }
      return items;
    } catch (_) {
      return const [];
    }
  }

  static Future<CurrencyRateListResult> fetchAllCurrencies() async {
    final currencyXml = await _fetchStringFromAny(_currencyUrls);
    final items = _buildAllCurrenciesFromXml(currencyXml, _currencyNameMap);
    return CurrencyRateListResult(
      items: items,
      fetchedAt: DateTime.now(),
    );
  }

  static Future<MetalRateListResult> fetchAllMetals() async {
    final metalXml = await _fetchStringFromAny(_metalXmlUrls);
    var items = _buildMetalsFromXml(metalXml, _metalNameMap);

    // Some days TCMB metal rows may be missing/empty; keep the screen usable.
    if (items.isEmpty) {
      final fallbackJson = await _fetchJsonFromAny(_metalFallbackUrls);
      items = _buildAllRatesFromJson(fallbackJson, _metalFallbackNameMap);
    }

    return MetalRateListResult(
      items: items,
      fetchedAt: DateTime.now(),
    );
  }

  static List<MarketRateItem> _buildAllCurrenciesFromXml(
    String xml,
    Map<String, String> nameMap,
  ) {
    final source = _extractCurrencyBlocks(xml);
    final items = <MarketRateItem>[];

    for (final e in source.entries) {
      final code = e.key.toUpperCase().trim();
      final block = e.value;
      final buy = _extractTcmbPrice(block, const ['ForexBuying', 'BanknoteBuying']);
      final sell = _extractTcmbPrice(block, const ['ForexSelling', 'BanknoteSelling']);

      if (buy == null || sell == null) continue;

      items.add(
        MarketRateItem(
          code: code,
          name: nameMap[code] ?? code,
          buy: buy,
          sell: sell,
        ),
      );
    }

    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  static List<MarketRateItem> _buildMetalsFromXml(
    String xml,
    Map<String, String> nameMap,
  ) {
    final source = _extractCurrencyBlocks(xml);
    final items = <MarketRateItem>[];
    final added = <String>{};

    // First pass: known metal codes.
    for (final entry in nameMap.entries) {
      final code = entry.key.toUpperCase();
      final block = source[code];
      if (block == null) continue;

      final buy = _extractTcmbPrice(
        block,
        const ['ForexBuying', 'BanknoteBuying', 'CrossRateUSD', 'CrossRateOther'],
      );
      final sell = _extractTcmbPrice(
        block,
        const ['ForexSelling', 'BanknoteSelling', 'CrossRateUSD', 'CrossRateOther'],
      );
      if (buy == null || sell == null) continue;

      items.add(
        MarketRateItem(
          code: code,
          name: entry.value,
          buy: buy,
          sell: sell,
        ),
      );
      added.add(code);
    }

    // Second pass: pick additional metal-like entries published by TCMB.
    for (final entry in source.entries) {
      final code = entry.key.toUpperCase();
      if (added.contains(code)) continue;

      final block = entry.value;
      final isim = (_extractTcmbText(block, 'Isim') ?? '').toUpperCase();
      final currName = (_extractTcmbText(block, 'CurrencyName') ?? '').toUpperCase();
      final isMetalLike =
          code.startsWith('XA') ||
          code.startsWith('XP') ||
          code.contains('ALTIN') ||
          isim.contains('ALTIN') ||
          isim.contains('GÜMÜŞ') ||
          isim.contains('GUMUS') ||
          isim.contains('PLATIN') ||
          isim.contains('PALADYUM') ||
          currName.contains('GOLD') ||
          currName.contains('SILVER') ||
          currName.contains('PLATINUM') ||
          currName.contains('PALLADIUM');
      if (!isMetalLike) continue;

      final buy = _extractTcmbPrice(
        block,
        const ['ForexBuying', 'BanknoteBuying', 'CrossRateUSD', 'CrossRateOther'],
      );
      final sell = _extractTcmbPrice(
        block,
        const ['ForexSelling', 'BanknoteSelling', 'CrossRateUSD', 'CrossRateOther'],
      );
      if (buy == null || sell == null) continue;

      items.add(
        MarketRateItem(
          code: code,
          name: nameMap[code] ?? _prettyMetalName(code, isim),
          buy: buy,
          sell: sell,
        ),
      );
    }

    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  static Map<String, String> _extractCurrencyBlocks(String xml) {
    final result = <String, String>{};
    final currencyRegex = RegExp(
      r'<Currency\b[^>]*CurrencyCode="([^"]+)"[^>]*>([\s\S]*?)</Currency>',
      caseSensitive: false,
      multiLine: true,
    );
    for (final m in currencyRegex.allMatches(xml)) {
      final code = (m.group(1) ?? '').trim().toUpperCase();
      final body = m.group(2) ?? '';
      if (code.isEmpty) continue;
      result[code] = body;
    }
    return result;
  }

  static double? _extractTcmbPrice(String currencyBlock, List<String> tags) {
    for (final tag in tags) {
      final re = RegExp('<$tag>([\\s\\S]*?)</$tag>', caseSensitive: false);
      final m = re.firstMatch(currencyBlock);
      if (m == null) continue;
      final raw = (m.group(1) ?? '').trim();
      final parsed = _parseNum(raw);
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  static String? _extractTcmbText(String currencyBlock, String tag) {
    final re = RegExp('<$tag>([\\s\\S]*?)</$tag>', caseSensitive: false);
    final m = re.firstMatch(currencyBlock);
    final raw = (m?.group(1) ?? '').trim();
    return raw.isEmpty ? null : raw;
  }

  static String _prettyMetalName(String code, String isimUpper) {
    if (isimUpper.contains('ALTIN')) return 'Altın';
    if (isimUpper.contains('GÜMÜŞ') || isimUpper.contains('GUMUS')) return 'Gümüş';
    if (isimUpper.contains('PLATIN')) return 'Platin';
    if (isimUpper.contains('PALADYUM')) return 'Paladyum';
    return code;
  }

  static List<MarketRateItem> _buildAllRatesFromJson(
    Map<String, dynamic> raw,
    Map<String, String> nameMap,
  ) {
    final source = _pickDataMap(raw);
    final items = <MarketRateItem>[];

    for (final e in source.entries) {
      final code = e.key.toUpperCase().trim();
      final value = e.value;
      if (value is! Map<String, dynamic>) continue;

      final buy = _parseNum(
        value['alis'] ??
            value['Alis'] ??
            value['Alış'] ??
            value['buy'] ??
            value['buying'] ??
            value['Buying'],
      );
      final sell = _parseNum(
        value['satis'] ??
            value['Satis'] ??
            value['Satış'] ??
            value['sell'] ??
            value['selling'] ??
            value['Selling'],
      );
      if (buy == null || sell == null) continue;

      items.add(
        MarketRateItem(
          code: code,
          name: nameMap[code] ?? code,
          buy: buy,
          sell: sell,
        ),
      );
    }

    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  static Map<String, dynamic> _pickDataMap(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    final result = raw['result'];
    if (result is Map<String, dynamic>) return result;
    return raw;
  }

  static Future<Map<String, dynamic>> _fetchJsonFromAny(List<String> urls) async {
    Object? lastError;
    for (final url in urls) {
      try {
        return await _fetchJson(url);
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError ?? 'API erişilemedi');
  }

  static Future<String> _fetchStringFromAny(List<String> urls) async {
    Object? lastError;
    for (final url in urls) {
      try {
        return await _fetchString(url);
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError ?? 'API erişilemedi');
  }

  static Future<String> _fetchString(String url) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(
        HttpHeaders.userAgentHeader,
        'Mozilla/5.0 (HesapKitap/1.0; +https://example.local)',
      );
      final res = await req.close();
      if (res.statusCode != 200) {
        throw Exception('API status: ${res.statusCode}');
      }
      return await utf8.decoder.bind(res).join();
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> _fetchJson(String url) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(
        HttpHeaders.userAgentHeader,
        'Mozilla/5.0 (HesapKitap/1.0; +https://example.local)',
      );
      final res = await req.close();
      if (res.statusCode != 200) {
        throw Exception('API status: ${res.statusCode}');
      }
      final body = await utf8.decoder.bind(res).join();
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) {
        throw Exception('Beklenmeyen API yanıtı');
      }
      return json;
    } finally {
      client.close();
    }
  }

  static double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    var s = value.toString().trim();
    if (s.isEmpty) return null;

    final lastDot = s.lastIndexOf('.');
    final lastComma = s.lastIndexOf(',');

    if (lastDot >= 0 && lastComma >= 0) {
      if (lastDot > lastComma) {
        // 1,234.56 -> decimal is dot
        s = s.replaceAll(',', '');
      } else {
        // 1.234,56 -> decimal is comma
        s = s.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (lastComma >= 0) {
      // 1234,56
      s = s.replaceAll(',', '.');
    } else {
      // 1234.56 or 1234
      s = s;
    }

    return double.tryParse(s);
  }

  static List<MarketRateItem> _buildStocksFromStooqCsv(String csv) {
    final lines = csv
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.length <= 1) return const [];

    final items = <MarketRateItem>[];
    for (int i = 1; i < lines.length; i++) {
      final parts = _parseCsvLine(lines[i]);
      if (parts.length < 7) continue;
      final symbolRaw = parts[0].replaceAll('"', '').trim().toUpperCase();
      final closeRaw = parts[6].replaceAll('"', '').trim();
      final nameRaw = parts.length > 10
          ? parts[10].replaceAll('"', '').trim()
          : '';
      if (symbolRaw.isEmpty || symbolRaw == 'N/A') continue;
      final code = symbolRaw
          .replaceAll('.TR', '')
          .replaceAll('.TI', '')
          .replaceAll('.IS', '');
      final close = _parseNum(closeRaw);
      if (close == null || close <= 0) continue;
      items.add(
        MarketRateItem(
          code: code,
          name: nameRaw.isEmpty || nameRaw == 'N/A' ? code : nameRaw,
          buy: close,
          sell: close,
        ),
      );
    }
    return items;
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        current.write(ch);
        continue;
      }
      if (ch == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
        continue;
      }
      current.write(ch);
    }
    result.add(current.toString());
    return result;
  }

  static Future<List<MarketRateItem>> _fetchStocksFromStooqBySuffix(
    List<String> codes,
    String suffix,
  ) async {
    if (codes.isEmpty) return const [];
    final joined = codes.map((c) => '${c.toLowerCase()}.$suffix').join(',');
    final url = 'https://stooq.com/q/l/?s=$joined&f=sd2t2ohlcvn&e=csv';
    try {
      final body = await _fetchString(url);
      return _buildStocksFromStooqCsv(body);
    } catch (_) {
      return const [];
    }
  }

  static Future<List<MarketRateItem>> _fetchStocksFromYahooByCodes(
    List<String> codes,
  ) async {
    if (codes.isEmpty) return const [];
    final symbols = codes.map((c) => '${c.toUpperCase()}.IS').join(',');
    final url = 'https://query1.finance.yahoo.com/v7/finance/quote?symbols=$symbols';
    try {
      final json = await _fetchJson(url);
      final qr = json['quoteResponse'];
      if (qr is! Map<String, dynamic>) return const [];
      final result = qr['result'];
      if (result is! List) return const [];

      final items = <MarketRateItem>[];
      for (final row in result) {
        if (row is! Map) continue;
        final symbolRaw = (row['symbol'] ?? '').toString().toUpperCase().trim();
        if (symbolRaw.isEmpty) continue;
        final code = symbolRaw.split('.').first;
        final price = _parseNum(row['regularMarketPrice']);
        if (price == null || price <= 0) continue;
        final name = (row['shortName'] ?? row['longName'] ?? code).toString().trim();
        items.add(
          MarketRateItem(
            code: code,
            name: name.isEmpty ? code : name,
            buy: price,
            sell: price,
          ),
        );
      }
      return items;
    } catch (_) {
      return const [];
    }
  }

  static Future<List<MarketRateItem>> _fetchStocksFromGoogleByCodes(
    List<String> codes,
  ) async {
    if (codes.isEmpty) return const [];
    final items = <MarketRateItem>[];
    for (final code in codes) {
      final item = await _fetchStockFromGoogleByCode(code);
      if (item != null) items.add(item);
    }
    return items;
  }

  static Future<MarketRateItem?> _fetchStockFromGoogleByCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return null;
    final url = 'https://www.google.com/finance/quote/$clean:IST?hl=tr';
    try {
      final html = await _fetchString(url);

      final escaped = RegExp.escape(clean);
      final re = RegExp(
        '\\["[^"]+",\\["$escaped","IST"\\],"([^"]+)"[^\\[]*\\[([0-9]+(?:\\.[0-9]+)?)',
        caseSensitive: false,
      );
      final m = re.firstMatch(html);
      if (m == null) return null;
      final name = (m.group(1) ?? clean).trim();
      final price = _parseNum(m.group(2));
      if (price == null || price <= 0) return null;

      return MarketRateItem(
        code: clean,
        name: name.isEmpty ? clean : name,
        buy: price,
        sell: price,
      );
    } catch (_) {
      return null;
    }
  }

  static List<MarketRateItem> _buildCryptosFromBinanceList(List rows) {
    final items = <MarketRateItem>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final symbol = (row['symbol'] ?? '').toString().toUpperCase().trim();
      final rawPrice = (row['price'] ?? '').toString().trim();
      if (symbol.isEmpty || rawPrice.isEmpty) continue;
      if (!symbol.endsWith('USDT')) continue;
      final code = symbol.substring(0, symbol.length - 4);
      final price = _parseNum(rawPrice);
      if (price == null || price <= 0) continue;
      items.add(
        MarketRateItem(
          code: code,
          name: code,
          buy: price,
          sell: price,
        ),
      );
    }
    return items;
  }
}
