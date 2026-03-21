import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/subscription_definition.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/subscription_definition_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_upper_case_formatter.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<SubscriptionDefinition> _items = [];
  List<Account> _accounts = [];
  List<Category> _categories = [];

  static const _typeOptions = <(String, String)>[
    ('electricity', 'Elektrik'),
    ('water', 'Su'),
    ('natural_gas', 'Doğalgaz'),
    ('phone', 'Telefon'),
    ('internet', 'İnternet'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _load() async {
    final results = await Future.wait([
      SubscriptionDefinitionService.getAll(),
      AccountService.getActiveExpenseAccounts(),
      CategoryService.getActiveManualExpenseCategories(),
    ]);
    if (!mounted) return;
    setState(() {
      _items = results[0] as List<SubscriptionDefinition>;
      _accounts = results[1] as List<Account>;
      _categories = results[2] as List<Category>;
    });
  }

  String _typeLabel(String type) {
    for (final option in _typeOptions) {
      if (option.$1 == type) return option.$2;
    }
    return type;
  }

  String? _accountName(int? id) {
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account.name;
    }
    return null;
  }

  String? _categoryName(int? id) {
    if (id == null) return null;
    for (final category in _categories) {
      if (category.id == id) return category.name;
    }
    return null;
  }

  Future<void> _showInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aboneliklerim'),
        content: const Text(
          'Bu ekranda düzenli fatura ve abonelik tanımlarını tutarsın.\n\n'
          'Elektrik, su, doğalgaz, telefon ve internet aboneliklerini sağlayıcı, ödeme hesabı ve varsayılan gider kategorisi ile birlikte kaydedebilirsin.\n\n'
          'Bu yapı ileride otomatik gider hazırlama, ödeme hatırlatma ve abonelik analizi için temel oluşturur.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDialog({SubscriptionDefinition? edit}) async {
    final nameController = TextEditingController(text: edit?.name ?? '');
    final providerController =
        TextEditingController(text: edit?.providerName ?? '');
    final subscriberController =
        TextEditingController(text: edit?.subscriberNumber ?? '');
    final dueDayController =
        TextEditingController(text: edit?.dueDay?.toString() ?? '');
    final noteController = TextEditingController(text: edit?.note ?? '');

    String selectedType = edit?.type ?? _typeOptions.first.$1;
    int? selectedAccountId = edit?.paymentAccountId;
    int? selectedCategoryId = edit?.defaultExpenseCategoryId;
    bool autoPay = edit?.isAutoPay ?? false;
    bool isActive = edit?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(edit == null ? 'Yeni Abonelik' : 'Abonelik Düzenle'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    inputFormatters: const [TurkishUpperCaseFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Abonelik Adı',
                      hintText: 'Ev Elektrik',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Abonelik Türü',
                    ),
                    items: _typeOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.$1,
                            child: Text(option.$2),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setInnerState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: providerController,
                    inputFormatters: const [TurkishUpperCaseFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Sağlayıcı / Kurum',
                      hintText: 'TÜRK TELEKOM',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subscriberController,
                    decoration: const InputDecoration(
                      labelText: 'Abone / Sözleşme No (opsiyonel)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int?>(
                    initialValue: selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Ödeme Hesabı (opsiyonel)',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Seçilmedi'),
                      ),
                      ..._accounts.map(
                        (account) => DropdownMenuItem<int?>(
                          value: account.id,
                          child: Text(account.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setInnerState(() {
                        selectedAccountId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int?>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Varsayılan Kategori (opsiyonel)',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Seçilmedi'),
                      ),
                      ..._categories.map(
                        (category) => DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setInnerState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dueDayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Son Ödeme Günü (opsiyonel)',
                      hintText: 'Örn: 15',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Not (opsiyonel)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: autoPay,
                    onChanged: (value) {
                      setInnerState(() {
                        autoPay = value;
                      });
                    },
                    title: const Text('Otomatik Ödeme Var'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: isActive,
                    onChanged: (value) {
                      setInnerState(() {
                        isActive = value;
                      });
                    },
                    title: const Text('Aktif'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dueDay = int.tryParse(dueDayController.text.trim());
                final item = edit ?? SubscriptionDefinition();
                item
                  ..name = nameController.text
                  ..type = selectedType
                  ..providerName = providerController.text
                  ..subscriberNumber = subscriberController.text
                  ..paymentAccountId = selectedAccountId
                  ..defaultExpenseCategoryId = selectedCategoryId
                  ..dueDay = dueDay
                  ..note = noteController.text
                  ..isAutoPay = autoPay
                  ..isActive = isActive;

                try {
                  if (edit == null) {
                    await SubscriptionDefinitionService.add(item);
                  } else {
                    await SubscriptionDefinitionService.update(item);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await _load();
                  _showSnack(edit == null
                      ? 'Abonelik kaydedildi.'
                      : 'Abonelik güncellendi.');
                } catch (e) {
                  _showSnack('$e');
                }
              },
              child: Text(edit == null ? 'Kaydet' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(SubscriptionDefinition item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aboneliği Sil'),
        content: Text('${item.name} silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await SubscriptionDefinitionService.delete(item.id);
      await _load();
      _showSnack('Abonelik silindi.');
    } catch (e) {
      _showSnack('Silme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Aboneliklerim'),
        actions: [
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Bilgi',
          ),
          buildHomeAction(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Abonelik'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'Henüz abonelik tanımlanmadı',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: item.isActive
                          ? Colors.orange.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.14),
                      child: Icon(
                        switch (item.type) {
                          'electricity' => Icons.bolt_outlined,
                          'water' => Icons.water_drop_outlined,
                          'natural_gas' => Icons.local_fire_department_outlined,
                          'phone' => Icons.phone_iphone_outlined,
                          'internet' => Icons.wifi_outlined,
                          _ => Icons.receipt_long_outlined,
                        },
                        color: item.isActive ? Colors.orange : Colors.grey,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_typeLabel(item.type)} • ${item.providerName}'),
                          if ((item.subscriberNumber ?? '').trim().isNotEmpty)
                            Text('Abone No: ${item.subscriberNumber}'),
                          if (_accountName(item.paymentAccountId) != null)
                            Text(
                                'Ödeme Hesabı: ${_accountName(item.paymentAccountId)}'),
                          if (_categoryName(item.defaultExpenseCategoryId) !=
                              null)
                            Text(
                                'Varsayılan Kategori: ${_categoryName(item.defaultExpenseCategoryId)}'),
                          if (item.dueDay != null)
                            Text('Son Ödeme Günü: ${item.dueDay}. gün'),
                          Text(
                            '${item.isAutoPay ? 'Otomatik Ödeme Var' : 'Otomatik Ödeme Yok'} • ${item.isActive ? 'Aktif' : 'Pasif'}',
                          ),
                          if ((item.note ?? '').trim().isNotEmpty)
                            Text('Not: ${item.note}'),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _openDialog(edit: item);
                        } else if (value == 'toggle') {
                          await SubscriptionDefinitionService.setActive(
                            item.id,
                            !item.isActive,
                          );
                          await _load();
                          _showSnack(item.isActive
                              ? 'Abonelik pasif yapıldı.'
                              : 'Abonelik aktif yapıldı.');
                        } else if (value == 'delete') {
                          await _delete(item);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Düzenle'),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(item.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Sil'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
