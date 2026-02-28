import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/runtime/app_runtime.dart';
import '../core/sync/cloud_data_state.dart';
import '../core/sync/cloud_sync_migration_service.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Yerel veri ozeti, kaydedilmis tercih ve ilk plan hesaplamasini bir arada yukler.
  Future<void> _load() async {
    final report = await _service.inspectLocalData();
    final preference = await _service.loadPreference();
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
      _choice = choice;
      _conflictPolicy = policy;
      _plan = plan;
      _loading = false;
    });
  }

  // Kullanici secenek degistirdikce tahmini sync planini yeniden hesaplar.
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

  // Cihazi cloud gecisine hazirlayip metadata ve tercihi disk uzerine kaydeder.
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
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cloud hazirligi kaydedildi. ${result.metadataRecordsCreated} kayit icin sync metadata olusturuldu.',
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
          content: Text('Cloud hazirligi kaydedilemedi: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitlement = AppRuntime.subscriptions.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync Hazirligi'),
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
                          'Uyelik Durumu',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entitlement.canUseCloud
                              ? 'Plus aktif. Cloud sync acildiginda bu cihazdaki hazirlik dogrudan kullanilabilir.'
                              : 'Su an local-only moddasiniz. Hazirlik secimlerinizi bugunden kaydedebilirsiniz.',
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
                        ? 'Hazirlaniyor...'
                        : 'Bu Cihazi Cloud Sync Icin Hazirla',
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
              'Yerel Veri Ozeti',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Toplam kayit: ${report.totalRecords}'),
            Text('Ek boyutu: ${_formatBytes(report.attachmentBytes)}'),
            Text('Hazir metadata: ${report.metadataCoverage}'),
            const SizedBox(height: 8),
            if (report.collections.isEmpty)
              const Text('Cihazda senkronize edilecek kayit bulunmuyor.')
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
              'Bulut Durumu Varsayimi',
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
                    title: Text('Bulut bos'),
                    subtitle: Text('Ilk kez cloud kullanilacak.'),
                  ),
                  RadioListTile<CloudDataState>(
                    value: CloudDataState.hasData,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Bulutta veri var'),
                    subtitle: Text(
                      'Ayni hesabin baska bir cihazi kullanilmis olabilir.',
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
              'Ilk Sync Stratejisi',
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
                    title: Text('Bu cihazi buluta yukle'),
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
                    title: Text('Guvenli birlestir'),
                    subtitle: Text(
                      'Cakisan kayitlari inceleyerek birlestir.',
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
              'Conflict Kurali',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            DropdownButtonFormField<SyncConflictPolicy>(
              initialValue: _conflictPolicy,
              decoration: const InputDecoration(
                labelText: 'Cakisma oldugunda',
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
                  child: Text('En son degisiklik kazansin'),
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
              'Olusacak Ilk Sync Plani',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Tahmini upload: ${plan.estimatedPushCount}'),
            Text('Tahmini download: ${plan.estimatedPullCount}'),
            Text(
              plan.requiresConfirmation
                  ? 'Bu plan ek kullanici onayi gerektirir.'
                  : 'Bu plan dogrudan uygulanabilir.',
            ),
            const SizedBox(height: 8),
            if (plan.warnings.isEmpty)
              const Text('Ek uyari yok.')
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
              'Kaydedilen Hazirlik',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Secim: ${_choiceLabel(preference.choice)}'),
            Text('Conflict kurali: ${_policyLabel(preference.conflictPolicy)}'),
            Text('Hazirlandi: ${formatter.format(preference.preparedAt)}'),
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
        return 'Bu cihazi buluta yukle';
      case SyncBootstrapChoice.downloadCloudData:
        return 'Buluttan cihaza indir';
      case SyncBootstrapChoice.mergeSafely:
        return 'Guvenli birlestir';
    }
  }

  String _policyLabel(SyncConflictPolicy policy) {
    switch (policy) {
      case SyncConflictPolicy.preferDevice:
        return 'Cihaz verisini koru';
      case SyncConflictPolicy.preferCloud:
        return 'Bulut verisini koru';
      case SyncConflictPolicy.preferLatestChange:
        return 'En son degisiklik kazansin';
      case SyncConflictPolicy.manualReview:
        return 'Elle inceleme iste';
    }
  }
}
