import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

bool isCameraSourceAvailable() {
  if (kIsWeb) return true;

  if (defaultTargetPlatform == TargetPlatform.android) {
    return true;
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // iOS simulator does not provide a real camera source.
    final isSimulator =
        Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
            Platform.environment['IPHONE_SIMULATOR_ROOT'] != null;
    return !isSimulator;
  }

  return false;
}
