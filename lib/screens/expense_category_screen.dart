import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_upper_case_formatter.dart';

class ExpenseCategoryScreen extends StatefulWidget {
  const ExpenseCategoryScreen({super.key});

  @override
  State<ExpenseCategoryScreen> createState() => _ExpenseCategoryScreenState();
}

class _ExpenseCategoryScreenState extends State<ExpenseCategoryScreen> {
  List<Category> categories = [];

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

  Future<void> init() async {
    await CategoryService.seedExpenseDefaultsIfEmpty();
    await loadCategories();
  }

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
              if (controller.text.isNotEmpty) {
                await CategoryService.addExpenseCategory(controller.text);
                await loadCategories();
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(Category category) async {
    if (category.isSystemGenerated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem kategorisi degistirilemez.'),
        ),
      );
      return;
    }
    await CategoryService.setActive(category.id, !category.isActive);
    await loadCategories();
  }

  void _editCategory(Category category) {
    if (category.isSystemGenerated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem kategorisi duzenlenemez.'),
        ),
      );
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
              if (controller.text.isNotEmpty) {
                category.name = controller.text;
                await CategoryService.updateExpenseCategory(category);
                await loadCategories();
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    if (category.isSystemGenerated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem kategorisi silinemez.'),
        ),
      );
      return;
    }
    final isUsed = await CategoryService.isExpenseCategoryUsed(category.id);
    if (isUsed) {
      await CategoryService.setActive(category.id, false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Bu kategori işlemde kullanılmış. Silinmedi, pasife alındı.",
          ),
        ),
      );
    } else {
      await CategoryService.deleteExpenseCategory(category.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kategori silindi."),
        ),
      );
    }
    await loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text("Gider Kategorileri"),
        actions: [buildHomeAction(context)],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return ListTile(
            title: Text(
              category.name,
              style: TextStyle(
                decoration:
                    category.isActive ? null : TextDecoration.lineThrough,
              ),
            ),
            trailing: PopupMenuButton<String>(
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
