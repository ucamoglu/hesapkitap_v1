import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/runtime/app_runtime.dart';
import '../core/sync/cloud_data_state.dart';
import '../core/sync/cloud_sync_migration_service.dart';
import '../core/sync/cloud_safety_backup.dart';
import '../core/sync/sync_bootstrap_choice.dart';
import '../core/sync/sync_bootstrap_plan.dart';
import '../core/sync/sync_conflict_policy.dart';
import '../core/sync/sync_bootstrap_preference.dart';
import '../core/sync/sync_readiness_report.dart';

class CloudSyncSetupScreen extends StatefulWidget {
  const CloudSyncSetupScreen({super.key});

  @override
  State<CloudSyncSetupScreen> createState() => _CloudSyncSetupScreenState();
}

class _CloudSyncSetupScreenState extends State<CloudSyncSetupScreen> {
  final CloudSyncMigrationService _service = AppRuntime.cloudSyncMigration;

  bool _loading = true;
  bool _saving = false;
  CloudDataState _cloudState = CloudDataState.empty;
  SyncBootstrapChoice _choice = SyncBootstrapChoice.uploadDeviceData;
  SyncConflictPolicy _conflictPolicy = SyncConflictPolicy.preferDevice;
  SyncReadinessReport? _report;
  SyncBootstrapPlan? _plan;
  SyncBootstrapPreference? _preference;
  CloudSafetyBackup? _latestBackup;
  bool _hasPreparationDrift = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Yerel veri ozeti, kaydedilmis tercih ve ilk plan hesaplamasini bir arada yukler.
  Future<void> _load() async {
    final report = await _service.inspectLocalData();
    final preference = await _service.loadPreference();
    final latestBackup = await _service.loadLatestBackup();
    final hasPreparationDrift = preference == null
        ? false
        : preference.localFingerprint != report.fingerprint;
    final choice = preference?.choice ?? SyncBootstrapChoice.uploadDeviceData;
    final policy =
        preference?.conflictPolicy ?? SyncBootstrapPlanner.defaultPolicyForChoice(choice);
    final plan = await _service.createPlan(
      cloudState: _cloudState,
      choice: choice,
      conflictPolicy: policy,
    );

    if (!mounted) return;
    setState(() {
      _report = report;
      _preference = preference;
      _latestBackup = latestBackup;
      _hasPreparationDrift = hasPreparationDrift;
      _choice = choice;
      _conflictPolicy = policy;
      _plan = plan;
      _loading = false;
    });
  }

  // Kullanici secenek degistirdikce tahmini esitleme planini yeniden hesaplar.
  Future<void> _refreshPlan() async {
    final plan = await _service.createPlan(
      cloudState: _cloudState,
      choice: _choice,
      conflictPolicy: _conflictPolicy,
    );
    if (!mounted) return;
    setState(() {
      _plan = plan;
    });
  }

  // Cihazi bulut esitlemesine hazirlayip metadata ve tercihi diske kaydeder.
  Future<void> _prepare() async {
    setState(() {
      _saving = true;
    });

    try {
      final result = await _service.prepareDeviceForCloud(
        cloudState: _cloudState,
        choice: _choice,
        conflictPolicy: _conflictPolicy,
      );
      if (!mounted) return;
      setState(() {
        _report = result.report;
        _plan = result.plan;
        _preference = result.preference;
        _latestBackup = result.backup;
        _hasPreparationDrift = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bulut esitleme hazırlığı kaydedildi. ${result.metadataRecordsCreated} kayıt için esitleme metaverisi oluşturuldu ve güvenlik yedeği alındı.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bulut esitleme hazırlığı kaydedilemedi: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitlement = AppRuntime.subscriptions.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulut Eşitleme Hazırlığı'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Üyelik Durumu',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entitlement.canUseCloud
                              ? 'Plus aktif. Bulut eşitleme açıldığında bu cihazdaki hazırlık doğrudan kullanılabilir.'
                              : 'Şu an yalnızca yerel moddasınız. Hazırlık seçimlerinizi bugünden kaydedebilirsiniz.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildLocalSummaryCard(),
                const SizedBox(height: 12),
                _buildCloudStateCard(),
                const SizedBox(height: 12),
                _buildStrategyCard(),
                const SizedBox(height: 12),
                _buildConflictCard(),
                const SizedBox(height: 12),
                _buildPlanCard(),
                if (_hasPreparationDrift) ...[
                  const SizedBox(height: 12),
                  _buildDriftWarningCard(),
                ],
                if (_latestBackup != null) ...[
                  const SizedBox(height: 12),
                  _buildBackupCard(),
                ],
                if (_preference != null) ...[
                  const SizedBox(height: 12),
                  _buildPreferenceCard(),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _prepare,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _saving
                        ? 'Hazırlanıyor...'
                        : 'Bu Cihazı Bulut Eşitlemeye Hazırla',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLocalSummaryCard() {
    final report = _report;
    if (report == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yerel Veri Özeti',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Toplam kayıt: ${report.totalRecords}'),
            Text('Ek boyutu: ${_formatBytes(report.attachmentBytes)}'),
            Text('Hazır metaveri: ${report.metadataCoverage}'),
            const SizedBox(height: 8),
            if (report.collections.isEmpty)
              const Text('Cihazda senkronize edilecek kayıt bulunmuyor.')
            else
              ...report.collections.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${item.entityType}: ${item.count}'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudStateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bulut Durumu Varsayımı',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            RadioGroup<CloudDataState>(
              groupValue: _cloudState,
              onChanged: (value) async {
                if (value == null) return;
                setState(() {
                  _cloudState = value;
                });
                await _refreshPlan();
              },
              child: Column(
                children: const [
                  RadioListTile<CloudDataState>(
                    value: CloudDataState.empty,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Bulut boş'),
                    subtitle: Text('İlk kez bulut kullanılacak.'),
                  ),
                  RadioListTile<CloudDataState>(
                    value: CloudDataState.hasData,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Bulutta veri var'),
                    subtitle: Text(
                      'Aynı hesabın başka bir cihazı kullanılmış olabilir.',
                    ),
                  ),
                  RadioListTile<CloudDataState>(
                    value: CloudDataState.unknown,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Durum bilinmiyor'),
                    subtitle: Text('Sunucu kontrol edilmeden karar verilmesin.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlk Eşitleme Stratejisi',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            RadioGroup<SyncBootstrapChoice>(
              groupValue: _choice,
              onChanged: (value) async {
                if (value == null) return;
                setState(() {
                  _choice = value;
                  _conflictPolicy =
                      SyncBootstrapPlanner.defaultPolicyForChoice(value);
                });
                await _refreshPlan();
              },
              child: Column(
                children: const [
                  RadioListTile<SyncBootstrapChoice>(
                    value: SyncBootstrapChoice.uploadDeviceData,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Bu cihazı buluta yükle'),
                    subtitle: Text(
                      'Mevcut telefon verisi ana kaynak kabul edilir.',
                    ),
                  ),
                  RadioListTile<SyncBootstrapChoice>(
                    value: SyncBootstrapChoice.downloadCloudData,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Buluttan cihaza indir'),
                    subtitle: Text('Bulut ana kaynak kabul edilir.'),
                  ),
                  RadioListTile<SyncBootstrapChoice>(
                    value: SyncBootstrapChoice.mergeSafely,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Güvenli birleştir'),
                    subtitle: Text(
                      'Çakışan kayıtları inceleyerek birleştir.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Çakışma Kuralı',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            DropdownButtonFormField<SyncConflictPolicy>(
              initialValue: _conflictPolicy,
              decoration: const InputDecoration(
                labelText: 'Çakışma olduğunda',
              ),
              items: const [
                DropdownMenuItem(
                  value: SyncConflictPolicy.preferDevice,
                  child: Text('Cihaz verisini koru'),
                ),
                DropdownMenuItem(
                  value: SyncConflictPolicy.preferCloud,
                  child: Text('Bulut verisini koru'),
                ),
                DropdownMenuItem(
                  value: SyncConflictPolicy.preferLatestChange,
                  child: Text('En son değişiklik kazansın'),
                ),
                DropdownMenuItem(
                  value: SyncConflictPolicy.manualReview,
                  child: Text('Elle inceleme iste'),
                ),
              ],
              onChanged: (value) async {
                if (value == null) return;
                setState(() {
                  _conflictPolicy = value;
                });
                await _refreshPlan();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard() {
    final plan = _plan;
    if (plan == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Oluşacak İlk Senkronizasyon Planı',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Tahmini yükleme: ${plan.estimatedPushCount}'),
            Text('Tahmini indirme: ${plan.estimatedPullCount}'),
            Text(
              plan.requiresConfirmation
                  ? 'Bu plan ek kullanıcı onayı gerektirir.'
                  : 'Bu plan doğrudan uygulanabilir.',
            ),
            const SizedBox(height: 8),
            if (plan.warnings.isEmpty)
              const Text('Ek uyarı yok.')
            else
              ...plan.warnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $warning'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriftWarningCard() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hazırlık Güncel Değil',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Son bulut hazırlığından sonra cihazdaki veriler değişmiş görünüyor. Cloud açılmadan önce bu cihazı yeniden hazırlamanız önerilir.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard() {
    final backup = _latestBackup;
    if (backup == null) {
      return const SizedBox.shrink();
    }

    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Güvenlik Yedeği',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Son yedek: ${formatter.format(backup.createdAt)}'),
            Text('Toplam kayıt: ${backup.totalRecords}'),
            Text('Ek boyutu: ${_formatBytes(backup.attachmentBytes)}'),
            Text('Yedek klasörü: ${backup.backupDirectoryPath}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard() {
    final preference = _preference;
    if (preference == null) {
      return const SizedBox.shrink();
    }

    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kaydedilen Hazırlık',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Seçim: ${_choiceLabel(preference.choice)}'),
            Text('Çakışma kuralı: ${_policyLabel(preference.conflictPolicy)}'),
            Text('Hazırlandı: ${formatter.format(preference.preparedAt)}'),
            Text(
              _hasPreparationDrift
                  ? 'Durum: Hazırlık sonrası veri değişmiş'
                  : 'Durum: Hazırlık güncel görünüyor',
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) {
      return '${(value / 1024).toStringAsFixed(1)} KB';
    }
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _choiceLabel(SyncBootstrapChoice choice) {
    switch (choice) {
      case SyncBootstrapChoice.uploadDeviceData:
        return 'Bu cihazı buluta yükle';
      case SyncBootstrapChoice.downloadCloudData:
        return 'Buluttan cihaza indir';
      case SyncBootstrapChoice.mergeSafely:
        return 'Güvenli birleştir';
    }
  }

  String _policyLabel(SyncConflictPolicy policy) {
    switch (policy) {
      case SyncConflictPolicy.preferDevice:
        return 'Cihaz verisini koru';
      case SyncConflictPolicy.preferCloud:
        return 'Bulut verisini koru';
      case SyncConflictPolicy.preferLatestChange:
        return 'En son değişiklik kazansın';
      case SyncConflictPolicy.manualReview:
        return 'Elle inceleme iste';
    }
  }
}
