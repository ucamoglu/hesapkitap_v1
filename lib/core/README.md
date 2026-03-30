# Core Data Layer (Cloud-Ready)

Bu klasor, uygulamanin mevcut local Isar davranisini bozmadan cloud gecisine hazirlik icin eklendi.

## Ne eklendi?

- `repositories/contracts`: Is kurallari icin arayuzler.
- `repositories/local`: Mevcut `services/*` metodlarini saran local implementasyonlar.
- `repositories/data_layer.dart`: Tek yerden local veya ileride cloud kompozisyonu.
- `sync/*`: Senkronizasyon yonu, durumlari ve `NoopSyncEngine`.
- `sync/api/*`: Cloud backend ile konusacak uygulama sozlesmesi.
- `sync/mappers/*`: Local model <-> remote payload ceviricileri.

## Su an davranis

- Uygulama hala eski servislerle calisir.
- Yeni katman sadece altyapi olarak eklendi.
- Runtime davranisinda degisiklik yoktur.
- `CloudSyncMigrationService`, mevcut local veriyi sayip ilk cloud sync plani
  olusturur.
- Secilen ilk sync stratejisi ve lokal sync metadata JSON dosyalarinda
  saklanir; boylece mevcut kullanici verisi kaybedilmeden cloud gecisi
  hazirlanabilir.
- `RemoteSyncEngine`, metadata ve mapper katmani uzerinden gercek push/pull
  akisini yurutebilecek omurgayi saglar.
- Cloud hazirligi sirasinda cihazdaki Isar verisi icin otomatik guvenlik yedegi
  alinir.
- Son hazirliktan sonra local veri degisirse fingerprint drift uyarisi
  gosterilebilir.

## Gelecek adim (cloud)

1. Ekran/service cagri noktalarini kademeli olarak `DataLayer` uzerinden gecirmek.
2. Her model icin `SyncRecord` benzeri metadata tutmak (versiyon, remoteId, dirty state).
3. `SyncEngine` icin cloud implementasyonu (pull/push/conflict cozum).
4. Ucretsiz local + ucretli cloud lisans akisini ayirmak.

## Veri guvenligi notu

Play Store uzerinden once local mod kullanan kullanicilarin verisinin cloud'a
gecis sirasinda kaybolmamasi icin su an iki emniyet vardir:

1. Cloud hazirligindan once yerel Isar veritabaninin kompakt bir guvenlik
   kopyasi alinir.
2. Hazirliktan sonra local veri degisirse kullaniciya yeniden hazirlik
   yapilmasi gerektigi bildirilebilir.

Ancak yine de tam cloud gecisi icin asagidaki maddeler tamamlanmadan
"veri kaybi olmayacak" garantisi verilmemelidir:

- Tum create/update/delete akislarinin `DataLayer` veya repository uzerinden
  gecmesi
- Sync metadata'nin her degisiklikte anlik guncellenmesi
- Gercek backend + auth + cihazlar arasi conflict cozumunun tamamlanmasi

## Cloud Cikis Checklist

Bu liste, uygulamayi Play Store'da local mod ile dagittiktan sonra ucretli
cloud ozelligini guvenli bicimde acmadan once tamamlanmasi gereken son
kontrol listesidir.

### Kritik

- Gercek cloud backend uclari tamamlanmis olmali.
  `sync/api/noop_cloud_sync_api.dart` yerine production API kullanilmali.
- Kimlik dogrulama ve kullanici bazli veri ayrimi tamamlanmis olmali.
  Her kullanicinin verisi yalnizca kendi hesabina baglanmali.
- Ilk gecis akisi cihazda yedek alarak calismali.
  Hazirlik oncesi backup, hazirlik sonrasi fingerprint drift kontrolu ve hata
  durumunda geri donus plani test edilmeli.
- Tum create/update/delete akislarinin sync metadata urettigi dogrulanmali.
  Yeni kayit, guncelleme, silme ve pasiflestirme akislari dahil.
- Sync mapper kapsami ile metadata kapsami birebir uyumlu olmali.
  Metadata ureten ama mapper'i olmayan entity birakilmamali.
- Conflict stratejisi urun seviyesinde netlestirilmeli.
  `preferDevice`, `preferCloud`, `preferLatestChange`, `manualReview`
  davranislari gercek backend ile test edilmeli.

### Onemli

- Ilk cloud bootstrap idempotent olmali.
  Ayni kullanici hazirlik veya ilk senkronizasyonu tekrar calistirsa veri
  ciftlenmemeli.
- Cok cihazli kullanim senaryolari test edilmeli.
  Ayni hesap ile iki cihazda eszamanli degisiklikler kontrol edilmeli.
- Buyuk veri seti ile stres testi yapilmali.
  Ozellikle binlerce finans hareketi, plan, cari hareket, ekli dosya ve
  takip verisi ile ilk gecis denenmeli.
- Offline/online gecisleri ve zayif internet davranisi test edilmeli.
  Yarida kalan push/pull akislarinda veri kaybi olmamali.
- Uygulama kapanmasi / cokerse geri kazanma testi yapilmali.
  Senkronizasyon ortasinda uygulama kapaninca metadata ve local veri
  tutarsiz kalmamali.
- Schema migration ve uygulama guncelleme senaryolari test edilmeli.
  Eski surumden yeni surume gecen kullanici cloud actiginda veri kaybi
  yasamamali.

### Sonradan Yapilabilir

- Kullaniciya conflict cozum ekrani sunmak
- Sync durumu / son senkronizasyon zamani / hata detaylarini UI'da gostermek
- Attachment ve buyuk medya dosyalari icin daha gelismis batch veya retry
  stratejileri eklemek
- Daha ince taneli telemetry ve sync health metric toplamak

### Test Senaryolari

1. Bos cihaz + bos cloud ile ilk cloud acilisi
2. Dolu cihaz + bos cloud ile ilk cloud acilisi
3. Dolu cihaz + dolu cloud ile `preferDevice`
4. Dolu cihaz + dolu cloud ile `preferCloud`
5. Dolu cihaz + dolu cloud ile `manualReview`
6. Hazirliktan sonra yeni kayit ekleyip drift uyarisini dogrulama
7. Senkronizasyon sirasinda uygulamayi kapatma
8. Senkronizasyon sirasinda interneti kesme
9. Iki cihazda ayni kaydi farkli sekilde guncelleme
10. Cloud ozelligi acildiktan sonra uygulamayi guncelleyip tekrar sync etme

### Cikis Kriteri

Asagidaki dort madde birlikte saglanmadan ucretli cloud ozelligi acilmamali:

- Production backend aktif
- Auth ve user isolation tamam
- Kritik test senaryolari gecti
- Geri donus / destek proseduru hazir
