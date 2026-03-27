import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/cari_card.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/tracked_crypto_service.dart';
import '../services/tracked_currency_service.dart';
import '../services/tracked_metal_service.dart';
import '../services/tracked_stock_service.dart';
import '../theme/app_theme_helpers.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_upper_case_formatter.dart';

class CariCardsScreen extends StatefulWidget {
  const CariCardsScreen({super.key});

  @override
  State<CariCardsScreen> createState() => _CariCardsScreenState();
}

class _CariCardsScreenState extends State<CariCardsScreen> {
  List<CariCard> cards = [];

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cari Kartlar'),
        content: const Text(
          "Bu ekranda kişi ve firma bazlı cari kart tanımlamaları yapılır.\n\n"
          "Cari kartlar, borç/alacak süreçlerinin düzenli ve izlenebilir şekilde yönetilebilmesi amacıyla kullanılır.\n\n"
          "Örneğin bir kişiye borç verildiğinde, İşlem ekranında 'Giden' türünde kayıt oluşturularak ilgili cari hareket sisteme işlenir.\n\n"
          "Bu sayede borç/alacak durumu cari kart bazında güvenli ve sürdürülebilir biçimde takip edilebilir.",
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
  void initState() {
    super.initState();
    loadCards();
  }

  // Cari kart listesini ekrana tekrar yukler.
  Future<void> loadCards() async {
    final data = await CariCardService.getAll();
    setState(() {
      cards = data;
    });
  }

  IconData _icon(String type) {
    return type == 'company' ? Icons.apartment : Icons.person;
  }

  Future<Uint8List?> _pickImageBytes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.bytes;
  }

  String _label(CariCard card) {
    if (card.type == 'company') {
      return card.title?.trim().isNotEmpty == true ? card.title! : '-';
    }
    return card.fullName?.trim().isNotEmpty == true ? card.fullName! : '-';
  }

  String _currencySummary(CariCard c) {
    if (c.currencyType != 'foreign') return 'TL';
    final market = switch ((c.foreignMarketType ?? '').trim()) {
      'currency' => 'Döviz',
      'metal' => 'Kıymetli Maden',
      'crypto' => 'Kripto',
      'stock' => 'Borsa',
      _ => 'Yabancı Para',
    };
    final symbol = (c.foreignCode ?? '').trim();
    return symbol.isEmpty ? market : '$market • $symbol';
  }

  String _fmtAmount(double value) => value.toStringAsFixed(2);

  String _fmtDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}.${two(value.month)}.${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  Future<void> _openMovements(CariCard card) async {
    final transactions = (await CariTransactionService.getAll())
        .where((tx) => tx.cariCardId == card.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final accounts = await AccountService.getAllAccounts();
    final accountNames = {for (final account in accounts) account.id: account.name};
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.72,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    _label(card),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${transactions.length} hareket'),
                ),
                const Divider(height: 1),
                Expanded(
                  child: transactions.isEmpty
                      ? const Center(
                          child: Text('Bu cari kart için hareket bulunamadı.'),
                        )
                      : ListView.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final tx = transactions[i];
                            final isCollection = tx.type == 'collection';
                            final accountName =
                                accountNames[tx.accountId] ?? 'Hesap #${tx.accountId}';

                            return ListTile(
                              leading: Icon(
                                isCollection ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isCollection ? Colors.green : Colors.red,
                              ),
                              title: Text(isCollection ? 'Gelen' : 'Giden'),
                              subtitle: Text(
                                '${_fmtDateTime(tx.date)} • $accountName\n'
                                'Açıklama: ${(tx.description ?? '').trim().isEmpty ? '-' : tx.description!.trim()}',
                              ),
                              isThreeLine: true,
                              trailing: Text(
                                '${isCollection ? '+' : '-'}${_fmtAmount(tx.amount)} TL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCollection ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ekleme ve duzenleme akislarini ayni dialog uzerinden yurutur.
  Future<void> _openDialog({CariCard? edit}) async {
    String selectedType = edit?.type ?? 'person';
    String selectedCurrencyType = edit?.currencyType ?? 'tl';
    String selectedForeignMarketType = edit?.foreignMarketType ?? 'currency';
    String? selectedForeignCode = edit?.foreignCode;
    String? selectedForeignName = edit?.foreignName;

    final trackedCurrencies = await TrackedCurrencyService.getAll();
    final trackedMetals = await TrackedMetalService.getAll();
    final trackedStocks = await TrackedStockService.getAll();
    final trackedCryptos = await TrackedCryptoService.getAll();
    if (!mounted) return;

    final optionsByMarket = <String, List<(String, String)>>{
      'currency': trackedCurrencies
          .where((e) => e.isActive)
          .map((e) => (e.code.toUpperCase(), e.name))
          .toList()
        ..sort((a, b) => a.$2.compareTo(b.$2)),
      'metal': trackedMetals
          .where((e) => e.isActive)
          .map((e) => (e.code.toUpperCase(), e.name))
          .toList()
        ..sort((a, b) => a.$2.compareTo(b.$2)),
      'stock': trackedStocks
          .where((e) => e.isActive)
          .map((e) => (e.code.toUpperCase(), e.name))
          .toList()
        ..sort((a, b) => a.$1.compareTo(b.$1)),
      'crypto': trackedCryptos
          .where((e) => e.isActive)
          .map((e) => (e.code.toUpperCase(), e.name))
          .toList()
        ..sort((a, b) => a.$1.compareTo(b.$1)),
    };

    List<(String, String)> currentOptions() =>
        optionsByMarket[selectedForeignMarketType] ?? const [];

    if (selectedCurrencyType == 'foreign') {
      final opts = currentOptions();
      if (opts.isEmpty) {
        selectedForeignCode = null;
        selectedForeignName = null;
      } else if (!opts.any((e) => e.$1 == selectedForeignCode)) {
        selectedForeignCode = opts.first.$1;
        selectedForeignName = opts.first.$2;
      }
    }

    final fullNameController = TextEditingController(text: edit?.fullName ?? '');
    final titleController = TextEditingController(text: edit?.title ?? '');
    final phoneController = TextEditingController(text: edit?.phone ?? '');
    final emailController = TextEditingController(text: edit?.email ?? '');
    final noteController = TextEditingController(text: edit?.note ?? '');
    Uint8List? selectedPhoto =
        edit?.photoBytes == null ? null : Uint8List.fromList(edit!.photoBytes!);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(edit == null ? 'Yeni Cari Kart' : 'Cari Kart Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          selectedPhoto != null ? MemoryImage(selectedPhoto!) : null,
                      child: selectedPhoto == null
                          ? const Icon(Icons.person, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final bytes = await _pickImageBytes();
                            if (bytes == null) return;
                            setInnerState(() {
                              selectedPhoto = bytes;
                            });
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Resim Seç'),
                        ),
                        if (selectedPhoto != null)
                          TextButton(
                            onPressed: () {
                              setInnerState(() {
                                selectedPhoto = null;
                              });
                            },
                            child: const Text('Resmi Kaldır'),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Kart Türü'),
                  items: const [
                    DropdownMenuItem(value: 'person', child: Text('Kişi')),
                    DropdownMenuItem(value: 'company', child: Text('Firma')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setInnerState(() {
                      selectedType = v;
                    });
                  },
                ),
                const SizedBox(height: 8),
                if (selectedType == 'person')
                  TextField(
                    controller: fullNameController,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: const [TurkishUpperCaseFormatter()],
                    decoration: const InputDecoration(labelText: 'İsim Soyisim'),
                  )
                else
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: const [TurkishUpperCaseFormatter()],
                    decoration: const InputDecoration(labelText: 'Ünvan'),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Not'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCurrencyType,
                  decoration: const InputDecoration(labelText: 'Para Birimi'),
                  items: const [
                    DropdownMenuItem(value: 'tl', child: Text('TL')),
                    DropdownMenuItem(value: 'foreign', child: Text('Yabancı Para')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setInnerState(() {
                      selectedCurrencyType = v;
                      if (v == 'tl') {
                        selectedForeignCode = null;
                        selectedForeignName = null;
                        return;
                      }
                      final opts = currentOptions();
                      if (opts.isEmpty) {
                        selectedForeignCode = null;
                        selectedForeignName = null;
                      } else if (!opts.any((e) => e.$1 == selectedForeignCode)) {
                        selectedForeignCode = opts.first.$1;
                        selectedForeignName = opts.first.$2;
                      }
                    });
                  },
                ),
                if (selectedCurrencyType == 'foreign') ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedForeignMarketType,
                    decoration: const InputDecoration(labelText: 'Yabancı Para Türü'),
                    items: const [
                      DropdownMenuItem(value: 'currency', child: Text('Döviz')),
                      DropdownMenuItem(value: 'metal', child: Text('Kıymetli Maden')),
                      DropdownMenuItem(value: 'crypto', child: Text('Kripto Para')),
                      DropdownMenuItem(value: 'stock', child: Text('Borsa')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setInnerState(() {
                        selectedForeignMarketType = v;
                        final opts = currentOptions();
                        if (opts.isEmpty) {
                          selectedForeignCode = null;
                          selectedForeignName = null;
                        } else {
                          selectedForeignCode = opts.first.$1;
                          selectedForeignName = opts.first.$2;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (_) {
                      final opts = currentOptions();
                      if (opts.isEmpty) {
                        return const InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Takip Edilen Enstrüman',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            'Bu türde aktif takip bulunamadı.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }
                      if (!opts.any((e) => e.$1 == selectedForeignCode)) {
                        selectedForeignCode = opts.first.$1;
                        selectedForeignName = opts.first.$2;
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: selectedForeignCode,
                        decoration: const InputDecoration(
                          labelText: 'Takip Edilen Enstrüman',
                        ),
                        items: opts
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.$1,
                                child: Text('${e.$1} - ${e.$2}'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setInnerState(() {
                            selectedForeignCode = v;
                            String? found;
                            for (final e in opts) {
                              if (e.$1 == v) {
                                found = e.$2;
                                break;
                              }
                            }
                            selectedForeignName = found;
                          });
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final fullName = fullNameController.text.trim();
                final title = titleController.text.trim();
                if (selectedType == 'person' && fullName.isEmpty) {
                  _showSnack('Kişi kartında isim soyisim zorunludur.');
                  return;
                }
                if (selectedType == 'company' && title.isEmpty) {
                  _showSnack('Firma kartında ünvan zorunludur.');
                  return;
                }
                if (selectedCurrencyType == 'foreign') {
                  final opts = currentOptions();
                  if (opts.isEmpty) {
                    _showSnack('Bu türde aktif takip bulunmadığı için kayıt yapılamaz.');
                    return;
                  }
                  if (selectedForeignCode == null) {
                    _showSnack('Takip edilen enstrümanı seçiniz.');
                    return;
                  }
                }

                final card = edit ?? CariCard()..createdAt = DateTime.now();
                card.type = selectedType;
                card.fullName = fullName.isEmpty ? null : fullName;
                card.title = title.isEmpty ? null : title;
                card.phone = phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim();
                card.email = emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim();
                card.note = noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim();
                card.photoBytes = selectedPhoto?.toList();
                card.currencyType = selectedCurrencyType;
                if (selectedCurrencyType == 'foreign') {
                  card.foreignMarketType = selectedForeignMarketType;
                  card.foreignCode = selectedForeignCode;
                  card.foreignName = selectedForeignName;
                } else {
                  card.foreignMarketType = null;
                  card.foreignCode = null;
                  card.foreignName = null;
                }

                try {
                  if (edit == null) {
                    await CariCardService.add(card);
                  } else {
                    await CariCardService.update(card);
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await loadCards();
                } catch (e) {
                  _showSnack('Kayıt hatası: $e');
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  // Karti silmeden aktif/pasif hale getirir.
  Future<void> _toggle(CariCard card) async {
    await CariCardService.setActive(card.id, !card.isActive);
    await loadCards();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const accent = Colors.orange;
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Cari Kartlar'),
        actions: [buildHomeAction(context)],
      ),
      body: cards.isEmpty
          ? Center(
              child: Text(
                'Cari kart bulunamadı.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final c = cards[index];
                return Dismissible(
                  key: ValueKey('cari-card-${c.id}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _openMovements(c);
                    return false;
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.chevron_left),
                        SizedBox(width: 8),
                        Text('Hareketleri Aç'),
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: context.surfaceDecoration(
                      accent: accent,
                      fillColor: c.isActive
                          ? context.softAccent(accent, 0.06)
                          : Colors.white,
                    ),
                    child: ListTile(
                      onTap: () => _openMovements(c),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: context.softAccent(accent),
                        backgroundImage:
                            c.photoBytes != null ? MemoryImage(Uint8List.fromList(c.photoBytes!)) : null,
                        child: c.photoBytes == null ? Icon(_icon(c.type), color: accent) : null,
                      ),
                      title: Text(
                        _label(c),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: c.isActive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(
                        '${c.type == 'company' ? 'Firma' : 'Kişi'} • ${_currencySummary(c)}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: accent),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _openDialog(edit: c);
                          } else if (value == 'toggle') {
                            await _toggle(c);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Düzenle'),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(c.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                          ),
                        ],
                      ),
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
              heroTag: 'cari_cards_info_fab',
              tooltip: 'Bilgi',
              onPressed: _showInfoDialog,
              child: const Icon(Icons.info_outline),
            ),
          ),
          FloatingActionButton(
            heroTag: 'cari_cards_add_fab',
            onPressed: () => _openDialog(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
