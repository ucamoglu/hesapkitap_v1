import 'package:flutter/material.dart';

class PlanningStandard {
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
}
