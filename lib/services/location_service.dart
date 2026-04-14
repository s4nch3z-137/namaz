import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Default location (Mecca) for platforms that don't support geolocator
  static const double DEFAULT_LATITUDE = 21.4225;
  static const double DEFAULT_LONGITUDE = 39.8262;

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        // Platform doesn't support this
        return _getDefaultPosition();
      }

      if (!serviceEnabled) {
        return _getDefaultPosition();
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getDefaultPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getDefaultPosition();
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return _getDefaultPosition();
    }
  }

  Future<String> getCityName(Position position) async {
    try {
      if (position.latitude == DEFAULT_LATITUDE && position.longitude == DEFAULT_LONGITUDE) {
        return "Mecca, Saudi Arabia";
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? "";
        final country = place.country ?? "";
        return [if (city.isNotEmpty) city, if (country.isNotEmpty) country].join(', ');
      }
    } catch (e) {
      // Fallback
    }
    return "Unknown Location";
  }

  Position _getDefaultPosition() {
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
