import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/market_rate_item.dart';
import '../screens/instrument_tracking_screen.dart';
import '../services/account_service.dart';
import '../services/market_rate_service.dart';
import '../services/tracked_metal_service.dart';

class PreciousMetalTrackingScreen extends StatelessWidget {
  const PreciousMetalTrackingScreen({super.key});

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

  Future<TrackingLinkStatus> _linkStatus(String code) async {
    final accounts = await AccountService.getAllAccounts();
    bool any = false;
    bool active = false;
    for (final Account a in accounts) {
      final match = a.type == 'investment' &&
          a.investmentSubtype == 'metal' &&
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
      title: 'Kıymetli Maden Takip',
      selectTitle: 'Maden Seç',
      emptyMessage: 'Takip listeniz boş.\nSağ alttaki + butonuyla maden ekleyebilirsiniz.',
      noCandidateMessage: 'Eklenebilecek yeni maden bulunamadı.',
      loadErrorPrefix: 'Kıymetli maden verileri alınamadı',
      blockedDeactivateMessage: 'Bu madene bağlı aktif hesap var. Pasife alamazsınız.',
      blockedDeleteMessage: 'Bu madene bağlı aktif hesap var. Silinemez veya pasife alınamaz.',
      linkedPassiveMessage: 'Bu madene bağlı hesap var. Silinemedi, pasife alındı.',
      linkedActiveLabel: 'Bağlı aktif yatırım hesabı var',
      linkedPassiveLabel: 'Bağlı pasif yatırım hesabı var',
      linkedNoneLabel: 'Bağlı yatırım hesabı yok',
      loadData: () async {
        final results = await Future.wait([
          TrackedMetalService.getAll(),
          MarketRateService.fetchAllMetals(),
        ]);
        final tracked = results[0] as List<TrackedMetalItem>;
        final rates = results[1] as MetalRateListResult;
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
          allRates: rates.items,
          fetchedAt: rates.fetchedAt,
        );
      },
      addOrUpdate: TrackedMetalService.addOrUpdate,
      setActive: TrackedMetalService.setActiveByCode,
      remove: TrackedMetalService.removeByCode,
      getByCode: (code) async {
        final e = await TrackedMetalService.getByCode(code);
        if (e == null) return null;
        return TrackingItemView(code: e.code, name: e.name, isActive: e.isActive);
      },
      linkStatusByCode: _linkStatus,
      trailingBuilder: (MarketRateItem? rate) {
        if (rate == null) return const Text('Veri yok');
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Alış: ${_fmt(rate.buy)}'),
            Text('Satış: ${_fmt(rate.sell)}'),
          ],
        );
      },
    );
  }
}
