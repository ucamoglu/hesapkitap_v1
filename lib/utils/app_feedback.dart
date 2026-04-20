import 'package:flutter/material.dart';

import '../core/runtime/app_messenger.dart';

class AppFeedback {
  static void saved() => _show('Kayit yapildi.');
  static void updated() => _show('Guncelleme yapildi.');
  static void deleted() => _show('Silme islemi basarili.');

  static void _show(String message) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
