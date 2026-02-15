

import 'package:flutter/material.dart';
import '../services/income_category_service.dart';
import '../models/income_category.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_upper_case_formatter.dart';

class IncomeCategoryScreen extends StatefulWidget {
  const IncomeCategoryScreen({super.key});

  @override
  State<IncomeCategoryScreen> createState() =>
      _IncomeCategoryScreenState();
}

class _IncomeCategoryScreenState extends State<IncomeCategoryScreen> {
  List<IncomeCategory> categories = [];

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Gelir Kategorileri"),
        content: const Text(
          "Bu ekranda gelir kayıtlarında kullanacağınız kategori tiplerini tanımlarsınız.\n\n"
          "Örnek: Maaş, Kira, Ek Gelir, Prim.\n\n"
          "Gelir girişlerinde doğru kategori seçmek; filtre, rapor ve analiz sonuçlarının doğru olmasını sağlar.",
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
    await IncomeCategoryService.seedDefaultsIfEmpty();
    await loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await IncomeCategoryService.getAll();
    setState(() {
      categories = data;
    });
  }

  void _addCategory() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Gelir Kategorisi"),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration:
              const InputDecoration(labelText: "Kategori Adı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await IncomeCategoryService.add(controller.text);
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

  Future<void> _toggleActive(IncomeCategory category) async {
    if (category.isSystemGenerated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem kategorisi degistirilemez.'),
        ),
      );
      return;
    }
    await IncomeCategoryService.setActive(
        category.id, !category.isActive);
    await loadCategories();
  }

  void _editCategory(IncomeCategory category) {
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
        title: const Text("Gelir Kategorisini Düzenle"),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration:
              const InputDecoration(labelText: "Kategori Adı"),
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
                await IncomeCategoryService.update(category);
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

  Future<void> _deleteCategory(IncomeCategory category) async {
    if (category.isSystemGenerated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem kategorisi silinemez.'),
        ),
      );
      return;
    }
    final isUsed = await IncomeCategoryService.isCategoryUsed(category.id);
    if (isUsed) {
      await IncomeCategoryService.setActive(category.id, false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Bu kategori işlemde kullanılmış. Silinmedi, pasife alındı.",
          ),
        ),
      );
    } else {
      await IncomeCategoryService.delete(category.id);
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
        title: const Text("Gelir Kategorileri"),
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
                decoration: category.isActive
                    ? null
                    : TextDecoration.lineThrough,
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
              heroTag: "income_category_info_fab",
              tooltip: "Bilgi",
              onPressed: _showInfoDialog,
              child: const Icon(Icons.info_outline),
            ),
          ),
          FloatingActionButton(
            heroTag: "income_category_add_fab",
            onPressed: _addCategory,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
