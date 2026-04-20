import 'package:isar/isar.dart';

import '../../database/isar_service.dart';
import '../../models/account.dart';
import '../../models/asset_record.dart';
import '../../models/cari_card.dart';
import '../../models/cari_transaction.dart';
import '../../models/category.dart';
import '../../models/expense_plan.dart';
import '../../models/finance_transaction.dart';
import '../../models/income_category.dart';
import '../../models/income_plan.dart';
import '../../models/investment_transaction.dart';
import '../../models/subscription_definition.dart';
import '../../models/tracked_crypto.dart';
import '../../models/tracked_crypto_state.dart';
import '../../models/tracked_currency.dart';
import '../../models/tracked_currency_state.dart';
import '../../models/tracked_metal.dart';
import '../../models/tracked_metal_state.dart';
import '../../models/tracked_stock.dart';
import '../../models/tracked_stock_state.dart';
import '../../models/transaction_attachment.dart';
import '../../models/transfer_transaction.dart';
import '../../models/user_profile.dart';
import 'cloud_data_state.dart';
import 'cloud_safety_backup.dart';
import 'cloud_safety_backup_service.dart';
import 'sync_bootstrap_choice.dart';
import 'sync_bootstrap_plan.dart';
import 'sync_bootstrap_preference.dart';
import 'sync_collection_snapshot.dart';
import 'sync_conflict_policy.dart';
import 'sync_metadata_store.dart';
import 'sync_readiness_report.dart';
import 'sync_record.dart';

class CloudSyncPreparationResult {
  final SyncReadinessReport report;
  final SyncBootstrapPlan plan;
  final int metadataRecordsCreated;
  final SyncBootstrapPreference preference;
  final CloudSafetyBackup backup;

  const CloudSyncPreparationResult({
    required this.report,
    required this.plan,
    required this.metadataRecordsCreated,
    required this.preference,
    required this.backup,
  });
}

class CloudSyncMigrationService {
  CloudSyncMigrationService({
    SyncMetadataStore? metadataStore,
    CloudSafetyBackupService? backupService,
  })  : _metadataStore = metadataStore ?? SyncMetadataStore(),
        _backupService = backupService ?? CloudSafetyBackupService();

  final SyncMetadataStore _metadataStore;
  final CloudSafetyBackupService _backupService;

  /// Cihazdaki Isar verisini sayip ilk sync icin yerel bir envanter cikarir.
  Future<SyncReadinessReport> inspectLocalData() async {
    final isar = IsarService.isar;
    final collections = <SyncCollectionSnapshot>[
      SyncCollectionSnapshot(
        entityType: 'account',
        count: (await isar.accounts.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'category',
        count: (await isar.categorys.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'finance_transaction',
        count: (await isar.financeTransactions.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'asset_record',
        count: (await isar.assetRecords.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'investment_transaction',
        count: (await isar.investmentTransactions.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'income_category',
        count: (await isar.incomeCategorys.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'cari_card',
        count: (await isar.cariCards.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'subscription_definition',
        count:
            (await isar.subscriptionDefinitions.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'cari_transaction',
        count: (await isar.cariTransactions.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'expense_plan',
        count: (await isar.expensePlans.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'income_plan',
        count: (await isar.incomePlans.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'transaction_attachment',
        count: (await isar.transactionAttachments.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'transfer_transaction',
        count: (await isar.transferTransactions.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'user_profile',
        count: (await isar.userProfiles.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_currency',
        count: (await isar.trackedCurrencys.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_currency_state',
        count: (await isar.trackedCurrencyStates.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_metal',
        count: (await isar.trackedMetals.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_metal_state',
        count: (await isar.trackedMetalStates.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_stock',
        count: (await isar.trackedStocks.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_stock_state',
        count: (await isar.trackedStockStates.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_crypto',
        count: (await isar.trackedCryptos.where().anyId().findAll()).length,
      ),
      SyncCollectionSnapshot(
        entityType: 'tracked_crypto_state',
        count: (await isar.trackedCryptoStates.where().anyId().findAll()).length,
      ),
    ];

    final attachments = await isar.transactionAttachments.where().findAll();
    final attachmentBytes = attachments.fold<int>(
      0,
      (sum, item) => sum + item.imageBytes.length,
    );
    final totalRecords = collections.fold<int>(0, (sum, item) => sum + item.count);
    final records = await _metadataStore.loadRecords();
    final fingerprint = collections
        .where((item) => item.count > 0)
        .map((item) => '${item.entityType}:${item.count}')
        .join('|');

    return SyncReadinessReport(
      collections: collections.where((item) => item.count > 0).toList(),
      totalRecords: totalRecords,
      attachmentBytes: attachmentBytes,
      metadataCoverage: records.length,
      fingerprint: '$fingerprint|attachmentBytes:$attachmentBytes',
    );
  }

  Future<SyncBootstrapPlan> createPlan({
    required CloudDataState cloudState,
    required SyncBootstrapChoice choice,
    SyncConflictPolicy? conflictPolicy,
  }) async {
    // UI tarafinda secilen stratejiye gore once tahmini bir plan uretilir.
    final report = await inspectLocalData();
    return SyncBootstrapPlanner.build(
      report: report,
      cloudState: cloudState,
      choice: choice,
      conflictPolicy: conflictPolicy,
    );
  }

  Future<CloudSyncPreparationResult> prepareDeviceForCloud({
    required CloudDataState cloudState,
    required SyncBootstrapChoice choice,
    SyncConflictPolicy? conflictPolicy,
  }) async {
    // Ilk cloud gecisi oncesi local kayitlar icin metadata olusturur ve tercihi saklar.
    final report = await inspectLocalData();
    final now = DateTime.now();
    final backup = await _backupService.createBackup(report: report);
    final created = await _metadataStore.ensureRecords(
      await _collectLocalRecords(now),
    );
    final plan = SyncBootstrapPlanner.build(
      report: report,
      cloudState: cloudState,
      choice: choice,
      conflictPolicy: conflictPolicy,
    );
    final preference = SyncBootstrapPreference(
      choice: choice,
      conflictPolicy: plan.conflictPolicy,
      preparedAt: now,
      localFingerprint: report.fingerprint,
    );
    await _metadataStore.savePreference(preference);
    return CloudSyncPreparationResult(
      report: report,
      plan: plan,
      metadataRecordsCreated: created,
      preference: preference,
      backup: backup,
    );
  }

  Future<SyncBootstrapPreference?> loadPreference() {
    return _metadataStore.loadPreference();
  }

  Future<CloudSafetyBackup?> loadLatestBackup() {
    return _backupService.loadLatestBackup();
  }

  Future<bool> hasPreparationDrift() async {
    final preference = await loadPreference();
    if (preference == null) return false;
    final report = await inspectLocalData();
    return preference.localFingerprint != report.fingerprint;
  }

  Future<List<SyncRecord>> _collectLocalRecords(DateTime now) async {
    final isar = IsarService.isar;
    final records = <SyncRecord>[];

    // Her koleksiyon icin tek tip sync kaydi uretmek mapping katmanini basit tutar.
    Future<void> addIds(String entityType, List<int> ids) async {
      for (final id in ids) {
        records.add(
          SyncRecord.initial(
            entityType: entityType,
            localId: id,
            now: now,
          ),
        );
      }
    }

    await addIds('account', await isar.accounts.where().idProperty().findAll());
    await addIds('category', await isar.categorys.where().idProperty().findAll());
    await addIds(
      'finance_transaction',
      await isar.financeTransactions.where().idProperty().findAll(),
    );
    await addIds(
      'asset_record',
      await isar.assetRecords.where().idProperty().findAll(),
    );
    await addIds(
      'investment_transaction',
      await isar.investmentTransactions.where().idProperty().findAll(),
    );
    await addIds(
      'income_category',
      await isar.incomeCategorys.where().idProperty().findAll(),
    );
    await addIds('cari_card', await isar.cariCards.where().idProperty().findAll());
    await addIds(
      'subscription_definition',
      await isar.subscriptionDefinitions.where().idProperty().findAll(),
    );
    await addIds(
      'cari_transaction',
      await isar.cariTransactions.where().idProperty().findAll(),
    );
    await addIds(
      'expense_plan',
      await isar.expensePlans.where().idProperty().findAll(),
    );
    await addIds('income_plan', await isar.incomePlans.where().idProperty().findAll());
    await addIds(
      'transaction_attachment',
      await isar.transactionAttachments.where().idProperty().findAll(),
    );
    await addIds(
      'transfer_transaction',
      await isar.transferTransactions.where().idProperty().findAll(),
    );
    await addIds(
      'user_profile',
      await isar.userProfiles.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_currency',
      await isar.trackedCurrencys.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_currency_state',
      await isar.trackedCurrencyStates.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_metal',
      await isar.trackedMetals.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_metal_state',
      await isar.trackedMetalStates.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_stock',
      await isar.trackedStocks.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_stock_state',
      await isar.trackedStockStates.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_crypto',
      await isar.trackedCryptos.where().idProperty().findAll(),
    );
    await addIds(
      'tracked_crypto_state',
      await isar.trackedCryptoStates.where().idProperty().findAll(),
    );

    return records;
  }
}
