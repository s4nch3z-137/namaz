import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;

class LocationService {
  // Default location (Mecca) for platforms that don't support geolocator
  static const double DEFAULT_LATITUDE = 21.4225;
  static const double DEFAULT_LONGITUDE = 39.8262;

  Future<Position?> getCurrentLocation() async {
    // On web platform, geolocator doesn't work reliably
    // Return a default position for web/windows
    if (true) {
      // Always try geolocator for all platforms now
      try {
        bool serviceEnabled;
        LocationPermission permission;

        // Check if location services are enabled
        try {
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        } catch (e) {
          // Platform doesn't support this, return default location
          return Position(
            latitude: DEFAULT_LATITUDE,
            longitude: DEFAULT_LONGITUDE,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }

        if (!serviceEnabled) {
          return null;
        }

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return null;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          return null;
        }

        return await Geolocator.getCurrentPosition();
      } catch (e) {
        // Fallback to default location if anything fails
        return Position(
          latitude: DEFAULT_LATITUDE,
          longitude: DEFAULT_LONGITUDE,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    }
  }
}
