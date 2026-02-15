import 'package:flutter/services.dart';

class TurkishMoneyInputFormatter extends TextInputFormatter {
  const TurkishMoneyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.trim();
    if (raw.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final cleaned = raw.replaceAll(RegExp(r'[^0-9,]'), '');
    final firstComma = cleaned.indexOf(',');

    String intPartRaw;
    String decPartRaw = '';
    bool hasComma = false;

    if (firstComma >= 0) {
      hasComma = true;
      intPartRaw = cleaned.substring(0, firstComma);
      decPartRaw =
          cleaned.substring(firstComma + 1).replaceAll(',', '').replaceAll(RegExp(r'[^0-9]'), '');
    } else {
      intPartRaw = cleaned;
    }

    final digits = intPartRaw.replaceAll(RegExp(r'[^0-9]'), '');
    final liraDigits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final normalized = liraDigits.isEmpty ? '0' : liraDigits;
    final formattedInt = _formatThousands(normalized);

    final dec = decPartRaw.length > 2 ? decPartRaw.substring(0, 2) : decPartRaw;
    final formatted = hasComma ? '$formattedInt,$dec' : formattedInt;

    return TextEditingValue(
      text: formatted,
      // Keep caret at the end to avoid digit reordering while separators are inserted.
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static double? parse(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final normalized = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  static String _formatThousands(String intPart) {
    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) {
        b.write('.');
      }
    }
    return b.toString();
  }
}
