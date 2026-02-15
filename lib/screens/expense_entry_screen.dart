import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/transaction_attachment_service.dart';
import '../theme/app_colors.dart';
import '../utils/camera_support.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({
    super.key,
    this.initialTransaction,
  });

  final FinanceTransaction? initialTransaction;

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<Account> _accounts = [];
  List<Category> _categories = [];

  int? _selectedAccountId;
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isLoading = true;
  final List<Uint8List> _attachments = [];
  final List<Uint8List> _existingAttachments = [];

  bool get _isEditMode => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await CategoryService.seedExpenseDefaultsIfEmpty();

    final accounts = (await AccountService.getActiveAccounts())
        .where((a) => a.type != 'investment')
        .toList();
    final categories = await CategoryService.getActiveManualExpenseCategories();

    if (!mounted) return;

    if (_isEditMode) {
      final tx = widget.initialTransaction!;
      final existing = await TransactionAttachmentService.getByOwner(
        ownerType: 'finance',
        ownerId: tx.id,
      );
      _existingAttachments
        ..clear()
        ..addAll(existing.map((e) => Uint8List.fromList(e.imageBytes)));
    }

    setState(() {
      _accounts = accounts;
      _categories = categories;
      if (_isEditMode) {
        final tx = widget.initialTransaction!;
        _selectedAccountId = accounts.any((a) => a.id == tx.accountId)
            ? tx.accountId
            : (accounts.isNotEmpty ? accounts.first.id : null);
        _selectedCategoryId = tx.categoryId;
        _selectedDate = tx.date;
        _amountController.text = _fmtAmount(tx.amount);
        _descriptionController.text = tx.description ?? '';
      } else {
        _selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
        _selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
      }
      _isLoading = false;
    });
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

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedCategoryId == null) return;

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geçerli bir tutar giriniz.")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditMode) {
        final tx = widget.initialTransaction!;
        await FinanceTransactionService.updateTransaction(
          transactionId: tx.id,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          type: 'expense',
          amount: amount,
          date: _selectedDate,
          description: _descriptionController.text,
          incomePlanId: null,
          expensePlanId: tx.expensePlanId,
        );
        await TransactionAttachmentService.addMany(
          ownerType: 'finance',
          ownerId: tx.id,
          images: _attachments.map((e) => e.toList()).toList(),
        );
      } else {
        final txId = await FinanceTransactionService.addExpenseAndGetId(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          amount: amount,
          date: _selectedDate,
          description: _descriptionController.text,
        );
        await TransactionAttachmentService.addMany(
          ownerType: 'finance',
          ownerId: txId,
          images: _attachments.map((e) => e.toList()).toList(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gider kaydedilemedi.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteCurrent() async {
    if (!_isEditMode || _isSaving) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu gider işlemi silinsin mi?'),
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
      _isSaving = true;
    });
    try {
      await FinanceTransactionService.deleteAndReturn(widget.initialTransaction!.id);
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
          _isSaving = false;
        });
      }
    }
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

  String _fmtDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return "$day.$month.${d.year}";
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
        title: Text(_isEditMode ? "Gider Düzenle" : "Gider Girişi"),
        actions: [buildHomeAction(context)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_accounts.isEmpty || _categories.isEmpty)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Gider girişi için en az bir hesap ve aktif gider kategorisi olmalı.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: "Hesap",
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
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Hesap seçiniz." : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: "Gider Kategorisi",
                          border: OutlineInputBorder(),
                        ),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Gider kategorisi seçiniz." : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: const [TurkishMoneyInputFormatter()],
                        decoration: const InputDecoration(
                          labelText: "Tutar (TL)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final parsed = TurkishMoneyInputFormatter.parse(value ?? "");
                          if (parsed == null || parsed <= 0) {
                            return "Geçerli bir tutar giriniz.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Tarih",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_fmtDate(_selectedDate)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [TurkishUpperCaseFormatter()],
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Açıklama (opsiyonel)",
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.expense,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isSaving ? null : _save,
                        child: Text(
                          _isSaving
                              ? "Kaydediliyor..."
                              : (_isEditMode ? "Güncelle" : "Kaydet"),
                        ),
                      ),
                      if (_isEditMode) ...[
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _isSaving ? null : _deleteCurrent,
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
