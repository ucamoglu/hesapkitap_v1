import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/account.dart';
import '../models/cari_card.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/transaction_attachment_service.dart';
import '../utils/camera_support.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class CariAccountScreen extends StatefulWidget {
  const CariAccountScreen({super.key});

  @override
  State<CariAccountScreen> createState() => _CariAccountScreenState();
}

class _CariAccountScreenState extends State<CariAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cards = await CariCardService.getAll();
    final accounts = await AccountService.getActiveAccounts();

    if (!mounted) return;
    setState(() {
      _cards = cards.where((e) => e.isActive).toList();
      _accounts = accounts;
      _selectedCardId = _cards.isNotEmpty ? _cards.first.id : null;
      _selectedAccountId = _accounts.isNotEmpty ? _accounts.first.id : null;
      _loading = false;
    });
  }

  String _cardLabel(CariCard c) {
    if (c.type == 'company') {
      return c.title?.isNotEmpty == true ? c.title! : '-';
    }
    return c.fullName?.isNotEmpty == true ? c.fullName! : '-';
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

    setState(() {
      _saving = true;
    });

    try {
      int txId;
      if (_isDebt) {
        txId = await CariTransactionService.addDebtAndGetId(
          cariCardId: _selectedCardId!,
          accountId: _selectedAccountId!,
          amount: parsed,
          date: _selectedDate,
          description: _noteController.text,
        );
      } else {
        txId = await CariTransactionService.addCollectionAndGetId(
          cariCardId: _selectedCardId!,
          accountId: _selectedAccountId!,
          amount: parsed,
          date: _selectedDate,
          description: _noteController.text,
        );
      }
      await TransactionAttachmentService.addMany(
        ownerType: 'cari',
        ownerId: txId,
        images: _attachments.map((e) => e.toList()).toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Cari Hesap'),
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
                        onChanged: (v) => setState(() => _selectedCardId = v),
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
                      if (_attachments.isNotEmpty)
                        SizedBox(
                          height: 78,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _attachments.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final bytes = _attachments[index];
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
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _attachments.removeAt(index);
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
                        child: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
