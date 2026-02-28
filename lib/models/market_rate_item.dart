class MarketRateItem {
  // Enstrumanin tekil kodu.
  final String code;
  // Ekranda gosterilen ad.
  final String name;
  // Alis fiyatı veya referans fiyat.
  final double buy;
  // Satis fiyatı veya referans fiyat.
  final double sell;

  const MarketRateItem({
    required this.code,
    required this.name,
    required this.buy,
    required this.sell,
  });
}
