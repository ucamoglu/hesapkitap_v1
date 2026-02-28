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

## Gelecek adim (cloud)

1. Ekran/service cagri noktalarini kademeli olarak `DataLayer` uzerinden gecirmek.
2. Her model icin `SyncRecord` benzeri metadata tutmak (versiyon, remoteId, dirty state).
3. `SyncEngine` icin cloud implementasyonu (pull/push/conflict cozum).
4. Ucretsiz local + ucretli cloud lisans akisini ayirmak.
