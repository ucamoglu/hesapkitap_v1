import 'package:flutter/material.dart';

class PlanningStandard {
  static const recurrencePresetOrder = <String>[
    'once',
    'daily',
    'weekly',
    'monthly',
    'yearly',
    'custom',
  ];

  static const dailyReminderOptions = <int>[
    10,
    30,
    60,
    120,
  ];

  static const periodOrder = <String>[
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

  static String periodLabel(String value) {
    if (value == 'once') return 'Tek Sefer';
    if (value == 'daily') return 'Günlük';
    if (value == 'weekly') return 'Haftalık';
    if (value == 'yearly') return 'Yıllık';
    return 'Aylık';
  }

  static String recurrencePresetLabel(String value) {
    if (value == 'once') return 'Asla';
    if (value == 'daily') return 'Her Gün';
    if (value == 'weekly') return 'Her Hafta';
    if (value == 'monthly') return 'Her Ay';
    if (value == 'yearly') return 'Her Yıl';
    return 'Özel...';
  }

  static List<DropdownMenuItem<String>> recurrencePresetItems() {
    return recurrencePresetOrder
        .map(
          (value) => DropdownMenuItem<String>(
            value: value,
            child: Text(recurrencePresetLabel(value)),
          ),
        )
        .toList();
  }

  static List<DropdownMenuItem<String>> periodItems() {
    return periodOrder
        .map(
          (value) => DropdownMenuItem<String>(
            value: value,
            child: Text(periodLabel(value)),
          ),
        )
        .toList();
  }

  static List<DropdownMenuItem<int>> frequencyItems({int max = 12}) {
    return List.generate(
      max,
      (i) => DropdownMenuItem<int>(
        value: i + 1,
        child: Text('Her ${i + 1}'),
      ),
    );
  }

  static bool usesReminderSelector(String periodType) {
    return periodType == 'daily';
  }

  static bool disablesFrequencySelector(String periodType) {
    return periodType == 'weekly';
  }

  static int maxFrequencyForPeriod(String periodType) {
    if (periodType == 'daily') return 30;
    if (periodType == 'weekly') return 12;
    if (periodType == 'yearly') return 10;
    return 12;
  }

  static String frequencyUnitLabel(String periodType) {
    if (periodType == 'once') return 'Kez';
    if (periodType == 'daily') return 'Gün';
    if (periodType == 'weekly') return 'Hafta';
    if (periodType == 'yearly') return 'Yıl';
    return 'Ay';
  }

  static List<DropdownMenuItem<int>> frequencyItemsForPeriod(
      String periodType) {
    final max = maxFrequencyForPeriod(periodType);
    final unit = frequencyUnitLabel(periodType);
    return List.generate(
      max,
      (i) => DropdownMenuItem<int>(
        value: i + 1,
        child: Text('Her ${i + 1} $unit'),
      ),
    );
  }

  static List<DropdownMenuItem<int>> dailyReminderItems() {
    return dailyReminderOptions
        .map(
          (minutes) => DropdownMenuItem<int>(
            value: minutes,
            child: Text(reminderLabel(minutes)),
          ),
        )
        .toList();
  }

  static String reminderLabel(int minutes) {
    if (minutes == 10) return '10 dk kala';
    if (minutes == 30) return '30 dk kala';
    if (minutes == 60) return '1 saat kala';
    if (minutes == 120) return '2 saat kala';
    if (minutes < 60) return '$minutes dk kala';
    final hours = minutes ~/ 60;
    return '$hours saat kala';
  }

  static String planSummary({
    required String periodType,
    required int frequency,
    required int reminderMinutesBefore,
  }) {
    final period = periodLabel(periodType);
    if (periodType == 'once') {
      return period;
    }
    if (periodType == 'daily') {
      if (reminderMinutesBefore > 0) {
        return '$period • ${reminderLabel(reminderMinutesBefore)}';
      }
      return period;
    }
    if (periodType == 'weekly') {
      return period;
    }
    return '$period / Her $frequency ${frequencyUnitLabel(periodType)}';
  }

  static String recurrencePresetFor({
    required String periodType,
    required int frequency,
  }) {
    if (periodType == 'once') {
      return 'once';
    }
    if (frequency == 1 &&
        (periodType == 'daily' ||
            periodType == 'weekly' ||
            periodType == 'monthly' ||
            periodType == 'yearly')) {
      return periodType;
    }
    return 'custom';
  }

  // Tekrarlayan planlar icin ekranda gosterilecek gelecek tarihleri uretir.
  static List<DateTime> previewDates({
    required DateTime startDate,
    required String periodType,
    required int frequency,
    DateTime? endDate,
    int maxCount = 12,
  }) {
    final dates = <DateTime>[];
    final safeFrequency = frequency < 1 ? 1 : frequency;
    final inclusiveEndDate = endDate == null ? null : _inclusiveDayEnd(endDate);
    var current = startDate;

    while (dates.length < maxCount) {
      if (inclusiveEndDate != null && current.isAfter(inclusiveEndDate)) {
        break;
      }
      dates.add(current);
      if (periodType == 'once') {
        break;
      }
      current = nextOccurrence(
        from: current,
        periodType: periodType,
        frequency: safeFrequency,
      );
    }

    return dates;
  }

  static DateTime nextOccurrence({
    required DateTime from,
    required String periodType,
    required int frequency,
  }) {
    final safeFrequency = frequency < 1 ? 1 : frequency;
    if (periodType == 'once') {
      return from;
    }
    if (periodType == 'daily') {
      return from.add(Duration(days: safeFrequency));
    }
    if (periodType == 'weekly') {
      return from.add(Duration(days: 7 * safeFrequency));
    }
    if (periodType == 'yearly') {
      return _addYearsSafe(from, safeFrequency);
    }
    return _addMonthsSafe(from, safeFrequency);
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

  static DateTime _inclusiveDayEnd(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
      999,
      999,
    );
  }
}
