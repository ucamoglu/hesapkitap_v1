import 'package:flutter/material.dart';

import '../models/account.dart';
import '../services/account_service.dart';
import '../services/investment_transaction_service.dart';
import '../services/tracked_currency_service.dart';
import '../services/tracked_metal_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';

class InvestmentEntryScreen extends StatefulWidget {
  const InvestmentEntryScreen({super.key});

  @override
  State<InvestmentEntryScreen> createState() => _InvestmentEntryScreenState();
}

class _InvestmentEntryScreenState extends State<InvestmentEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();

  List<Account> _investmentAccounts = [];
  List<Account> _cashAccounts = [];
  final Map<String, String> _currencyNameByCode = {};
  final Map<String, String> _metalNameByCode = {};

  int? _selectedAccountId;
  int? _selectedCashAccountId;
  String _txType = 'buy';
  DateTime _selectedDate = DateTime.now();
  double? _calculatedUnitPrice;
  FifoSellPreview? _sellPreview;
  String? _lastCalculationKey;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      AccountService.getActiveAccounts(),
      TrackedCurrencyService.getAll(),
      TrackedMetalService.getAll(),
    ]);

    final allAccounts = results[0] as List<Account>;
    final trackedCurrencies = results[1] as List<TrackedCurrencyItem>;
    final trackedMetals = results[2] as List<TrackedMetalItem>;

    for (final c in trackedCurrencies) {
      _currencyNameByCode[c.code.toUpperCase()] = c.name;
    }
    for (final m in trackedMetals) {
      _metalNameByCode[m.code.toUpperCase()] = m.name;
    }

    final investmentAccounts = allAccounts
        .where(
          (a) =>
              a.type == 'investment' &&
              (a.investmentSymbol ?? '').trim().isNotEmpty,
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final cashAccounts = allAccounts
        .where((a) => a.type != 'investment')
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (!mounted) return;
    setState(() {
      _investmentAccounts = investmentAccounts;
      _cashAccounts = cashAccounts;
      _selectedAccountId =
          investmentAccounts.isNotEmpty ? investmentAccounts.first.id : null;
      _selectedCashAccountId =
          cashAccounts.isNotEmpty ? cashAccounts.first.id : null;
      _loading = false;
    });
  }

  Account? _selectedAccount() {
    final id = _selectedAccountId;
    if (id == null) return null;
    for (final a in _investmentAccounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  String _instrumentLabel(Account? account) {
    if (account == null) return '-';
    final symbol = (account.investmentSymbol ?? '').trim();
    if (symbol.isEmpty) return '-';

    final upper = symbol.toUpperCase();
    final subtype = account.investmentSubtype;

    if (subtype == 'currency') {
      final name = _currencyNameByCode[upper] ?? upper;
      return '$name ($upper)';
    }
    if (subtype == 'metal') {
      final name = _metalNameByCode[upper] ?? upper;
      return '$name ($upper)';
    }
    return upper;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  String _buildCalculationKey({
    required int accountId,
    required String txType,
    required double amount,
    required double quantity,
  }) {
    return '$accountId|$txType|${amount.toStringAsFixed(6)}|${quantity.toStringAsFixed(8)}';
  }

  void _invalidateCalculation() {
    _calculatedUnitPrice = null;
    _sellPreview = null;
    _lastCalculationKey = null;
  }

  double? _parseQuantity(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return null;

    String normalized = input;
    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll('.', '');
      normalized = normalized.replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  Future<void> _calculateUnitPrice() async {
    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    final quantity = _parseQuantity(_quantityController.text);
    final account = _selectedAccount();

    if (amount == null ||
        amount <= 0 ||
        quantity == null ||
        quantity <= 0 ||
        account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli tutar ve miktar giriniz.')),
      );
      return;
    }

    final unitPrice = amount / quantity;
    FifoSellPreview? preview;
    if (_txType == 'sell') {
      try {
        preview = await InvestmentTransactionService.previewSell(
          investmentAccountId: account.id,
          symbol: (account.investmentSymbol ?? '').toUpperCase(),
          sellQuantity: quantity,
          sellUnitPrice: unitPrice,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
        return;
      }
    }

    if (!mounted) return;
    final key = _buildCalculationKey(
      accountId: account.id,
      txType: _txType,
      amount: amount,
      quantity: quantity,
    );
    setState(() {
      _calculatedUnitPrice = unitPrice;
      _sellPreview = preview;
      _lastCalculationKey = key;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final account = _selectedAccount();
    final cashAccountId = _selectedCashAccountId;

    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yatırım hesabı seçiniz.')),
      );
      return;
    }
    if (cashAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaynak/Hedef hesap seçiniz.')),
      );
      return;
    }

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    final quantity = _parseQuantity(_quantityController.text);

    if (amount == null || amount <= 0 || quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli tutar ve miktar giriniz.')),
      );
      return;
    }

    final unitPrice = amount / quantity;
    final key = _buildCalculationKey(
      accountId: account.id,
      txType: _txType,
      amount: amount,
      quantity: quantity,
    );
    FifoSellPreview? sellPreview;
    if (_lastCalculationKey == key) {
      sellPreview = _sellPreview;
    } else if (_txType == 'sell') {
      try {
        sellPreview = await InvestmentTransactionService.previewSell(
          investmentAccountId: account.id,
          symbol: (account.investmentSymbol ?? '').toUpperCase(),
          sellQuantity: quantity,
          sellUnitPrice: unitPrice,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
        return;
      }
    }

    setState(() {
      _saving = true;
      _calculatedUnitPrice = unitPrice;
      _sellPreview = sellPreview;
      _lastCalculationKey = key;
    });

    try {
      await InvestmentTransactionService.addAndGetId(
        investmentAccountId: account.id,
        cashAccountId: cashAccountId,
        symbol: (account.investmentSymbol ?? '').toUpperCase(),
        type: _txType,
        quantity: quantity,
        unitPrice: unitPrice,
        total: amount,
        date: _selectedDate,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt hatası: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _fmtMoney(double value) {
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

  String _investmentAccountLabel(Account a) {
    final symbol = (a.investmentSymbol ?? '-').toUpperCase();
    return '${a.name} • Bakiye: ${_fmtQuantity(a.balance)} $symbol';
  }

  String _cashAccountLabel(Account a) {
    return '${a.name} • Bakiye: ${_fmtMoney(a.balance)} TL';
  }

  @override
  Widget build(BuildContext context) {
    final selectedAccount = _selectedAccount();

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Yatırım İşlemi'),
        actions: [buildHomeAction(context)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_investmentAccounts.isEmpty || _cashAccounts.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _investmentAccounts.isEmpty
                          ? 'İşlem için en az bir aktif yatırım hesabı ve bağlı yatırım türü olmalı.'
                          : 'İşlem için en az bir aktif kaynak/hedef hesabı olmalı.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(value: 'buy', label: Text('Alış')),
                          ButtonSegment<String>(value: 'sell', label: Text('Satış')),
                        ],
                        selected: {_txType},
                        onSelectionChanged: (set) {
                          setState(() {
                            _txType = set.first;
                            _invalidateCalculation();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedAccountId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Yatırım Hesabı',
                          border: OutlineInputBorder(),
                        ),
                        items: _investmentAccounts
                            .map(
                              (a) => DropdownMenuItem<int>(
                                value: a.id,
                                child: Text(
                                  _investmentAccountLabel(a),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedAccountId = v;
                            _invalidateCalculation();
                          });
                        },
                        validator: (v) => v == null ? 'Hesap seçiniz.' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCashAccountId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _txType == 'buy' ? 'Kaynak Hesap' : 'Hedef Hesap',
                          border: const OutlineInputBorder(),
                        ),
                        items: _cashAccounts
                            .map(
                              (a) => DropdownMenuItem<int>(
                                value: a.id,
                                child: Text(
                                  _cashAccountLabel(a),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedCashAccountId = v;
                            _invalidateCalculation();
                          });
                        },
                        validator: (v) => v == null ? 'Hesap seçiniz.' : null,
                      ),
                      const SizedBox(height: 12),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tür (hesaba bağlı)',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_instrumentLabel(selectedAccount)),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tarih',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_fmtDate(_selectedDate)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Hesapla',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: const [TurkishMoneyInputFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Tutar (TL)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          if (_calculatedUnitPrice != null ||
                              _sellPreview != null ||
                              _lastCalculationKey != null) {
                            setState(() {
                              _invalidateCalculation();
                            });
                          }
                        },
                        validator: (v) {
                          final parsed = TurkishMoneyInputFormatter.parse(v ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Geçerli tutar giriniz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Miktar',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: 12,50',
                        ),
                        onChanged: (_) {
                          if (_calculatedUnitPrice != null ||
                              _sellPreview != null ||
                              _lastCalculationKey != null) {
                            setState(() {
                              _invalidateCalculation();
                            });
                          }
                        },
                        validator: (v) {
                          final parsed = _parseQuantity(v ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Geçerli miktar giriniz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _calculateUnitPrice,
                        child: const Text('Hesapla'),
                      ),
                      if (_calculatedUnitPrice != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            'Birim Fiyat: ${_fmtMoney(_calculatedUnitPrice!)} TL',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      if (_txType == 'sell' && _sellPreview != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            'FIFO Maliyet: ${_fmtMoney(_sellPreview!.costBasisTotal)} TL\n'
                            'Gerçekleşen K/Z: ${_fmtMoney(_sellPreview!.realizedPnl.abs())} TL ${_sellPreview!.realizedPnl >= 0 ? '(Kar)' : '(Zarar)'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _sellPreview!.realizedPnl >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
