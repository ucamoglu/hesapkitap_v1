import 'package:flutter/material.dart';

import '../core/runtime/app_runtime.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../theme/app_theme_helpers.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_upper_case_formatter.dart';

class ExpenseCategoryScreen extends StatefulWidget {
  const ExpenseCategoryScreen({super.key});

  @override
  State<ExpenseCategoryScreen> createState() => _ExpenseCategoryScreenState();
}

class _ExpenseCategoryScreenState extends State<ExpenseCategoryScreen> {
  List<Category> categories = [];

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
        title: const Text("Gider Kategorileri"),
        content: const Text(
          "Bu ekranda gider kayıtlarında kullanacağınız kategori tiplerini tanımlarsınız.\n\n"
          "Örnek: Market, Fatura, Ulaşım, Sağlık.\n\n"
          "Gider girişlerinde doğru kategori seçmek; bütçe takibi, filtre ve raporlamanın doğru çalışmasını sağlar.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  // Gerekirse varsayilan kategorileri olusturup listeyi ilk kez yukler.
  Future<void> init() async {
    await CategoryService.seedExpenseDefaultsIfEmpty();
    await loadCategories();
  }

  // Gider kategori listesini veritabanindan tazeler.
  Future<void> loadCategories() async {
    final data = await CategoryService.getAllExpenseCategories();
    setState(() {
      categories = data;
    });
  }

  void _addCategory() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Gider Kategorisi"),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration: const InputDecoration(labelText: "Kategori Adı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                _showSnack('Kategori adı zorunludur.');
                return;
              }

              try {
                await AppRuntime.dataLayer.expenseCategories.add(name);
                await loadCategories();
                if (!mounted) return;
                Navigator.pop(context);
              } catch (e) {
                _showSnack('Kayıt hatası: $e');
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  // Kategori kaydini silmeden aktif/pasif duruma getirir.
  Future<void> _toggleActive(Category category) async {
    if (category.isSystemGenerated) {
      _showSnack('Sistem kategorisi degistirilemez.');
      return;
    }
    try {
      await AppRuntime.dataLayer.expenseCategories.setActive(
        category.id,
        !category.isActive,
      );
      await loadCategories();
    } catch (e) {
      _showSnack('İşlem hatası: $e');
    }
  }

  void _editCategory(Category category) {
    if (category.isSystemGenerated) {
      _showSnack('Sistem kategorisi duzenlenemez.');
      return;
    }
    final controller = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Gider Kategorisini Düzenle"),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration: const InputDecoration(labelText: "Kategori Adı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                _showSnack('Kategori adı zorunludur.');
                return;
              }

              category.name = name;
              try {
                await AppRuntime.dataLayer.expenseCategories.update(category);
                await loadCategories();
                if (!mounted) return;
                Navigator.pop(context);
              } catch (e) {
                _showSnack('Güncelleme hatası: $e');
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  // Kategoriyi kullanim durumuna gore kontrollu bicimde siler.
  Future<void> _deleteCategory(Category category) async {
    if (category.isSystemGenerated) {
      _showSnack('Sistem kategorisi silinemez.');
      return;
    }
    try {
      final isUsed = await AppRuntime.dataLayer.expenseCategories.isUsed(
        category.id,
      );
      if (isUsed) {
        await AppRuntime.dataLayer.expenseCategories.setActive(category.id, false);
        _showSnack("Bu kategori işlemde kullanılmış. Silinmedi, pasife alındı.");
      } else {
        await AppRuntime.dataLayer.expenseCategories.delete(category.id);
        _showSnack("Kategori silindi.");
      }
      await loadCategories();
    } catch (e) {
      _showSnack('Silme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = Colors.redAccent;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text("Gider Kategorileri"),
        actions: [buildHomeAction(context)],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: context.surfaceDecoration(
              accent: accent,
              fillColor: category.isActive
                  ? context.softAccent(accent, 0.06)
                  : Colors.white,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.softAccent(accent),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.sell, color: accent, size: 20),
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  decoration:
                      category.isActive ? null : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                category.isSystemGenerated
                    ? 'Sistem kategorisi'
                    : (category.isActive ? 'Aktif' : 'Pasif'),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: accent),
                onSelected: (value) async {
                  if (value == "edit") {
                    _editCategory(category);
                  } else if (value == "delete") {
                    await _deleteCategory(category);
                  } else if (value == "toggle") {
                    await _toggleActive(category);
                  }
                },
                itemBuilder: (context) => [
                  if (!category.isSystemGenerated)
                    const PopupMenuItem(
                      value: "edit",
                      child: Text("Düzenle"),
                    ),
                  if (!category.isSystemGenerated)
                    if (category.isActive)
                      const PopupMenuItem(
                        value: "toggle",
                        child: Text("Pasif Yap"),
                      )
                    else
                      const PopupMenuItem(
                        value: "toggle",
                        child: Text("Aktif Yap"),
                      ),
                  if (!category.isSystemGenerated)
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
              heroTag: "expense_category_info_fab",
              tooltip: "Bilgi",
              onPressed: _showInfoDialog,
              child: const Icon(Icons.info_outline),
            ),
          ),
          FloatingActionButton(
            heroTag: "expense_category_add_fab",
            onPressed: _addCategory,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
