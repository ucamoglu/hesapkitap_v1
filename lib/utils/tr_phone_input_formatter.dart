import 'package:flutter/services.dart';

class TrPhoneInputFormatter extends TextInputFormatter {
  const TrPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    final formatted = _format(limited);

    return TextEditingValue(
      text: formatted,
      // Keep caret at end to avoid digit reordering while applying mask.
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String formatDigits(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    return _format(limited);
  }

  static String _format(String digits) {
    if (digits.isEmpty) return '';

    final b = StringBuffer();

    if (digits.length <= 3) {
      b.write('(');
      b.write(digits);
      return b.toString();
    }

    b.write('(');
    b.write(digits.substring(0, 3));
    b.write(')');

    if (digits.length <= 6) {
      b.write(digits.substring(3));
      return b.toString();
    }

    b.write(digits.substring(3, 6));

    if (digits.length <= 8) {
      b.write(' ');
      b.write(digits.substring(6));
      return b.toString();
    }

    b.write(' ');
    b.write(digits.substring(6, 8));
    b.write(' ');
    b.write(digits.substring(8));

    return b.toString();
  }
}
