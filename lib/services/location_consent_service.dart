import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocationConsentPreference {
  final bool promptSeen;
  final bool autoCaptureEnabled;

  const LocationConsentPreference({
    required this.promptSeen,
    required this.autoCaptureEnabled,
  });
}

class LocationConsentService {
  static const _fileName = 'location_consent_v1.json';

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<LocationConsentPreference?> getPreference() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LocationConsentPreference(
        promptSeen: json['promptSeen'] == true,
        autoCaptureEnabled: json['autoCaptureEnabled'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> savePreference({
    required bool autoCaptureEnabled,
  }) async {
    final file = await _file();
    final payload = jsonEncode({
      'promptSeen': true,
      'autoCaptureEnabled': autoCaptureEnabled,
    });
    await file.writeAsString(payload, flush: true);
  }
}
