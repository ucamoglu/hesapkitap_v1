import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/market_rate_item.dart';
import '../services/account_service.dart';
import '../services/market_rate_service.dart';
import '../services/tracked_crypto_service.dart';
import 'instrument_tracking_screen.dart';

class CryptoTrackingScreen extends StatefulWidget {
  const CryptoTrackingScreen({super.key});

  @override
  State<CryptoTrackingScreen> createState() => _CryptoTrackingScreenState();
}

class _CryptoTrackingScreenState extends State<CryptoTrackingScreen> {
  // Fiyat degerlerini TR biciminde gostermek icin ortak formatter.
  String _fmt(double value, {int decimals = 6}) {
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

  // Takipteki sembole bagli yatirim hesabi olup olmadigini kontrol eder.
  Future<TrackingLinkStatus> _linkStatus(String code) async {
    final accounts = await AccountService.getAllAccounts();
    bool any = false;
    bool active = false;
    for (final Account a in accounts) {
      final match = a.type == 'investment' &&
          a.investmentSubtype == 'crypto' &&
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
      title: 'Kripto Para Takip',
      selectTitle: 'Kripto Seç',
      emptyMessage:
          'Takip listeniz boş.\nSağ alttaki + butonuyla kripto para ekleyebilirsiniz.',
      noCandidateMessage: 'Eklenebilecek yeni kripto bulunamadı.',
      loadErrorPrefix: 'Kripto verileri alınamadı',
      blockedDeactivateMessage: 'Bu kriptoya bağlı aktif hesap var. Pasife alamazsınız.',
      blockedDeleteMessage: 'Bu kriptoya bağlı aktif hesap var. Silinemez veya pasife alınamaz.',
      linkedPassiveMessage: 'Bu kriptoya bağlı hesap var. Silinemedi, pasife alındı.',
      linkedActiveLabel: 'Bağlı aktif yatırım hesabı var',
      linkedPassiveLabel: 'Bağlı pasif yatırım hesabı var',
      linkedNoneLabel: 'Bağlı yatırım hesabı yok',
      loadData: () async {
        // Once kayitli takip listesi okunur, sonra canli fiyatlar ustune bindirilir.
        final tracked = await TrackedCryptoService.getAll();
        final catalog = TrackedCryptoService.allCryptos();
        final trackedCodes = tracked.map((e) => e.code).toList();
        List<MarketRateItem> live = const [];
        if (trackedCodes.isNotEmpty) {
          try {
            live = await MarketRateService.fetchCryptosByCodes(trackedCodes);
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
      addOrUpdate: TrackedCryptoService.addOrUpdate,
      setActive: TrackedCryptoService.setActiveByCode,
      remove: TrackedCryptoService.removeByCode,
      getByCode: (code) async {
        final e = await TrackedCryptoService.getByCode(code);
        if (e == null) return null;
        return TrackingItemView(code: e.code, name: e.name, isActive: e.isActive);
      },
      linkStatusByCode: _linkStatus,
      trailingBuilder: (MarketRateItem? rate) {
        if (rate == null || (rate.sell <= 0 && rate.buy <= 0)) {
          return const Text('Veri yok');
        }
        // Kripto tarafinda alis/satis yerine tek fiyat gostermek yeterli.
        final price = rate.sell > 0 ? rate.sell : rate.buy;
        return Text(
          'Fiyat: ${_fmt(price)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        );
      },
      refreshInterval: const Duration(minutes: 1),
    );
  }
}
