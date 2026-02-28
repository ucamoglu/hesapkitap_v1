# Cloud Sync API Contract

Bu klasor, cloud sync icin uygulama tarafindaki sozlesmeyi tanimlar.

## Temel tipler

- `CloudSyncApi`: Uygulamanin backend ile konustugu arabirim.
- `RemoteSyncRecord`: Her kaydi tek tip envelope icinde tasir.
- `MemoryCloudSyncApi`: Test ve gelistirme icin bellek ici ornek implementasyon.
- `NoopCloudSyncApi`: Backend hazir degilken guvenli bos implementasyon.

## RemoteSyncRecord yapisi

- `entityType`: Kayit tipi. Ornek: `account`, `finance_transaction`
- `remoteId`: Cloud tarafindaki kalici kimlik
- `version`: Optimistic concurrency / versiyon takibi
- `updatedAt`: Sunucu tarafinda son degisiklik zamani
- `deletedAt`: Soft delete/tombstone zamani
- `payload`: Model alanlari ve remote referanslar

## Referans kurali

Iliskili kayitlar local `id` ile degil, diger kayitlarin `remoteId` degerleriyle
tasinir. Boylece cihazlar arasi local `id` farklari veri kaybina yol acmaz.
