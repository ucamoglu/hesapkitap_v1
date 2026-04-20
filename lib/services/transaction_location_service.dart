import 'package:geolocator/geolocator.dart';

class TransactionLocationPoint {
  final double latitude;
  final double longitude;

  const TransactionLocationPoint({
    required this.latitude,
    required this.longitude,
  });
}

class TransactionLocationService {
  static Future<TransactionLocationPoint?> tryGetCurrentLocation({
    bool requestPermission = false,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );
      return TransactionLocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}
