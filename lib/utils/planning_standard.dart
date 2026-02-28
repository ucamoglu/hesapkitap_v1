import 'package:flutter/material.dart';

class PlanningStandard {
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
    if (value == 'daily') return 'Günlük';
    if (value == 'weekly') return 'Haftalık';
    if (value == 'yearly') return 'Yıllık';
    return 'Aylık';
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
}
