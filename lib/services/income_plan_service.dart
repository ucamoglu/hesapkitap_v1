import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/income_plan.dart';
import 'finance_transaction_service.dart';
import 'local_notification_service.dart';

class IncomePlanCompletionResult {
  final int transactionId;
  final DateTime previousDueDate;
  final bool previousIsActive;

  const IncomePlanCompletionResult({
    required this.transactionId,
    required this.previousDueDate,
    required this.previousIsActive,
  });
}

class IncomePlanService {
  /// Gelir planlarini bir sonraki vade tarihine gore siralar.
  static Future<List<IncomePlan>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.incomePlans.where().anyId().findAll();
    items.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return items;
  }

  /// Gelir planini kaydeder ve ona ait bildirimi gunceller.
  static Future<void> save(IncomePlan plan) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.incomePlans.put(plan);
    });
    await LocalNotificationService.scheduleOrCancelIncomePlan(plan);
  }

  /// Gelir planini siler ve bildirimi iptal eder.
  static Future<void> delete(int id) async {
    await LocalNotificationService.cancelIncomePlan(id);
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.incomePlans.delete(id);
    });
  }

  /// Bugun gerceklesmesi beklenen gelir planlarini dondurur.
  static Future<List<IncomePlan>> getDuePlans(DateTime now) async {
    final plans = await getAll();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return plans
        .where((p) => p.isActive)
        .where((p) =>
            !p.nextDueDate.isBefore(dayStart) && !p.nextDueDate.isAfter(dayEnd))
        .where((p) => p.endDate == null || !p.nextDueDate.isAfter(p.endDate!))
        .toList();
  }

  /// Gelir planini gercek harekete cevirir ve sonraki vade tarihini ilerletir.
  static Future<IncomePlanCompletionResult> markCompleted(
      IncomePlan plan) async {
    final previousDueDate = plan.nextDueDate;
    final previousIsActive = plan.isActive;

    final transactionId = await FinanceTransactionService.addIncomeAndGetId(
      accountId: plan.accountId,
      categoryId: plan.incomeCategoryId,
      amount: plan.amount,
      date: plan.nextDueDate,
      description: _buildDescription(plan.description),
      incomePlanId: plan.id,
    );

    final next = _nextByPlan(plan.nextDueDate, plan.periodType, plan.frequency);
    plan.nextDueDate = next;

    if (plan.endDate != null && plan.nextDueDate.isAfter(plan.endDate!)) {
      plan.isActive = false;
    }

    await save(plan);

    return IncomePlanCompletionResult(
      transactionId: transactionId,
      previousDueDate: previousDueDate,
      previousIsActive: previousIsActive,
    );
  }

  /// Tamamlanan plan hareketini geri alip plani onceki aktif haline dondurur.
  static Future<void> undoCompleted(
    IncomePlan plan,
    IncomePlanCompletionResult result,
  ) async {
    await FinanceTransactionService.deleteIncomeAndRevertBalance(
        result.transactionId);
    plan.nextDueDate = result.previousDueDate;
    plan.isActive = result.previousIsActive;
    await save(plan);
  }

  /// Silinen gelir hareketinden plani tekrar aktiflestirmek icin kullanilir.
  static Future<void> restorePlanFromDeletedIncome({
    required int incomePlanId,
    required DateTime originalDate,
  }) async {
    final isar = IsarService.isar;
    final plan = await isar.incomePlans.get(incomePlanId);
    if (plan == null) return;

    plan
      ..nextDueDate = originalDate
      ..isActive = true;

    await save(plan);
  }

  /// Sonraki vade tarihini kullanicinin sectigi yeni gune tasir.
  static Future<void> postpone(IncomePlan plan, DateTime newDate) async {
    plan.nextDueDate = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      plan.nextDueDate.hour,
      plan.nextDueDate.minute,
      plan.nextDueDate.second,
      plan.nextDueDate.millisecond,
      plan.nextDueDate.microsecond,
    );
    await save(plan);
  }

  /// Gelir planini silmeden pasife alir.
  static Future<void> cancel(IncomePlan plan) async {
    plan.isActive = false;
    await save(plan);
  }

  /// Plan kaynakli gelir kayitlarini raporlarda ayirt etmek icin standart etiket uretir.
  static String _buildDescription(String? description) {
    final trimmed = description?.trim() ?? '';
    if (trimmed.isEmpty) return 'GELIR PLANLAMASI';
    return 'PLAN: $trimmed';
  }

  /// Tekrar tipine gore bir sonraki plan tarihini hesaplar.
  static DateTime _nextByPlan(DateTime from, String periodType, int frequency) {
    final f = frequency < 1 ? 1 : frequency;
    if (periodType == 'daily') {
      return from.add(Duration(days: f));
    }
    if (periodType == 'weekly') {
      return from.add(Duration(days: 7 * f));
    }
    if (periodType == 'yearly') {
      return _addYearsSafe(from, f);
    }
    return _addMonthsSafe(from, f);
  }

  /// Aylik tekrarlar icin gecersiz gunleri duzeltir.
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

  /// Yillik tekrarlar icin tarih tasmasini onler.
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
