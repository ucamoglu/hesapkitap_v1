import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/expense_plan.dart';
import 'finance_transaction_service.dart';
import 'local_notification_service.dart';

class ExpensePlanService {
  static Future<List<ExpensePlan>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.expensePlans.where().anyId().findAll();
    items.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return items;
  }

  static Future<void> save(ExpensePlan plan) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.expensePlans.put(plan);
    });
    await LocalNotificationService.scheduleOrCancelExpensePlan(plan);
  }

  static Future<void> delete(int id) async {
    await LocalNotificationService.cancelExpensePlan(id);
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.expensePlans.delete(id);
    });
  }

  static Future<List<ExpensePlan>> getDuePlans(DateTime now) async {
    final plans = await getAll();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return plans
        .where((p) => p.isActive)
        .where((p) => !p.nextDueDate.isBefore(dayStart) && !p.nextDueDate.isAfter(dayEnd))
        .where((p) => p.endDate == null || !p.nextDueDate.isAfter(p.endDate!))
        .toList();
  }

  static Future<void> markCompleted(ExpensePlan plan) async {
    await FinanceTransactionService.addExpense(
      accountId: plan.accountId,
      categoryId: plan.expenseCategoryId,
      amount: plan.amount,
      date: plan.nextDueDate,
      description: _buildDescription(plan.description),
      expensePlanId: plan.id,
    );

    final next = _nextByPlan(plan.nextDueDate, plan.periodType, plan.frequency);
    plan.nextDueDate = next;

    if (plan.endDate != null && plan.nextDueDate.isAfter(plan.endDate!)) {
      plan.isActive = false;
    }

    await save(plan);
  }

  static Future<void> postpone(ExpensePlan plan, DateTime newDate) async {
    plan.nextDueDate = DateTime(newDate.year, newDate.month, newDate.day);
    await save(plan);
  }

  static Future<void> cancel(ExpensePlan plan) async {
    plan.isActive = false;
    await save(plan);
  }

  static String _buildDescription(String? description) {
    final trimmed = description?.trim() ?? '';
    if (trimmed.isEmpty) return 'GIDER PLANLAMASI';
    return 'PLAN: $trimmed';
  }

  static DateTime _nextByPlan(DateTime from, String periodType, int frequency) {
    final f = frequency < 1 ? 1 : frequency;
    if (periodType == 'daily') {
      return DateTime(from.year, from.month, from.day + f);
    }
    if (periodType == 'weekly') {
      return DateTime(from.year, from.month, from.day + (7 * f));
    }
    if (periodType == 'yearly') {
      return _addYearsSafe(from, f);
    }
    return _addMonthsSafe(from, f);
  }

  static DateTime _addMonthsSafe(DateTime date, int monthsToAdd) {
    final totalMonths = date.month + monthsToAdd;
    final targetYear = date.year + ((totalMonths - 1) ~/ 12);
    final targetMonth = ((totalMonths - 1) % 12) + 1;
    final maxDay = _daysInMonth(targetYear, targetMonth);
    final targetDay = date.day <= maxDay ? date.day : maxDay;
    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static DateTime _addYearsSafe(DateTime date, int yearsToAdd) {
    final targetYear = date.year + yearsToAdd;
    final maxDay = _daysInMonth(targetYear, date.month);
    final targetDay = date.day <= maxDay ? date.day : maxDay;
    return DateTime(
      targetYear,
      date.month,
      targetDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static int _daysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }
}
