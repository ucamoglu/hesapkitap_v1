import 'dart:math' as math;

import 'package:flutter/services.dart';

class TurkishUpperCaseFormatter extends TextInputFormatter {
  const TurkishUpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = _toTurkishUpper(newValue.text);
    final baseOffset = newValue.selection.baseOffset;
    final safeOffset = baseOffset < 0
        ? upper.length
        : math.max(0, math.min(baseOffset, upper.length));

    return newValue.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: safeOffset),
      composing: TextRange.empty,
    );
  }

  String _toTurkishUpper(String input) {
    return input
        .replaceAll('i', 'İ')
        .replaceAll('ı', 'I')
        .toUpperCase();
  }
}
