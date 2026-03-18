import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/market_rate_item.dart';
import '../services/account_service.dart';
import '../services/market_rate_service.dart';
import '../services/tracked_stock_service.dart';
import 'instrument_tracking_screen.dart';

class StockTrackingScreen extends StatefulWidget {
  const StockTrackingScreen({super.key});

  @override
  State<StockTrackingScreen> createState() => _StockTrackingScreenState();
}

class _StockTrackingScreenState extends State<StockTrackingScreen> {
  // Hisse fiyatlarini ekranda okunur bicimde gosterir.
  String _fmt(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    return '${b.toString()},$decPart';
  }

  // Ilgili hisseye bagli yatirim hesabi varsa silme/pasiflestirme kurallari degisir.
  Future<TrackingLinkStatus> _linkStatus(String code) async {
    final accounts = await AccountService.getAllAccounts();
    bool any = false;
    bool active = false;
    for (final Account a in accounts) {
      final match = a.type == 'investment' &&
          a.investmentSubtype == 'stock' &&
          (a.investmentSymbol ?? '').toUpperCase() == code.toUpperCase();
      if (!match) continue;
      any = true;
      if (a.isActive) {
        active = true;
        break;
      }
    }
    return TrackingLinkStatus(hasAny: any, hasActive: active);
  }

  @override
  Widget build(BuildContext context) {
    return InstrumentTrackingScreen(
      title: 'Borsa Takip (BIST)',
      selectTitle: 'BIST Hisse Seç',
      emptyMessage:
          'Takip listeniz boş.\nSağ alttaki + butonuyla BIST hissesi ekleyebilirsiniz.',
      noCandidateMessage: 'Eklenebilecek yeni BIST hissesi bulunamadı.',
      loadErrorPrefix: 'Borsa verileri alınamadı',
      blockedDeactivateMessage: 'Bu hisseye bağlı aktif hesap var. Pasife alamazsınız.',
      blockedDeleteMessage: 'Bu hisseye bağlı aktif hesap var. Silinemez veya pasife alınamaz.',
      linkedPassiveMessage: 'Bu hisseye bağlı hesap var. Silinemedi, pasife alındı.',
      linkedActiveLabel: 'Bağlı aktif yatırım hesabı var',
      linkedPassiveLabel: 'Bağlı pasif yatırım hesabı var',
      linkedNoneLabel: 'Bağlı yatırım hesabı yok',
      loadData: () async {
        // Sabit BIST katalogu ile canli fiyat verisi tek listede birlestirilir.
        final tracked = await TrackedStockService.getAll();
        final catalog = TrackedStockService.allBistStocks();

        final trackedCodes = tracked.map((e) => e.code).toList();
        List<MarketRateItem> live = const [];
        if (trackedCodes.isNotEmpty) {
          try {
            live = await MarketRateService.fetchStocksByCodes(trackedCodes);
          } catch (_) {
            live = const [];
          }
        }

        final allRates = <MarketRateItem>[
          ...catalog,
          ...live,
        ];

        return TrackingLoadData(
          tracked: tracked
              .map(
                (e) => TrackingItemView(
                  code: e.code,
                  name: e.name,
                  isActive: e.isActive,
                ),
              )
              .toList(),
          allRates: allRates,
          fetchedAt: DateTime.now(),
        );
      },
      addOrUpdate: TrackedStockService.addOrUpdate,
      setActive: TrackedStockService.setActiveByCode,
      remove: TrackedStockService.removeByCode,
      getByCode: (code) async {
        final e = await TrackedStockService.getByCode(code);
        if (e == null) return null;
        return TrackingItemView(code: e.code, name: e.name, isActive: e.isActive);
      },
      linkStatusByCode: _linkStatus,
      trailingBuilder: (MarketRateItem? rate) {
        if (rate == null || (rate.sell <= 0 && rate.buy <= 0)) {
          return const Text('Veri yok');
        }
        final price = rate.sell > 0 ? rate.sell : rate.buy;
        return Text(
          'Fiyat: ${_fmt(price)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        );
      },
      refreshInterval: const Duration(minutes: 3),
    );
  }
}
