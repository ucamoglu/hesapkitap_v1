import 'package:flutter/material.dart';

import '../theme/app_theme_helpers.dart';
import '../utils/navigation_helpers.dart';

class HelpDocumentationScreen extends StatelessWidget {
  const HelpDocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Yardım Dökümanı'),
        actions: [buildHomeAction(context)],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary.withValues(alpha: 0.08),
              Theme.of(context).scaffoldBackgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            _HeroCard(
              title: 'HesapKitap ne yapar?',
              description:
                  'Gelir, gider, transfer, cari, sabit odeme, planlama ve yatirim takibini tek yerde toplar. Bu rehber, menudeki ekranlarin ne ise yaradigini hizlica anlaman icin hazirlandi.',
            ),
            const SizedBox(height: 14),
            _QuickStartCard(
              items: const [
                _HelpBullet(
                  title: '1. Profil ve tema ayarini yap',
                  description:
                      'Profil ekranindan ad, fotograf ve tema secimini tamamlayarak uygulamayi kendine gore hazirla.',
                ),
                _HelpBullet(
                  title: '2. Hesaplarini tanimla',
                  description:
                      'Kasa, banka, kredi karti, yatirim ve gerekiyorsa ek hesap limitlerini once kaydet.',
                ),
                _HelpBullet(
                  title: '3. Kategorileri ve sabit kayitlari olustur',
                  description:
                      'Gelir ve gider kategorilerini, ardindan sabit gelir ve sabit odemeleri tanimla.',
                ),
                _HelpBullet(
                  title: '4. Gunluk islemleri kaydet',
                  description:
                      'Alt bardaki Gelir, Gider, Fatura, Cari ve Transfer aksiyonlariyla gunluk hareketleri islemeye basla.',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _HelpSectionCard(
              icon: Icons.dashboard_customize_outlined,
              color: scheme.primary,
              title: 'Ana Dashboard',
              description:
                  'Finansal Durum ekrani; toplam bakiye, hesap dagilimi, cari bakiye, bugun odenecek sabit odemeler ve takip ettigin enstrumanlari tek bakista gosterir.',
              bullets: const [
                _HelpBullet(
                  title: 'Hizli islem cubugu',
                  description:
                      'Transfer, Cari, Yatirim, Gelir, Fatura ve Gider kayitlarina tek dokunusla ulasirsin.',
                ),
                _HelpBullet(
                  title: 'Acilabilir ozet kartlari',
                  description:
                      'Cari bakiyesi, sabit odemeler ve takip edilen enstrumanlar kartlara basildiginda detay acilir.',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _HelpSectionCard(
              icon: Icons.folder_open_outlined,
              color: Colors.blueGrey,
              title: 'Tanim Ekranlari',
              description:
                  'Uygulamanin temel verileri burada olusturulur. Bir kez dogru kuruldugunda diger tum ekranlar daha hizli calisir.',
              extraContent: const _AccountDefinitionPreview(),
              bullets: const [
                _HelpBullet(
                  title: 'Hesap Tanim',
                  description:
                      'Kasa, banka, yatirim ve kredi karti hesaplarini olusturur. Banka hesabi icin ek hesap limiti de tanimlanabilir.',
                ),
                _HelpBullet(
                  title: 'Cuzdan',
                  description:
                      'Sizin kasa hesabinizdir. Nakit para hareketlerinizi bu alan uzerinden yonetebilirsiniz.',
                ),
                _HelpBullet(
                  title: 'Banka',
                  description:
                      'Banka hesaplari 2 ye ayrilir: Mevduat Hesabi ve Kredi Karti. Mevduat hesabinizi yonetebilir, kredi kartlarinizi takip edebilir, kredi kartlariniza ait taksitli harcamalar yapabilir ve hesap ekstrelerinizi olusturarak harcamalarinizi yonetebilirsiniz.',
                ),
                _HelpBullet(
                  title: 'Yatirim Hesabi',
                  description:
                      'Yatirim hesabi icin once ana menudeki Yatirimci bolumunden ilgilendiginiz yatirimi + ile takibe alin. Daha sonra buradan ilgili yatirim hesaplarini olusturup yonetebilirsiniz.',
                ),
                _HelpBullet(
                  title: 'Sabit Gelirlerim',
                  description:
                      'Maas, kira geliri veya duzenli tahsilatlar gibi tekrar eden gelir kalemlerini yonetir.',
                ),
                _HelpBullet(
                  title: 'Sabit Odemelerim',
                  description:
                      'Elektrik, su, kredi, aidat gibi odemeleri sabit ya da degisken tutarli olarak tanimlar. Son odeme gunu varsa takvim ve dashboard buna gore davranir.',
                ),
                _HelpBullet(
                  title: 'Gelir ve Gider Kategorileri',
                  description:
                      'Raporlarin duzgun cikmasi icin gelir ve gider kalemlerini kategorilere ayirir.',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _HelpSectionCard(
              icon: Icons.receipt_long_outlined,
              color: Colors.deepOrange,
              title: 'Gunluk Islem Kayitlari',
              description:
                  'Uygulamanin ana kullanim alani burasidir. Her hareket kayit altina alinarak bakiye ve analizlere yansir.',
              bullets: const [
                _HelpBullet(
                  title: 'Gelir ve Gider',
                  description:
                      'Kategorili normal finans hareketlerini kaydeder. Hesap secimiyle birlikte bakiyeleri gunceller.',
                ),
                _HelpBullet(
                  title: 'Fatura',
                  description:
                      'Sabit odeme tanimlarindan birini secerek odeme islersin. Varsayilan hesap ve kategori otomatik gelir, istersen degistirebilirsin.',
                ),
                _HelpBullet(
                  title: 'Transfer',
                  description:
                      'Iki hesap arasinda para hareketi yapar ve hesap bakiyelerini senkron tutar.',
                ),
                _HelpBullet(
                  title: 'Yatirim Islemleri',
                  description:
                      'Alis, satis ve yatirim hareketleriyle enstruman bazli portfoy takibini surdurur.',
                ),
                _HelpBullet(
                  title: 'Kredi Karti Ekstreleri ve Hesap Hareketleri',
                  description:
                      'Gecmis islemleri inceleyerek hangi hareketin hangi hesaba nasil yansidigini takip etmene yardim eder.',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _HelpSectionCard(
              icon: Icons.people_alt_outlined,
              color: Colors.orange,
              title: 'Cari ve Tahsilat Takibi',
              description:
                  'Musteri, tedarikci veya kisi bazli alacak-borc yonetimini yapar.',
              bullets: const [
                _HelpBullet(
                  title: 'Cari Kartlar',
                  description:
                      'Her cari icin kart olusturur, gerekli ise dovizli takip de yaparsin.',
                ),
                _HelpBullet(
                  title: 'Cari Islem Girisi',
                  description:
                      'Tahsilat, odeme, alacak ve borc hareketlerini kaydeder.',
                ),
                _HelpBullet(
                  title: 'Cari Ozet Ekranlari',
                  description:
                      'Toplam alacak, toplam borc ve net durumu hem genel hem yabanci para bazinda izlersin.',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _HelpSectionCard(
              icon: Icons.event_note_outlined,
              color: Colors.teal,
              title: 'Planlama ve Takvim',
              description:
                  'Tekrar eden gelir ve giderleri onceden planlayarak odeme ve tahsilat duzenini bozmadan yonetmeni saglar.',
              bullets: const [
                _HelpBullet(
                  title: 'Gelir ve Gider Planlama',
                  description:
                      'Belirli tarihlerde gerceklesmesi beklenen islemleri plan olarak kaydeder.',
                ),
                _HelpBullet(
                  title: 'Takvim',
                  description:
                      'Planlanan hareketleri ve sabit odemeleri gun bazinda gorur; son odeme gunu olmayan sabit odemelerde ay sonu is gunu mantigi kullanilir.',
                ),
                _HelpBullet(
                  title: 'Bildirim altyapisi',
                  description:
                      'Planlanan gelir ve giderler icin hatirlatma mantigi ile ilerler; bu sayede vadesi gelen kalemleri kacirma ihtimali azalir.',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _HelpSectionCard(
              icon: Icons.show_chart_outlined,
              color: Colors.indigo,
              title: 'Analiz ve Piyasa Takibi',
              description:
                  'Mevcut varlik durumunu, finansal dagilimi ve takip ettigin piyasa enstrumanlarini tek uygulamada birlestirir.',
              bullets: const [
                _HelpBullet(
                  title: 'Finansal Analiz ve Varlik Durumu',
                  description:
                      'Donemsel performans, toplam varlik resmi ve hesap dagilimini anlamani kolaylastirir.',
                ),
                _HelpBullet(
                  title: 'Doviz, Altin, Borsa ve Kripto Takip',
                  description:
                      'Secili enstrumanlari izleyerek dashboard ve takip ekranlarinda guncel durumu gorebilirsin.',
                ),
                _HelpBullet(
                  title: 'Harcama Haritasi',
                  description:
                      'Konumlu gider kayitlari varsa harita uzerinden harcama yogunlugunu inceleyebilirsin.',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _HelpSectionCard(
              icon: Icons.tips_and_updates_outlined,
              color: Colors.purple,
              title: 'Pratik Kullanim Onerileri',
              description:
                  'Uygulamadan daha fazla verim almak icin bu kisa akisi kullanabilirsin.',
              bullets: const [
                _HelpBullet(
                  title: 'Once tanim, sonra islem',
                  description:
                      'Hesaplar, kategoriler ve sabit kayitlar once tamamlanirsa veri girisi cok hizlanir.',
                ),
                _HelpBullet(
                  title: 'Fatura ekranini sabit odemelerde kullan',
                  description:
                      'Sabit odeme tanimlarindan gelen odemeleri gider gibi yeniden kurmak yerine Fatura akisiyla isle.',
                ),
                _HelpBullet(
                  title: 'Takvim ve dashboardi birlikte kontrol et',
                  description:
                      'Bugun vadesi gelen sabit odemeleri dashboarddan, ileri tarihli planlari takvimden takip etmek en rahat kullanimdir.',
                ),
                _HelpBullet(
                  title: 'Tema ve profil ayarlarini kullan',
                  description:
                      'Tema secimi ve profil duzenlemeleri uygulamayi daha kisisel ve okunabilir hale getirir.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.secondary.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Uygulama Rehberi',
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: scheme.onPrimary.withValues(alpha: 0.88),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard({required this.items});

  final List<_HelpBullet> items;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.surfaceDecoration(
        accent: scheme.tertiary,
        radius: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.softAccent(scheme.tertiary, 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  color: scheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'En hizli baslangic akisi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BulletRow(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSectionCard extends StatelessWidget {
  const _HelpSectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.bullets,
    this.extraContent,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<_HelpBullet> bullets;
  final Widget? extraContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.surfaceDecoration(
        accent: color,
        radius: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.softAccent(color, 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...bullets.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BulletRow(item: item),
            ),
          ),
          if (extraContent != null) ...[
            const SizedBox(height: 8),
            extraContent!,
          ],
        ],
      ),
    );
  }
}

class _AccountDefinitionPreview extends StatelessWidget {
  const _AccountDefinitionPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ornek Hesap Gorunumu',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: context.surfaceDecoration(
            accent: Theme.of(context).colorScheme.primary,
            radius: 22,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
          ),
          child: Column(
            children: const [
              _SampleAccountTile(
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.blue,
                title: 'CUZDAN',
                lines: [
                  'Kasa',
                  'Bakiye: 541.500,00 TL',
                ],
              ),
              SizedBox(height: 10),
              _SampleAccountTile(
                icon: Icons.account_balance,
                color: Colors.indigo,
                title: 'AKBANK MAAS HS.',
                lines: [
                  'Mevduat Hesabi',
                  'Bakiye: -149.100,00 TL',
                  'Ek Hesap: 150.000,00 TL',
                ],
              ),
              SizedBox(height: 10),
              _SampleAccountTile(
                icon: Icons.credit_card,
                color: Colors.deepOrange,
                title: 'AKBANK KREDI KARTI',
                lines: [
                  'Kredi Karti',
                  'Bagli Hesap: AKBANK MAAS HS.',
                  'Kesim: 30. gun • Son Odeme: 9. gun',
                  'Kart Borcu: 368.450,00 TL',
                ],
              ),
              SizedBox(height: 10),
              _SampleAccountTile(
                icon: Icons.trending_up,
                color: Colors.teal,
                title: 'ALTIN BIRIKIM HS.',
                lines: [
                  'Yatirim • Kiymetli Maden • GA',
                  'Depo: 9 GA',
                  'Degeri: 57.798,99 TL',
                ],
              ),
              SizedBox(height: 10),
              _SampleAccountTile(
                icon: Icons.show_chart,
                color: Colors.teal,
                title: 'HISSE SENEDI XXX',
                lines: [
                  'Yatirim • Borsa • XXX',
                  'Depo: 1.500 XXX',
                  'Degeri: 19.905,00 TL',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SampleAccountTile extends StatelessWidget {
  const _SampleAccountTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_horiz,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.item});

  final _HelpBullet item;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HelpBullet {
  const _HelpBullet({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
