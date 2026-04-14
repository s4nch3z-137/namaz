import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeService {
  PrayerTimes? getPrayerTimes(Position position, DateTime date) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    // Setting calculation parameters. Muslim World League is a common default.
    final params = CalculationMethod.muslim_world_league.getParameters();
    
    // Create DateComponents for the specific date requested
    final dateComponents = DateComponents.from(date);
    
    return PrayerTimes(coordinates, dateComponents, params);
  }
}
