import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/runtime/app_runtime.dart';
import '../models/account.dart';
import '../models/market_rate_item.dart';
import '../services/account_service.dart';
import '../services/market_rate_service.dart';
import '../services/investment_outcome_category_service.dart';
import '../database/isar_service.dart';
import '../services/tracked_crypto_service.dart';
import '../services/tracked_currency_service.dart';
import '../services/tracked_metal_service.dart';
import '../services/tracked_stock_service.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_upper_case_formatter.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> accounts = [];
  Map<String, double> _livePriceBySymbol = {};
  TextEditingController? _dialogNameController;
  TextEditingController? _dialogStatementDayController;
  TextEditingController? _dialogPaymentDueDayController;
  TextEditingController? _dialogOverdraftLimitController;

  Color _accountAccentColor(BuildContext context, Account account) {
    final colorScheme = Theme.of(context).colorScheme;
    if (account.isCreditCard) return Colors.deepOrange;
    switch (account.type) {
      case 'cash':
        return Colors.blue;
      case 'bank':
        return colorScheme.primary;
      case 'balance':
        return Colors.deepPurple;
      case 'investment':
        return Colors.teal;
      default:
        return colorScheme.primary;
    }
  }

  Color _accountSoftColor(BuildContext context, Account account) {
    return _accountAccentColor(context, account).withValues(alpha: 0.10);
  }

  // Ekranda kullanilan kisa bilgi mesajlarini tek yerden gosterir.
  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // TL tutarlarinin liste kartlarinda ayni bicimde gorunmesini saglar.
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

  // Yatirim miktarlarinda gereksiz sifirlari kirparak okunabilirlik saglar.
  String _fmtQuantity(double value) {
    final fixed = value.toStringAsFixed(4);
    final normalized = fixed.replaceFirst(RegExp(r'([.,]?)0+$'), '');
    final parts = normalized.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    if (decPart.isEmpty) return b.toString();
    return '${b.toString()},$decPart';
  }

  // Hesap tipine gore kart alt aciklamasini ve gerekiyorsa canli degeri uretir.
  String _accountSubtitle(Account acc) {
    if (acc.type != 'investment') {
      if (acc.type == 'balance') {
        return 'Denge Hesabı\nHayalet hesap • Özetlerde görünmez';
      }
      if (acc.type == 'cash') {
        return 'Kasa\nBakiye: ${_fmtAmount(acc.balance)} TL';
      }
      if (acc.isCreditCard) {
        final linkedName = _accountNameById(acc.linkedBankAccountId) ?? '-';
        final statementDay = acc.statementDay?.toString() ?? '-';
        final paymentDueDay = acc.paymentDueDay?.toString() ?? '-';
        return 'Kredi Kartı\n'
            'Bağlı Hesap: $linkedName\n'
            'Kesim: $statementDay. gün • Son Ödeme: $paymentDueDay. gün\n'
            'Kart Borcu: ${_fmtAmount(acc.balance.abs())} TL';
      }
      final label = 'Mevduat Hesabı';
      final overdraftText = acc.effectiveOverdraftLimit > 0
          ? '\nEk Hesap: ${_fmtAmount(acc.effectiveOverdraftLimit)} TL'
          : '';
      return '$label\nBakiye: ${_fmtAmount(acc.balance)} TL$overdraftText';
    }

    final symbol = (acc.investmentSymbol ?? '-').toUpperCase();
    final price = _livePriceBySymbol[symbol];
    final currentValue = price == null ? null : (acc.balance * price);
    final valueText = currentValue == null
        ? 'Değeri: Veri yok'
        : 'Değeri: ${_fmtAmount(currentValue)} TL';

    return 'Yatırım • ${_investmentSubtypeLabel(acc.investmentSubtype)} • $symbol\n'
        'Depo: ${_fmtQuantity(acc.balance)} $symbol\n'
        '$valueText';
  }

  String? _accountNameById(int? id) {
    if (id == null) return null;
    for (final account in accounts) {
      if (account.id == id) return account.name;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  @override
  void dispose() {
    _disposeDialogControllers();
    super.dispose();
  }

  void _disposeDialogControllers() {
    _dialogNameController?.dispose();
    _dialogStatementDayController?.dispose();
    _dialogPaymentDueDayController?.dispose();
    _dialogOverdraftLimitController?.dispose();
    _dialogNameController = null;
    _dialogStatementDayController = null;
    _dialogPaymentDueDayController = null;
    _dialogOverdraftLimitController = null;
  }

  // Hesaplari ve canli piyasa degerlerini birlikte yukleyip listeyi tazeler.
  Future<void> loadAccounts() async {
    final data = await AccountService.getAllAccounts();
    final livePriceMap = <String, double>{};
    final stockSymbols = data
        .where(
          (account) =>
              account.type == 'investment' &&
              account.investmentSubtype == 'stock' &&
              (account.investmentSymbol?.trim().isNotEmpty ?? false),
        )
        .map((account) => account.investmentSymbol!.trim().toUpperCase())
        .toSet()
        .toList();
    final cryptoSymbols = data
        .where(
          (account) =>
              account.type == 'investment' &&
              account.investmentSubtype == 'crypto' &&
              (account.investmentSymbol?.trim().isNotEmpty ?? false),
        )
        .map((account) => account.investmentSymbol!.trim().toUpperCase())
        .toSet()
        .toList();

    try {
      final results = await Future.wait<Object?>([
        (() async {
          try {
            return await MarketRateService.fetchAllCurrencies();
          } catch (_) {
            return null;
          }
        })(),
        (() async {
          try {
            return await MarketRateService.fetchAllMetals();
          } catch (_) {
            return null;
          }
        })(),
        (() async {
          if (stockSymbols.isEmpty) return const <MarketRateItem>[];
          try {
            return await MarketRateService.fetchStocksByCodes(stockSymbols);
          } catch (_) {
            return const <MarketRateItem>[];
          }
        })(),
        (() async {
          if (cryptoSymbols.isEmpty) return const <MarketRateItem>[];
          try {
            return await MarketRateService.fetchCryptosByCodes(cryptoSymbols);
          } catch (_) {
            return const <MarketRateItem>[];
          }
        })(),
      ]);

      final currencyRates = (results[0] as CurrencyRateListResult?)?.items ??
          const <MarketRateItem>[];
      final metalRates = (results[1] as MetalRateListResult?)?.items ??
          const <MarketRateItem>[];
      final stockRates = results[2] as List<MarketRateItem>;
      final cryptoRates = results[3] as List<MarketRateItem>;
      final allRates = <MarketRateItem>[
        ...currencyRates,
        ...metalRates,
        ...stockRates,
        ...cryptoRates,
      ];
      for (final item in allRates) {
        livePriceMap[item.code.toUpperCase()] = item.sell;
      }
    } catch (_) {
      // Keep account list usable when live prices are temporarily unavailable.
    }

    if (!mounted) return;
    setState(() {
      accounts = data;
      _livePriceBySymbol = livePriceMap;
    });
  }

  IconData _getIcon(Account account) {
    if (account.isCreditCard) {
      return Icons.credit_card;
    }
    switch (account.type) {
      case "cash":
        return Icons.account_balance_wallet;
      case "bank":
        return Icons.account_balance;
      case "balance":
        return Icons.blur_on;
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
          '• Banka: Banka hesaplarınızı ve kredi kartlarınızı ayırmak için kullanılır.\n'
          '• Yatırım: Altın, döviz, hisse ve kripto gibi yatırım varlıkları için kullanılır.\n\n'
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text("Hesap Tanım"),
        actions: [buildHomeAction(context)],
      ),
      body: accounts.isEmpty
          ? Center(
              child: Text(
                "Henüz hesap tanımlanmadı",
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                final accentColor = _accountAccentColor(context, acc);
                final softColor = _accountSoftColor(context, acc);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.22),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: Icon(
                      _getIcon(acc),
                      color: accentColor,
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
                      _accountSubtitle(acc),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        color: accentColor,
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onSelected: (value) => _handleMenuAction(acc, value),
                      itemBuilder: (context) {
                        final isProtectedBalanceAccount =
                            AccountService.isProtectedBalanceAccount(acc);
                        return [
                          const PopupMenuItem(
                            value: "edit",
                            child: Text("Düzenle"),
                          ),
                          if (!isProtectedBalanceAccount)
                            PopupMenuItem(
                              value: "toggle",
                              child: Text(
                                acc.isActive ? "Pasif Yap" : "Aktif Yap",
                              ),
                            ),
                          if (!isProtectedBalanceAccount)
                            const PopupMenuItem(
                              value: "delete",
                              child: Text("Sil"),
                            ),
                        ];
                      },
                    ),
                    tileColor: softColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
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
    _showAccountDialog();
  }

  Future<void> _showAccountDialog({Account? initialAccount}) async {
    final trackedCurrencies = await TrackedCurrencyService.getAll();
    final trackedMetals = await TrackedMetalService.getAll();
    final trackedStocks = await TrackedStockService.getAll();
    final trackedCryptos = await TrackedCryptoService.getAll();
    final parentBankAccounts = await AccountService.getActiveParentBankAccounts(
      excludeId: initialAccount?.id,
    );
    if (!mounted) return;
    final isProtectedBalanceAccount =
        initialAccount != null &&
        AccountService.isProtectedBalanceAccount(initialAccount);
    _disposeDialogControllers();
    final nameController =
        _dialogNameController =
            TextEditingController(text: initialAccount?.name ?? '');
    final statementDayController =
        _dialogStatementDayController = TextEditingController(
      text: initialAccount?.statementDay?.toString() ?? '',
    );
    final paymentDueDayController =
        _dialogPaymentDueDayController = TextEditingController(
      text: initialAccount?.paymentDueDay?.toString() ?? '',
    );
    final overdraftLimitController =
        _dialogOverdraftLimitController = TextEditingController(
      text: initialAccount == null || initialAccount.effectiveOverdraftLimit <= 0
          ? ''
          : _fmtAmount(initialAccount.effectiveOverdraftLimit),
    );
    String selectedType = initialAccount?.type ?? "cash";
    String? selectedBankSubtype =
        selectedType == 'bank' ? initialAccount?.effectiveBankSubtype : null;
    int? selectedLinkedBankAccountId = initialAccount?.linkedBankAccountId;
    String? selectedInvestmentSubtype = initialAccount?.investmentSubtype;
    String? selectedSymbol = initialAccount?.investmentSymbol;

    int? autoPaymentDueDayFromStatement(String raw) {
      final day = int.tryParse(raw);
      if (day == null || day < 1 || day > 31) return null;
      return DateTime(2024, 1, day + 10).day;
    }

    void syncPaymentDueDayFromStatement() {
      final autoValue = autoPaymentDueDayFromStatement(
        statementDayController.text,
      );
      if (autoValue == null) return;
      paymentDueDayController.value = TextEditingValue(
        text: autoValue.toString(),
        selection: TextSelection.collapsed(
          offset: autoValue.toString().length,
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialAccount == null ? "Yeni Hesap" : "Hesabı Düzenle"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
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
                    if (!isProtectedBalanceAccount) ...[
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
                            if (selectedType != "bank") {
                              selectedBankSubtype = null;
                              selectedLinkedBankAccountId = null;
                              statementDayController.clear();
                              paymentDueDayController.clear();
                            } else {
                              selectedBankSubtype ??=
                                  AccountService.bankSubtypeBankAccount;
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Hesap Türü",
                        ),
                      ),
                    ],
                    if (!isProtectedBalanceAccount &&
                        selectedType == "bank") ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedBankSubtype,
                        items: const [
                          DropdownMenuItem(
                            value: 'bank_account',
                            child: Text('Mevduat Hesabı'),
                          ),
                          DropdownMenuItem(
                            value: 'credit_card',
                            child: Text('Kredi Kartı'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedBankSubtype = value;
                            if (value != AccountService.bankSubtypeCreditCard) {
                              selectedLinkedBankAccountId = null;
                              statementDayController.clear();
                              paymentDueDayController.clear();
                            } else if (paymentDueDayController.text
                                .trim()
                                .isEmpty) {
                              syncPaymentDueDayFromStatement();
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Hesap Alt Türü",
                        ),
                      ),
                    ],
                    if (!isProtectedBalanceAccount &&
                        selectedType == "bank" &&
                        selectedBankSubtype ==
                            AccountService.bankSubtypeBankAccount) ...[
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('bank-overdraft-limit-field'),
                        controller: overdraftLimitController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: const [TurkishMoneyInputFormatter()],
                        decoration: const InputDecoration(
                          labelText: "Ek Hesap Tutarı",
                          hintText: "Opsiyonel",
                        ),
                      ),
                    ],
                    if (!isProtectedBalanceAccount &&
                        selectedType == "bank" &&
                        selectedBankSubtype ==
                            AccountService.bankSubtypeCreditCard) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        key: const ValueKey('credit-card-linked-account-field'),
                        initialValue: selectedLinkedBankAccountId,
                        items: parentBankAccounts
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(
                                  '${e.name} • ${_fmtAmount(e.balance)} TL',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLinkedBankAccountId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Bağlı Banka Hesabı",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('credit-card-statement-day-field'),
                        controller: statementDayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) {
                          syncPaymentDueDayFromStatement();
                        },
                        decoration: const InputDecoration(
                          labelText: "Hesap Kesim Günü",
                          hintText: "1-31",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('credit-card-payment-due-day-field'),
                        controller: paymentDueDayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: "Son Ödeme Günü",
                          hintText: "1-31",
                        ),
                      ),
                      if (parentBankAccounts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Önce banka türünde ve alt türü mevduat hesabı olan aktif bir hesap ekleyiniz.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment") ...[
                      const SizedBox(height: 12),
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
                            child: Text("Kripto"),
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
                    ],
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
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
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
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
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
                        selectedInvestmentSubtype == "stock")
                      DropdownButtonFormField<String>(
                        initialValue: selectedSymbol,
                        items: trackedStocks
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
                          labelText: "Kayıtlı Hisse Seçimi",
                        ),
                      ),
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
                        selectedInvestmentSubtype == "crypto")
                      DropdownButtonFormField<String>(
                        initialValue: selectedSymbol,
                        items: trackedCryptos
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
                          labelText: "Kayıtlı Kripto Seçimi",
                        ),
                      ),
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
                        selectedInvestmentSubtype == "currency" &&
                        trackedCurrencies.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Önce Döviz Takip ekranından döviz ekleyiniz.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
                        selectedInvestmentSubtype == "metal" &&
                        trackedMetals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Önce Kıymetli Maden Takip ekranından maden ekleyiniz.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
                        selectedInvestmentSubtype == "stock" &&
                        trackedStocks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Önce Borsa Takip ekranından hisse ekleyiniz.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (!isProtectedBalanceAccount &&
                        selectedType == "investment" &&
                        selectedInvestmentSubtype == "crypto" &&
                        trackedCryptos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Önce Kripto Takip ekranından kripto ekleyiniz.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
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

                if (!isProtectedBalanceAccount &&
                    selectedType == "bank" &&
                    selectedBankSubtype == null) {
                  _showSnack("Banka türü için hesap alt türü seçiniz.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "bank" &&
                    selectedBankSubtype ==
                        AccountService.bankSubtypeCreditCard &&
                    selectedLinkedBankAccountId == null) {
                  _showSnack("Kredi kartı için bağlı banka hesabı seçiniz.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "bank" &&
                    selectedBankSubtype ==
                        AccountService.bankSubtypeCreditCard &&
                    parentBankAccounts.isEmpty) {
                  _showSnack(
                    "Önce aktif bir mevduat hesabı tanımlayınız.",
                  );
                  return;
                }
                final statementDay = int.tryParse(statementDayController.text);
                final paymentDueDay =
                    int.tryParse(paymentDueDayController.text);
                final overdraftLimit = TurkishMoneyInputFormatter.parse(
                      overdraftLimitController.text,
                    ) ??
                    0;
                if (!isProtectedBalanceAccount &&
                    selectedType == "bank" &&
                    selectedBankSubtype ==
                        AccountService.bankSubtypeBankAccount &&
                    overdraftLimit < 0) {
                  _showSnack("Ek hesap tutarı negatif olamaz.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "bank" &&
                    selectedBankSubtype ==
                        AccountService.bankSubtypeCreditCard &&
                    (statementDay == null ||
                        statementDay < 1 ||
                        statementDay > 31)) {
                  _showSnack("Hesap kesim günü 1-31 arasında olmalıdır.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "bank" &&
                    selectedBankSubtype ==
                        AccountService.bankSubtypeCreditCard &&
                    (paymentDueDay == null ||
                        paymentDueDay < 1 ||
                        paymentDueDay > 31)) {
                  _showSnack("Son ödeme günü 1-31 arasında olmalıdır.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "investment" &&
                    selectedInvestmentSubtype == null) {
                  _showSnack("Yatırım hesabı için alt tür seçiniz.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "investment" &&
                    selectedInvestmentSubtype == "currency" &&
                    selectedSymbol == null) {
                  _showSnack("Döviz alt türü için kayıtlı döviz seçiniz.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "investment" &&
                    selectedInvestmentSubtype == "metal" &&
                    selectedSymbol == null) {
                  _showSnack(
                    "Kıymetli maden alt türü için kayıtlı maden seçiniz.",
                  );
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "investment" &&
                    selectedInvestmentSubtype == "stock" &&
                    selectedSymbol == null) {
                  _showSnack("Borsa alt türü için kayıtlı hisse seçiniz.");
                  return;
                }
                if (!isProtectedBalanceAccount &&
                    selectedType == "investment" &&
                    selectedInvestmentSubtype == "crypto" &&
                    selectedSymbol == null) {
                  _showSnack("Kripto alt türü için kayıtlı kripto seçiniz.");
                  return;
                }

                final account = initialAccount ?? Account();
                account.name = name;
                if (!isProtectedBalanceAccount) {
                  account
                    ..type = selectedType
                    ..bankSubtype =
                        selectedType == 'bank' ? selectedBankSubtype : null
                    ..overdraftLimit = selectedType == 'bank' &&
                            selectedBankSubtype ==
                                AccountService.bankSubtypeBankAccount
                        ? overdraftLimit
                        : 0
                    ..linkedBankAccountId = selectedType == 'bank' &&
                            selectedBankSubtype ==
                                AccountService.bankSubtypeCreditCard
                        ? selectedLinkedBankAccountId
                        : null
                    ..statementDay = selectedType == 'bank' &&
                            selectedBankSubtype ==
                                AccountService.bankSubtypeCreditCard
                        ? statementDay
                        : null
                    ..paymentDueDay = selectedType == 'bank' &&
                            selectedBankSubtype ==
                                AccountService.bankSubtypeCreditCard
                        ? paymentDueDay
                        : null
                    ..investmentSubtype = selectedInvestmentSubtype
                    ..investmentSymbol = selectedSymbol;
                }

                if (initialAccount == null) {
                  account
                    ..isActive = true
                    ..createdAt = DateTime.now();
                }

                try {
                  if (initialAccount == null) {
                    await AppRuntime.dataLayer.accounts.add(account);
                  } else {
                    await AppRuntime.dataLayer.accounts.update(account);
                  }
                  if (selectedType == 'investment' &&
                      selectedSymbol != null &&
                      selectedSymbol!.trim().isNotEmpty) {
                    await IsarService.isar.writeTxn(() async {
                      await InvestmentOutcomeCategoryService
                          .ensurePairForSymbol(
                        isar: IsarService.isar,
                        symbol: selectedSymbol!,
                      );
                    });
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await loadAccounts();
                } catch (e) {
                  _showSnack(
                    initialAccount == null
                        ? "Kayıt hatası: $e"
                        : "Güncelleme hatası: $e",
                  );
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
    _showAccountDialog(initialAccount: account);
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
                final deleted =
                    await AppRuntime.dataLayer.accounts.delete(account.id);
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
      await AppRuntime.dataLayer.accounts.setActive(
        account.id,
        !account.isActive,
      );
      await loadAccounts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
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
        return 'Kripto';
      case 'stock':
        return 'Borsa';
      default:
        return 'Yatırım';
    }
  }
}
