# Core Data Layer (Cloud-Ready)

Bu klasor, uygulamanin mevcut local Isar davranisini bozmadan cloud gecisine hazirlik icin eklendi.

## Ne eklendi?

- `repositories/contracts`: Is kurallari icin arayuzler.
- `repositories/local`: Mevcut `services/*` metodlarini saran local implementasyonlar.
- `repositories/data_layer.dart`: Tek yerden local veya ileride cloud kompozisyonu.
- `sync/*`: Senkronizasyon yonu, durumlari ve `NoopSyncEngine`.

## Su an davranis

- Uygulama hala eski servislerle calisir.
- Yeni katman sadece altyapi olarak eklendi.
- Runtime davranisinda degisiklik yoktur.

## Gelecek adim (cloud)

1. Ekran/service cagri noktalarini kademeli olarak `DataLayer` uzerinden gecirmek.
2. Her model icin `SyncMetadata` eklemek (versiyon, remoteId, dirty state).
3. `SyncEngine` icin cloud implementasyonu (pull/push/conflict cozum).
4. Ucretsiz local + ucretli cloud lisans akisini ayirmak.
