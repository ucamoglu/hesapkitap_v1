import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/investment_outcome_category_service.dart';
import '../database/isar_service.dart';
import '../services/tracked_currency_service.dart';
import '../services/tracked_metal_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_upper_case_formatter.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> accounts = [];

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    return '${b.toString()},$decPart';
  }

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final data = await AccountService.getAllAccounts();
    setState(() {
      accounts = data;
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "cash":
        return Icons.account_balance_wallet;
      case "bank":
        return Icons.account_balance;
      case "investment":
        return Icons.trending_up;
      default:
        return Icons.help;
    }
  }

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hesap Tanım'),
        content: const Text(
          'Bu ekranda para hareketlerinin bağlanacağı hesapları tanımlarsınız.\n\n'
          '• Kasa: Nakit cüzdan/paranız için kullanılır.\n'
          '• Banka: Banka hesaplarınızı ayırmak için kullanılır.\n'
          '• Yatırım: Altın, döviz gibi yatırım hesapları için kullanılır.\n\n'
          'Gelir, gider, cari ve planlama işlemleri doğru raporlanabilmesi için hesaplara bağlı çalışır.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text("Hesap Tanım"),
        actions: [buildHomeAction(context)],
      ),
      body: accounts.isEmpty
          ? const Center(
              child: Text(
                "Henüz hesap tanımlanmadı",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      _getIcon(acc.type),
                      color: Colors.deepPurple,
                    ),
                    title: Text(
                      acc.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            acc.isActive ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      '${acc.type == "investment"
                              ? "Yatırım • ${_investmentSubtypeLabel(acc.investmentSubtype)} • ${acc.investmentSymbol ?? "-"}"
                              : acc.type == "cash"
                                  ? "Kasa"
                                  : "Banka"}\n'
                      'Bakiye: ${_fmtAmount(acc.balance)} TL',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(acc, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "edit",
                          child: Text("Düzenle"),
                        ),
                        PopupMenuItem(
                          value: "toggle",
                          child: Text(acc.isActive ? "Pasif Yap" : "Aktif Yap"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Sil"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: FloatingActionButton.small(
              heroTag: 'accounts_info_fab',
              tooltip: 'Bilgi',
              onPressed: _showInfoDialog,
              child: const Icon(Icons.info_outline),
            ),
          ),
          FloatingActionButton(
            heroTag: 'accounts_add_fab',
            onPressed: _showAddAccountDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog() {
    _showAddAccountDialogInternal();
  }

  Future<void> _showAddAccountDialogInternal() async {
    final trackedCurrencies = await TrackedCurrencyService.getAll();
    final trackedMetals = await TrackedMetalService.getAll();
    if (!mounted) return;
    final nameController = TextEditingController();
    String selectedType = "cash";
    String? selectedInvestmentSubtype;
    String? selectedSymbol;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Hesap"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: const [TurkishUpperCaseFormatter()],
                    decoration: const InputDecoration(
                      labelText: "Hesap Adı",
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: "cash",
                        child: Text("Kasa"),
                      ),
                      DropdownMenuItem(
                        value: "bank",
                        child: Text("Banka"),
                      ),
                      DropdownMenuItem(
                        value: "investment",
                        child: Text("Yatırım"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        if (selectedType != "investment") {
                          selectedInvestmentSubtype = null;
                          selectedSymbol = null;
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Hesap Türü",
                    ),
                  ),
                  if (selectedType == "investment")
                    DropdownButtonFormField<String>(
                      initialValue: selectedInvestmentSubtype,
                      items: const [
                        DropdownMenuItem(
                          value: "currency",
                          child: Text("Döviz"),
                        ),
                        DropdownMenuItem(
                          value: "metal",
                          child: Text("Kıymetli Maden"),
                        ),
                        DropdownMenuItem(
                          value: "crypto",
                          child: Text("Bitcoin"),
                        ),
                        DropdownMenuItem(
                          value: "stock",
                          child: Text("Borsa"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedInvestmentSubtype = value;
                          selectedSymbol = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Yatırım Alt Türü",
                      ),
                    ),
                  if (selectedType == "investment" &&
                      selectedInvestmentSubtype == "currency")
                    DropdownButtonFormField<String>(
                      initialValue: selectedSymbol,
                      items: trackedCurrencies
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.code,
                              child: Text('${e.name} (${e.code})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSymbol = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Kayıtlı Döviz Seçimi",
                      ),
                    ),
                  if (selectedType == "investment" &&
                      selectedInvestmentSubtype == "metal")
                    DropdownButtonFormField<String>(
                      initialValue: selectedSymbol,
                      items: trackedMetals
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.code,
                              child: Text('${e.name} (${e.code})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSymbol = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Kayıtlı Kıymetli Maden Seçimi",
                      ),
                    ),
                  if (selectedType == "investment" &&
                      selectedInvestmentSubtype == "currency" &&
                      trackedCurrencies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Önce Döviz Takip ekranından döviz ekleyiniz.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (selectedType == "investment" &&
                      selectedInvestmentSubtype == "metal" &&
                      trackedMetals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Önce Kıymetli Maden Takip ekranından maden ekleyiniz.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  _showSnack("Hesap adı zorunludur.");
                  return;
                }

                if (selectedType == "investment" &&
                    selectedInvestmentSubtype == null) {
                  _showSnack("Yatırım hesabı için alt tür seçiniz.");
                  return;
                }
                if (selectedType == "investment" &&
                    selectedInvestmentSubtype == "currency" &&
                    selectedSymbol == null) {
                  _showSnack("Döviz alt türü için kayıtlı döviz seçiniz.");
                  return;
                }
                if (selectedType == "investment" &&
                    selectedInvestmentSubtype == "metal" &&
                    selectedSymbol == null) {
                  _showSnack(
                    "Kıymetli maden alt türü için kayıtlı maden seçiniz.",
                  );
                  return;
                }

                final account = Account()
                  ..name = name
                  ..type = selectedType
                  ..investmentSubtype = selectedInvestmentSubtype
                  ..investmentSymbol = selectedSymbol
                  ..isActive = true
                  ..createdAt = DateTime.now();

                try {
                  await AccountService.addAccount(account);
                  if (selectedType == 'investment' &&
                      selectedSymbol != null &&
                      selectedSymbol!.trim().isNotEmpty) {
                    await IsarService.isar.writeTxn(() async {
                      await InvestmentOutcomeCategoryService.ensurePairForSymbol(
                        isar: IsarService.isar,
                        symbol: selectedSymbol!,
                      );
                    });
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await loadAccounts();
                } catch (e) {
                  _showSnack("Kayıt hatası: $e");
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  void _showEditAccountDialog(Account account) {
    final nameController = TextEditingController(text: account.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hesabı Düzenle"),
        content: TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration: const InputDecoration(labelText: "Hesap Adı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              account.name = nameController.text;

              await AccountService.updateAccount(account);
              if (!mounted) return;

              Navigator.pop(context);
              loadAccounts();
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Future<String?> _confirmDelete(Account account) async {
    return await showDialog<String>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Hesap Sil"),
            content: Text("${account.name} silinsin mi?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, "cancel"),
                child: const Text("İptal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final deleted = await AccountService.deleteAccount(account.id);
                    if (!mounted) return;
                    Navigator.pop(context, deleted ? "deleted" : "passived");
                  } catch (_) {
                    if (!mounted) return;
                    Navigator.pop(context, "blocked_balance");
                  }
                },
                child: const Text("Sil"),
              ),
            ],
          ),
        );
  }

  Future<void> _toggleActive(Account account) async {
    try {
      await AccountService.setActive(account.id, !account.isActive);
      await loadAccounts();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bakiyesi 0'dan büyük hesap pasife alınamaz."),
        ),
      );
    }
  }

  Future<void> _handleMenuAction(Account acc, String value) async {
    if (value == "edit") {
      _showEditAccountDialog(acc);
      return;
    }
    if (value == "toggle") {
      await _toggleActive(acc);
      return;
    }
    if (value == "delete") {
      final result = await _confirmDelete(acc);
      if (!mounted) return;
      if (result == "deleted" || result == "passived") {
        await loadAccounts();
      }
      if (result == "passived") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Bu hesap işlemde kullanılmış. Silinmedi, pasife alındı.",
            ),
          ),
        );
      }
      if (result == "blocked_balance") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bakiyesi 0'dan büyük hesap pasife alınamaz."),
          ),
        );
      }
    }
  }

  String _investmentSubtypeLabel(String? subtype) {
    switch (subtype) {
      case 'currency':
        return 'Döviz';
      case 'metal':
        return 'Kıymetli Maden';
      case 'crypto':
        return 'Bitcoin';
      case 'stock':
        return 'Borsa';
      default:
        return 'Yatırım';
    }
  }
}
