import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/income_category.dart';

class CreditCardAdjustmentCategoryPair {
  final IncomeCategory income;
  final Category expense;

  const CreditCardAdjustmentCategoryPair({
    required this.income,
    required this.expense,
  });
}

class CreditCardAdjustmentCategoryService {
  static const String incomeSystemKey =
      'credit_card_statement_adjustment_income';
  static const String expenseSystemKey =
      'credit_card_statement_adjustment_expense';

  static Future<CreditCardAdjustmentCategoryPair> ensurePair({
    required Isar isar,
  }) async {
    const incomeName = 'Ekstre Farkı Geliri';
    const expenseName = 'Ekstre Farkı Gideri';

    IncomeCategory? income = await isar.incomeCategorys
        .where()
        .filter()
        .systemKeyEqualTo(incomeSystemKey)
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
        ..systemKey = incomeSystemKey
        ..createdAt = DateTime.now();
      await isar.incomeCategorys.put(income);
    } else {
      income
        ..name = incomeName
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = incomeSystemKey;
      await isar.incomeCategorys.put(income);
    }

    Category? expense = await isar.categorys
        .where()
        .filter()
        .typeEqualTo('expense')
        .and()
        .systemKeyEqualTo(expenseSystemKey)
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
        ..systemKey = expenseSystemKey
        ..createdAt = DateTime.now();
      await isar.categorys.put(expense);
    } else {
      expense
        ..name = expenseName
        ..type = 'expense'
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = expenseSystemKey;
      await isar.categorys.put(expense);
    }

    return CreditCardAdjustmentCategoryPair(
      income: income,
      expense: expense,
    );
  }
}
