import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/account.dart';
import '../models/cari_card.dart';
import '../models/cari_transaction.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/transaction_attachment_service.dart';
import '../utils/camera_support.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class CariAccountScreen extends StatefulWidget {
  const CariAccountScreen({
    super.key,
    this.initialTransaction,
  });

  final CariTransaction? initialTransaction;

  @override
  State<CariAccountScreen> createState() => _CariAccountScreenState();
}

class _CariAccountScreenState extends State<CariAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<CariCard> _cards = [];
  List<Account> _accounts = [];
  int? _selectedCardId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isDebt = true;
  bool _loading = true;
  bool _saving = false;
  final List<Uint8List> _attachments = [];
  final List<Uint8List> _existingAttachments = [];

  bool get _isEditMode => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<CariCard> _uniqueCardsById(Iterable<CariCard> items) {
    final map = <int, CariCard>{};
    for (final item in items) {
      map[item.id] = item;
    }
    return map.values.toList();
  }

  List<Account> _uniqueAccountsById(Iterable<Account> items) {
    final map = <int, Account>{};
    for (final item in items) {
      map[item.id] = item;
    }
    return map.values.toList();
  }

  Future<void> _load() async {
    final allCards = await CariCardService.getAll();
    final activeAccounts = await AccountService.getActiveAccounts();
    final allAccounts = _isEditMode
        ? await AccountService.getAllAccounts()
        : const <Account>[];

    final tx = widget.initialTransaction;
    final activeCards = allCards.where((e) => e.isActive).toList();
    CariCard? editCard;
    Account? editAccount;
    if (tx != null) {
      for (final card in allCards) {
        if (card.id == tx.cariCardId) {
          editCard = card;
          break;
        }
      }
      for (final account in allAccounts) {
        if (account.id == tx.accountId) {
          editAccount = account;
          break;
        }
      }
    }

    final cards = _uniqueCardsById([
      ...activeCards,
      if (editCard != null) editCard,
    ]);
    final accounts = _uniqueAccountsById([
      ...activeAccounts,
      if (editAccount != null) editAccount,
    ]);

    if (_isEditMode) {
      final tx = widget.initialTransaction!;
      final existing = await TransactionAttachmentService.getByOwner(
        ownerType: 'cari',
        ownerId: tx.id,
      );
      _existingAttachments
        ..clear()
        ..addAll(existing.map((e) => Uint8List.fromList(e.imageBytes)));
    }

    if (!mounted) return;
    setState(() {
      _cards = cards;
      _accounts = accounts;
      if (_isEditMode) {
        final tx = widget.initialTransaction!;
        _selectedCardId = _cards.any((e) => e.id == tx.cariCardId)
            ? tx.cariCardId
            : (_cards.isNotEmpty ? _cards.first.id : null);
        _selectedAccountId = _accounts.any((e) => e.id == tx.accountId)
            ? tx.accountId
            : (_accounts.isNotEmpty ? _accounts.first.id : null);
        _selectedDate = tx.date;
        _isDebt = tx.type == 'debt';
        _amountController.text = _fmtAmount(tx.amount);
        _quantityController.text = tx.quantity == null
            ? ''
            : tx.quantity!.toString().replaceAll('.', ',');
        _noteController.text = tx.description ?? '';
      } else {
        _selectedCardId = _cards.isNotEmpty ? _cards.first.id : null;
        _selectedAccountId = _accounts.isNotEmpty ? _accounts.first.id : null;
      }
      _loading = false;
    });
  }

  CariCard? _selectedCard() {
    final id = _selectedCardId;
    if (id == null) return null;
    for (final c in _cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  bool _isSelectedCardForeign() {
    final c = _selectedCard();
    return c?.currencyType == 'foreign';
  }

  String _foreignUnitLabel() {
    final c = _selectedCard();
    if (c == null || c.currencyType != 'foreign') return 'Miktar';
    final unit = _currencyTypeLabel(c);
    return unit.isEmpty ? 'Miktar' : 'Miktar ($unit)';
  }

  String _cardLabel(CariCard c) {
    final currency = _currencyTypeLabel(c);
    final suffix = currency.isEmpty ? '' : ' - $currency';
    if (c.type == 'company') {
      final title = c.title?.isNotEmpty == true ? c.title! : '-';
      return '$title$suffix';
    }
    final fullName = c.fullName?.isNotEmpty == true ? c.fullName! : '-';
    return '$fullName$suffix';
  }

  String _currencyTypeLabel(CariCard c) {
    if (c.currencyType != 'foreign') return 'TL';

    final explicitName = (c.foreignName ?? '').trim();
    if (explicitName.isNotEmpty) return explicitName;

    final code = (c.foreignCode ?? '').trim().toUpperCase();
    if (code.isEmpty) return '';

    switch (code) {
      case 'USD':
        return 'Dolar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'Sterlin';
      case 'GA':
        return 'Gram Altın';
      default:
        return code;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
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

  double? _parseQuantity(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return null;
    var normalized = input;
    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll('.', '');
      normalized = normalized.replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      if (source == ImageSource.camera && !isCameraSourceAvailable()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamera bu platformda desteklenmiyor.')),
        );
        return;
      }
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _attachments.add(bytes);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim eklenemedi: $e')),
      );
    }
  }

  Future<void> _showAddAttachmentSheet() async {
    final cameraSupported = isCameraSourceAvailable();
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cameraSupported)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future<void>.delayed(const Duration(milliseconds: 220));
                  if (!mounted) return;
                  await _pickAttachment(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await Future<void>.delayed(const Duration(milliseconds: 220));
                if (!mounted) return;
                await _pickAttachment(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCardId == null || _selectedAccountId == null) return;

    final parsed = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (parsed == null || parsed <= 0) return;
    final isForeign = _isSelectedCardForeign();
    final quantity = _parseQuantity(_quantityController.text);
    if (isForeign && (quantity == null || quantity <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yabancı para için geçerli miktar giriniz.')),
      );
      return;
    }
    final unitPrice = isForeign ? (parsed / quantity!) : null;

    setState(() {
      _saving = true;
    });

    try {
      if (_isEditMode) {
        final tx = widget.initialTransaction!;
        await CariTransactionService.updateTransaction(
          transactionId: tx.id,
          cariCardId: _selectedCardId!,
          accountId: _selectedAccountId!,
          type: _isDebt ? 'debt' : 'collection',
          amount: parsed,
          quantity: isForeign ? quantity : null,
          unitPrice: unitPrice,
          date: _selectedDate,
          description: _noteController.text,
        );
        await TransactionAttachmentService.addMany(
          ownerType: 'cari',
          ownerId: tx.id,
          images: _attachments.map((e) => e.toList()).toList(),
        );
      } else {
        int txId;
        if (_isDebt) {
          txId = await CariTransactionService.addDebtAndGetId(
            cariCardId: _selectedCardId!,
            accountId: _selectedAccountId!,
            amount: parsed,
            quantity: isForeign ? quantity : null,
            unitPrice: unitPrice,
            date: _selectedDate,
            description: _noteController.text,
          );
        } else {
          txId = await CariTransactionService.addCollectionAndGetId(
            cariCardId: _selectedCardId!,
            accountId: _selectedAccountId!,
            amount: parsed,
            quantity: isForeign ? quantity : null,
            unitPrice: unitPrice,
            date: _selectedDate,
            description: _noteController.text,
          );
        }
        await TransactionAttachmentService.addMany(
          ownerType: 'cari',
          ownerId: txId,
          images: _attachments.map((e) => e.toList()).toList(),
        );
      }

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

  Future<void> _deleteCurrent() async {
    if (!_isEditMode || _saving) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu cari işlemi silinsin mi?'),
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
    if (ok != true) return;

    setState(() {
      _saving = true;
    });
    try {
      await CariTransactionService.deleteAndReturn(widget.initialTransaction!.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme hatası: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: _isEditMode
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => popToDashboard(context),
              ),
        title: Text(_isEditMode ? 'Cari İşlem Düzenle' : 'Cari Hesap'),
        actions: [buildHomeAction(context)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_cards.isEmpty || _accounts.isEmpty)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Cari işlem için en az bir aktif cari kart ve aktif hesap olmalı.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(value: true, label: Text('Giden')),
                          ButtonSegment<bool>(value: false, label: Text('Gelen')),
                        ],
                        selected: {_isDebt},
                        onSelectionChanged: (set) {
                          setState(() {
                            _isDebt = set.first;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCardId,
                        decoration: const InputDecoration(
                          labelText: 'Cari Kart',
                          border: OutlineInputBorder(),
                        ),
                        items: _cards
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(_cardLabel(c)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedCardId = v;
                        }),
                        validator: (v) => v == null ? 'Cari kart seçiniz.' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Hesap',
                          border: OutlineInputBorder(),
                        ),
                        items: _accounts
                            .map(
                              (a) => DropdownMenuItem<int>(
                                value: a.id,
                                child: Text(a.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedAccountId = v),
                        validator: (v) => v == null ? 'Hesap seçiniz.' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: const [TurkishMoneyInputFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Tutar (TL)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final n = TurkishMoneyInputFormatter.parse(v ?? '');
                          if (n == null || n <= 0) return 'Geçerli bir tutar giriniz.';
                          return null;
                        },
                      ),
                      if (_isSelectedCardForeign()) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: _foreignUnitLabel(),
                            filled: true,
                            fillColor: Colors.orange.withValues(alpha: 0.14),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (!_isSelectedCardForeign()) return null;
                            final q = _parseQuantity(v ?? '');
                            if (q == null || q <= 0) {
                              return 'Geçerli bir miktar giriniz.';
                            }
                            return null;
                          },
                        ),
                      ],
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [TurkishUpperCaseFormatter()],
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama (opsiyonel)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Resim Eki (opsiyonel)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _showAddAttachmentSheet,
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            label: const Text('Resim Ekle'),
                          ),
                        ],
                      ),
                      if (_existingAttachments.isNotEmpty || _attachments.isNotEmpty)
                        SizedBox(
                          height: 78,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _existingAttachments.length + _attachments.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final isExisting = index < _existingAttachments.length;
                              final bytes = isExisting
                                  ? _existingAttachments[index]
                                  : _attachments[index - _existingAttachments.length];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      bytes,
                                      width: 78,
                                      height: 78,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (!isExisting)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _attachments
                                                .removeAt(index - _existingAttachments.length);
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(
                          _saving
                              ? 'Kaydediliyor...'
                              : (_isEditMode ? 'Güncelle' : 'Kaydet'),
                        ),
                      ),
                      if (_isEditMode) ...[
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _saving ? null : _deleteCurrent,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Sil'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
