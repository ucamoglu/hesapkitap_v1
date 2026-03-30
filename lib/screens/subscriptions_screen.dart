import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/runtime/app_runtime.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/subscription_definition.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/subscription_definition_service.dart';
import '../theme/app_theme_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
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
    ('mobile_line', 'Mobil Hat'),
    ('streaming', 'Yayın Platformu'),
    ('digital_service', 'Dijital Servis'),
    ('insurance', 'Sigorta'),
    ('dues', 'Aidat'),
    ('maintenance', 'Bakım / Servis'),
    ('loan', 'Kredi'),
    ('rent', 'Kira'),
    ('other', 'Diğer'),
  ];
  static const _paymentTypeOptions = <(String, String)>[
    ('variable', 'Değişken Tutar'),
    ('fixed', 'Sabit Tutar'),
  ];
  static const _duePeriodOptions = <(String, String)>[
    ('monthly', 'Aylık'),
    ('yearly', 'Yıllık'),
  ];
  static const _monthOptions = <(int, String)>[
    (1, 'Ocak'),
    (2, 'Şubat'),
    (3, 'Mart'),
    (4, 'Nisan'),
    (5, 'Mayıs'),
    (6, 'Haziran'),
    (7, 'Temmuz'),
    (8, 'Ağustos'),
    (9, 'Eylül'),
    (10, 'Ekim'),
    (11, 'Kasım'),
    (12, 'Aralık'),
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
      AppRuntime.dataLayer.subscriptions.getAll(),
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

  String _paymentTypeLabel(String paymentType) {
    for (final option in _paymentTypeOptions) {
      if (option.$1 == paymentType) return option.$2;
    }
    return paymentType;
  }

  String _duePeriodLabel(String duePeriod) {
    for (final option in _duePeriodOptions) {
      if (option.$1 == duePeriod) return option.$2;
    }
    return duePeriod;
  }

  String? _monthLabel(int? month) {
    if (month == null) return null;
    for (final option in _monthOptions) {
      if (option.$1 == month) return option.$2;
    }
    return null;
  }

  String _fmtAmount(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) {
        b.write('.');
      }
    }
    return '${b.toString()},$decPart';
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
        title: const Text('Sabit Odemelerim'),
        content: const Text(
          'Bu ekranda duzenli fatura ve sabit odeme tanimlarini tutarsin.\n\n'
          'Elektrik, su, doğalgaz, telefon, internet, mobil hat, yayın platformu, sigorta ve benzeri düzenli ödemeleri sağlayıcı, ödeme hesabı, ödeme yapısı ve varsayılan gider kategorisi ile birlikte kaydedebilirsin.\n\n'
          'Bu yapi ileride otomatik gider hazirlama, odeme hatirlatma ve sabit odeme analizi icin temel olusturur.',
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
    final defaultAmountController = TextEditingController(
      text: edit?.defaultAmount == null
          ? ''
          : _fmtAmount(edit!.defaultAmount!),
    );
    final dueDayController =
        TextEditingController(text: edit?.dueDay?.toString() ?? '');
    final noteController = TextEditingController(text: edit?.note ?? '');

    String selectedType = edit?.type ?? _typeOptions.first.$1;
    String selectedPaymentType =
        SubscriptionDefinitionService.isValidPaymentType(edit?.paymentType)
            ? edit!.paymentType.trim().toLowerCase()
            : _paymentTypeOptions.first.$1;
    String selectedDuePeriod =
        SubscriptionDefinitionService.isValidDuePeriod(edit?.duePeriod)
            ? edit!.duePeriod.trim().toLowerCase()
            : _duePeriodOptions.first.$1;
    int? selectedAccountId = edit?.paymentAccountId;
    int? selectedCategoryId = edit?.defaultExpenseCategoryId;
    int? selectedDueMonth = edit?.dueMonth;
    bool autoPay = edit?.isAutoPay ?? false;
    bool isActive = edit?.isActive ?? true;
    String? dueDayError;
    String? dueMonthError;

    void validateDueDay(String raw) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        dueDayError = null;
        return;
      }
      final parsed = int.tryParse(trimmed);
      if (parsed == null || parsed < 1 || parsed > 31) {
        dueDayError = '1 ile 31 arasında olmalı';
        return;
      }
      dueDayError = null;
    }

    void validateDueMonth() {
      if (selectedDuePeriod != 'yearly' || dueDayController.text.trim().isEmpty) {
        dueMonthError = null;
        return;
      }
      if (selectedDueMonth == null) {
        dueMonthError = 'Ay seçilmelidir';
        return;
      }
      dueMonthError = null;
    }

    validateDueDay(dueDayController.text);
    validateDueMonth();

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(edit == null ? 'Yeni Sabit Odeme' : 'Sabit Odeme Duzenle'),
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
                      labelText: 'Sabit Odeme Adi',
                      hintText: 'Ev Elektrik',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Sabit Odeme Turu',
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedPaymentType,
                    decoration: const InputDecoration(
                      labelText: 'Ödeme Yapısı',
                    ),
                    items: _paymentTypeOptions
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
                        selectedPaymentType = value;
                        if (selectedPaymentType == 'variable') {
                          defaultAmountController.clear();
                        }
                      });
                    },
                  ),
                  if (selectedPaymentType == 'fixed') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: defaultAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [TurkishMoneyInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Varsayılan Tutar',
                        hintText: 'Örn: 499,90',
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDuePeriod,
                    decoration: const InputDecoration(
                      labelText: 'Son Ödeme Periyodu',
                    ),
                    items: _duePeriodOptions
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
                        selectedDuePeriod = value;
                        if (selectedDuePeriod == 'monthly') {
                          selectedDueMonth = null;
                        }
                        validateDueMonth();
                      });
                    },
                  ),
                  if (selectedDuePeriod == 'yearly') ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int?>(
                      initialValue: selectedDueMonth,
                      decoration: InputDecoration(
                        labelText: 'Son Ödeme Ayı',
                        errorText: dueMonthError,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Seçilmedi'),
                        ),
                        ..._monthOptions.map(
                          (option) => DropdownMenuItem<int?>(
                            value: option.$1,
                            child: Text(option.$2),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setInnerState(() {
                          selectedDueMonth = value;
                          validateDueMonth();
                        });
                      },
                    ),
                  ],
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    onChanged: (value) {
                      setInnerState(() {
                        validateDueDay(value);
                        validateDueMonth();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Son Ödeme Günü (opsiyonel)',
                      hintText: 'Örn: 15',
                      errorText: dueDayError,
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
                final defaultAmount = TurkishMoneyInputFormatter.parse(
                  defaultAmountController.text,
                );
                validateDueDay(dueDayController.text);
                validateDueMonth();
                if (dueDay != null && (dueDay < 1 || dueDay > 31)) {
                  setInnerState(() {});
                  _showSnack('Son ödeme günü 1 ile 31 arasında olmalıdır.');
                  return;
                }
                if (selectedDuePeriod == 'yearly' &&
                    dueDay != null &&
                    selectedDueMonth == null) {
                  setInnerState(() {});
                  _showSnack('Yıllık son ödeme tarihi için ay seçin.');
                  return;
                }
                if (selectedPaymentType == 'fixed' &&
                    (defaultAmount == null || defaultAmount <= 0)) {
                  _showSnack(
                    'Sabit tutarli gider icin varsayilan tutar girin.',
                  );
                  return;
                }
                final item = edit ?? SubscriptionDefinition();
                item
                  ..name = nameController.text
                  ..type = selectedType
                  ..paymentType = selectedPaymentType
                  ..duePeriod = selectedDuePeriod
                  ..providerName = providerController.text
                  ..subscriberNumber = subscriberController.text
                  ..paymentAccountId = selectedAccountId
                  ..defaultExpenseCategoryId = selectedCategoryId
                  ..defaultAmount = defaultAmount
                  ..dueDay = dueDay
                  ..dueMonth = selectedDuePeriod == 'yearly' ? selectedDueMonth : null
                  ..note = noteController.text
                  ..isAutoPay = autoPay
                  ..isActive = isActive;

                try {
                  if (edit == null) {
                    await AppRuntime.dataLayer.subscriptions.add(item);
                  } else {
                    await AppRuntime.dataLayer.subscriptions.update(item);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await _load();
                  _showSnack(edit == null
                      ? 'Sabit odeme kaydedildi.'
                      : 'Sabit odeme guncellendi.');
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
      await AppRuntime.dataLayer.subscriptions.delete(item.id);
      await _load();
      _showSnack('Sabit odeme silindi.');
    } catch (e) {
      _showSnack('Silme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Sabit Odemelerim'),
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
        label: const Text('Yeni Sabit Odeme'),
      ),
      body: _items.isEmpty
          ? Center(
              child: Text(
                'Henuz sabit odeme tanimlanmadi',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final accent = item.isActive
                    ? Colors.deepOrange
                    : colorScheme.onSurfaceVariant;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.22),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    tileColor: item.isActive
                        ? context.softAccent(Colors.deepOrange, 0.06)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                          'mobile_line' => Icons.sim_card_outlined,
                          'streaming' => Icons.live_tv_outlined,
                          'digital_service' => Icons.cloud_outlined,
                          'insurance' => Icons.health_and_safety_outlined,
                          'dues' => Icons.apartment_outlined,
                          'maintenance' => Icons.build_outlined,
                          'loan' => Icons.account_balance_wallet_outlined,
                          'rent' => Icons.home_outlined,
                          'other' => Icons.more_horiz,
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
                          Text(
                            'Ödeme Yapısı: ${_paymentTypeLabel(item.paymentType)}'
                            '${item.paymentType == 'fixed' && item.defaultAmount != null ? ' • ${_fmtAmount(item.defaultAmount!)} TL' : ''}',
                          ),
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
                            Text(
                              item.duePeriod == 'yearly' && item.dueMonth != null
                                  ? 'Son Ödeme Tarihi: ${item.dueDay} ${_monthLabel(item.dueMonth) ?? ''} • ${_duePeriodLabel(item.duePeriod)}'
                                  : 'Son Ödeme Günü: ${item.dueDay}. gün • ${_duePeriodLabel(item.duePeriod)}',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          else
                            const Text('Son Ödeme Tarihi Yok'),
                          Text(
                            '${item.isAutoPay ? 'Otomatik Ödeme Var' : 'Otomatik Ödeme Yok'} • ${item.isActive ? 'Aktif' : 'Pasif'}',
                          ),
                          if ((item.note ?? '').trim().isNotEmpty)
                            Text('Not: ${item.note}'),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: accent),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _openDialog(edit: item);
                        } else if (value == 'toggle') {
                          await AppRuntime.dataLayer.subscriptions.setActive(
                            item.id,
                            !item.isActive,
                          );
                          await _load();
                          _showSnack(item.isActive
                              ? 'Sabit odeme pasif yapildi.'
                              : 'Sabit odeme aktif yapildi.');
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
