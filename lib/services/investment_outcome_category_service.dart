import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/income_category.dart';

class OutcomeCategoryPair {
  final IncomeCategory income;
  final Category expense;

  const OutcomeCategoryPair({
    required this.income,
    required this.expense,
  });
}

class InvestmentOutcomeCategoryService {
  static const Map<String, String> _symbolNameMap = {
    'USD': 'Dolar',
    'EUR': 'Euro',
    'GBP': 'Sterlin',
    'CHF': 'Isvicre Frangi',
    'AED': 'BAE Dirhemi',
    'HA': 'Has Altin',
    'GA': 'Gram Altin',
    'GAG': 'Gram Gumus',
    'XAU': 'Altin',
    'XAG': 'Gumus',
    'XPT': 'Platin',
    'BTC': 'Bitcoin',
  };

  static String displayNameForSymbol(String symbol) {
    final key = symbol.trim().toUpperCase();
    return _symbolNameMap[key] ?? key;
  }

  static String incomeSystemKey(String symbol) =>
      'investment_pnl_income_${symbol.trim().toUpperCase()}';

  static String expenseSystemKey(String symbol) =>
      'investment_pnl_expense_${symbol.trim().toUpperCase()}';

  static Future<OutcomeCategoryPair> ensurePairForSymbol({
    required Isar isar,
    required String symbol,
  }) async {
    final cleaned = symbol.trim().toUpperCase();
    final display = displayNameForSymbol(cleaned);
    final incomeName = '$display Olumlu Sonuc';
    final expenseName = '$display Olumsuz Sonuc';

    final incomeKey = incomeSystemKey(cleaned);
    final expenseKey = expenseSystemKey(cleaned);

    IncomeCategory? income = await isar.incomeCategorys
        .where()
        .filter()
        .systemKeyEqualTo(incomeKey)
        .findFirst();
    income ??= await isar.incomeCategorys
        .where()
        .filter()
        .nameEqualTo(incomeName)
        .findFirst();

    if (income == null) {
      income = IncomeCategory()
        ..name = incomeName
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = incomeKey
        ..createdAt = DateTime.now();
      await isar.incomeCategorys.put(income);
    } else {
      income
        ..name = incomeName
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = incomeKey;
      await isar.incomeCategorys.put(income);
    }

    Category? expense = await isar.categorys
        .where()
        .filter()
        .typeEqualTo('expense')
        .and()
        .systemKeyEqualTo(expenseKey)
        .findFirst();
    expense ??= await isar.categorys
        .where()
        .filter()
        .typeEqualTo('expense')
        .and()
        .nameEqualTo(expenseName)
        .findFirst();

    if (expense == null) {
      expense = Category()
        ..name = expenseName
        ..type = 'expense'
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = expenseKey
        ..createdAt = DateTime.now();
      await isar.categorys.put(expense);
    } else {
      expense
        ..name = expenseName
        ..type = 'expense'
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = expenseKey;
      await isar.categorys.put(expense);
    }

    return OutcomeCategoryPair(income: income, expense: expense);
  }
}
