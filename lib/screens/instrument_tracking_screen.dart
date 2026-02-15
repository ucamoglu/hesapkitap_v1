import 'dart:async';

import 'package:flutter/material.dart';

import '../models/market_rate_item.dart';
import '../utils/navigation_helpers.dart';

class TrackingItemView {
  final String code;
  final String name;
  final bool isActive;

  const TrackingItemView({
    required this.code,
    required this.name,
    required this.isActive,
  });
}

class TrackingLoadData {
  final List<TrackingItemView> tracked;
  final List<MarketRateItem> allRates;
  final DateTime fetchedAt;

  const TrackingLoadData({
    required this.tracked,
    required this.allRates,
    required this.fetchedAt,
  });
}

class TrackingLinkStatus {
  final bool hasAny;
  final bool hasActive;

  const TrackingLinkStatus({
    required this.hasAny,
    required this.hasActive,
  });
}

class InstrumentTrackingScreen extends StatefulWidget {
  final String title;
  final String selectTitle;
  final String emptyMessage;
  final String noCandidateMessage;
  final String loadErrorPrefix;
  final String blockedDeactivateMessage;
  final String blockedDeleteMessage;
  final String linkedPassiveMessage;
  final String linkedActiveLabel;
  final String linkedPassiveLabel;
  final String linkedNoneLabel;
  final Future<TrackingLoadData> Function() loadData;
  final Future<void> Function(MarketRateItem item) addOrUpdate;
  final Future<void> Function(String code, bool isActive) setActive;
  final Future<void> Function(String code) remove;
  final Future<TrackingItemView?> Function(String code) getByCode;
  final Future<TrackingLinkStatus> Function(String code) linkStatusByCode;
  final Widget Function(MarketRateItem? rate) trailingBuilder;
  final Duration refreshInterval;

  const InstrumentTrackingScreen({
    required this.title,
    required this.selectTitle,
    required this.emptyMessage,
    required this.noCandidateMessage,
    required this.loadErrorPrefix,
    required this.blockedDeactivateMessage,
    required this.blockedDeleteMessage,
    required this.linkedPassiveMessage,
    required this.linkedActiveLabel,
    required this.linkedPassiveLabel,
    required this.linkedNoneLabel,
    required this.loadData,
    required this.addOrUpdate,
    required this.setActive,
    required this.remove,
    required this.getByCode,
    required this.linkStatusByCode,
    required this.trailingBuilder,
    this.refreshInterval = const Duration(hours: 1),
    super.key,
  });

  @override
  State<InstrumentTrackingScreen> createState() => _InstrumentTrackingScreenState();
}

class _InstrumentTrackingScreenState extends State<InstrumentTrackingScreen> {
  List<TrackingItemView> _tracked = const [];
  List<MarketRateItem> _allItems = const [];
  Map<String, MarketRateItem> _rateByCode = const {};
  DateTime? _lastUpdated;
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(widget.refreshInterval, (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final data = await widget.loadData();
      final map = <String, MarketRateItem>{for (final i in data.allRates) i.code: i};
      if (!mounted) return;
      setState(() {
        _tracked = data.tracked;
        _allItems = data.allRates;
        _rateByCode = map;
        _lastUpdated = data.fetchedAt;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '${widget.loadErrorPrefix}: $e';
      });
    }
  }

  Future<void> _openAddDialog() async {
    if (_loading) return;
    final trackedCodes = _tracked.map((e) => e.code).toSet();
    final candidates = _allItems.where((e) => !trackedCodes.contains(e.code)).toList();
    if (candidates.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.noCandidateMessage)),
      );
      return;
    }

    String query = '';
    final selected = await showModalBottomSheet<MarketRateItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final q = query.trim().toLowerCase();
          final filtered = candidates.where((e) {
            if (q.isEmpty) return true;
            return e.code.toLowerCase().contains(q) || e.name.toLowerCase().contains(q);
          }).toList();

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.75,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      widget.selectTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Ara (kod veya ad)',
                      ),
                      onChanged: (v) {
                        setModalState(() {
                          query = v;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        return ListTile(
                          title: Text('${item.code} - ${item.name}'),
                          onTap: () => Navigator.pop(ctx, item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (selected == null) return;
    await widget.addOrUpdate(selected);
    await _load(silent: true);
  }

  Future<void> _deleteOrPassive(TrackingItemView tracked) async {
    final link = await widget.linkStatusByCode(tracked.code);
    if (link.hasAny) {
      if (link.hasActive) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.blockedDeleteMessage)),
        );
        return;
      }
      await widget.setActive(tracked.code, false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.linkedPassiveMessage)),
      );
      await _load(silent: true);
      return;
    }

    await widget.remove(tracked.code);
    await _load(silent: true);
  }

  Future<void> _showActions(TrackingItemView tracked) async {
    final latest = await widget.getByCode(tracked.code);
    if (latest == null) return;
    final link = await widget.linkStatusByCode(latest.code);
    if (!mounted) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('${latest.code} - ${latest.name}'),
              subtitle: Text(
                link.hasActive
                    ? widget.linkedActiveLabel
                    : (link.hasAny ? widget.linkedPassiveLabel : widget.linkedNoneLabel),
              ),
            ),
            const Divider(height: 1),
            if (latest.isActive)
              ListTile(
                leading: const Icon(Icons.pause_circle_outline),
                title: const Text('Pasif Yap'),
                onTap: () => Navigator.pop(ctx, 'deactivate'),
              )
            else
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Aktif Yap'),
                onTap: () => Navigator.pop(ctx, 'activate'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Sil'),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (action == 'activate') {
      await widget.setActive(latest.code, true);
      await _load(silent: true);
      return;
    }
    if (action == 'deactivate') {
      if (link.hasActive) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.blockedDeactivateMessage)),
        );
        return;
      }
      await widget.setActive(latest.code, false);
      await _load(silent: true);
      return;
    }
    if (action == 'delete') {
      await _deleteOrPassive(latest);
    }
  }

  String _fmtTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.${dt.year} $h:$min';
  }

  Widget _buildTrackedCard(TrackingItemView tracked) {
    return Card(
      child: ListTile(
        title: Text('${tracked.code} - ${tracked.name}'),
        trailing: widget.trailingBuilder(_rateByCode[tracked.code]),
        onTap: () => _showActions(tracked),
        onLongPress: () => _showActions(tracked),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeItems = _tracked.where((e) => e.isActive).toList();
    final passiveItems = _tracked.where((e) => !e.isActive).toList();

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
          buildHomeAction(context),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_lastUpdated != null)
                        Text(
                          'Son güncelleme: ${_fmtTime(_lastUpdated!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 12),
                      if (_tracked.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              widget.emptyMessage,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else ...[
                        if (activeItems.isNotEmpty) ...[
                          const Text(
                            'Aktif Takipler',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...activeItems.map(_buildTrackedCard),
                        ],
                        if (passiveItems.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          const Text(
                            'Pasif Takipler',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...passiveItems.map(_buildTrackedCard),
                        ],
                      ],
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
