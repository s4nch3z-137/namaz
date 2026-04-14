import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/prayer_record.dart';

class PrayerProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  PrayerTimes? prayerTimes;
  Position? currentPosition;
  String cityName = "Locating...";
  int currentStreak = 0;
  bool isLoading = true;

  List<PrayerRecord> todaysRecords = [];

  PrayerProvider() {
    _init();
  }

  Future<void> _init() async {
    await _notificationService.init();
    currentStreak = await _storageService.getStreak();
    await fetchLocationAndTimes();
  }

  Future<void> fetchLocationAndTimes() async {
    isLoading = true;
    notifyListeners();

    currentPosition = await _locationService.getCurrentLocation();
    if (currentPosition != null) {
      cityName = await _locationService.getCityName(currentPosition!);
      prayerTimes = _prayerTimeService.getPrayerTimes(currentPosition!, DateTime.now());
      await _scheduleNotifications();
      await _loadTodaysRecords();
    } else {
      cityName = "Location Unavailable";
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTodaysRecords() async {
    final String todayDate = DateTime.now().toIso8601String().split('T').first;
    todaysRecords = await _storageService.getPrayerRecordsForDate(todayDate);
    notifyListeners();
  }

  Future<void> logPrayer(String prayerName, PrayerStatus status, {bool sunnahBefore = false, bool sunnahAfter = false, bool jamaah = false}) async {
    final String todayDate = DateTime.now().toIso8601String().split('T').first;
    final record = PrayerRecord(
      date: todayDate, 
      prayerName: prayerName, 
      status: status,
      sunnahBefore: sunnahBefore,
      sunnahAfter: sunnahAfter,
      jamaah: jamaah,
    );
    
    await _storageService.savePrayerRecord(record);
    
    if (status == PrayerStatus.missed) {
      await _storageService.resetStreak();
    } else {
      await _storageService.incrementStreak();
    }
    
    currentStreak = await _storageService.getStreak();
    await _loadTodaysRecords();
  }

  Future<void> _scheduleNotifications() async {
    if (prayerTimes != null) {
      await _notificationService.schedulePrayerNotification(1, 'Fajr', prayerTimes!.fajr);
      await _notificationService.schedulePrayerNotification(2, 'Dhuhr', prayerTimes!.dhuhr);
      await _notificationService.schedulePrayerNotification(3, 'Asr', prayerTimes!.asr);
      await _notificationService.schedulePrayerNotification(4, 'Maghrib', prayerTimes!.maghrib);
      await _notificationService.schedulePrayerNotification(5, 'Isha', prayerTimes!.isha);
    }
  }
}
