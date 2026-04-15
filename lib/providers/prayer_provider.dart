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
  String cityName = "دیاریکردنی شوێن...";
  int currentStreak = 0;
  bool isLoading = true;
  bool isManualLocation = false;
  int? milestoneReached;

  List<PrayerRecord> todaysRecords = [];

  static const _milestones = [7, 30, 100, 365];

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

    final manual = await _storageService.getManualLocation();
    if (manual != null) {
      isManualLocation = true;
      cityName = manual['city'] as String;
      currentPosition = Position(
        latitude: manual['lat'] as double,
        longitude: manual['lng'] as double,
        timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, altitudeAccuracy: 0,
        heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0,
      );
    } else {
      isManualLocation = false;
      currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition != null) {
        cityName = await _locationService.getCityName(currentPosition!);
      } else {
        cityName = "شوێن بەردەست نییە";
      }
    }

    if (currentPosition != null) {
      prayerTimes = _prayerTimeService.getPrayerTimes(currentPosition!, DateTime.now());
      await _scheduleNotifications();
      await _loadTodaysRecords();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> setManualLocation(double lat, double lng, String city) async {
    await _storageService.saveManualLocation(lat, lng, city);
    await fetchLocationAndTimes();
  }

  Future<void> resetToGPS() async {
    await _storageService.clearManualLocation();
    await fetchLocationAndTimes();
  }

  Future<void> _loadTodaysRecords() async {
    final String todayDate = DateTime.now().toIso8601String().split('T').first;
    todaysRecords = await _storageService.getPrayerRecordsForDate(todayDate);
    notifyListeners();
  }

  /// Anti-cheat: only the FIRST log of a prayer today affects the streak.
  /// Re-logging only updates sunnah/jamaah metadata — streak never double-counts.
  Future<void> logPrayer(
    String prayerName,
    PrayerStatus status, {
    bool sunnahBefore = false,
    bool sunnahAfter = false,
    bool jamaah = false,
  }) async {
    final String todayDate = DateTime.now().toIso8601String().split('T').first;

    final existing = todaysRecords.cast<PrayerRecord?>().firstWhere(
      (r) => r?.prayerName == prayerName,
      orElse: () => null,
    );

    final record = PrayerRecord(
      date: todayDate,
      prayerName: prayerName,
      status: status,
      sunnahBefore: sunnahBefore,
      sunnahAfter: sunnahAfter,
      jamaah: jamaah,
    );

    await _storageService.savePrayerRecord(record);

    // Only touch streak on the very first log of this prayer today
    if (existing == null) {
      if (status == PrayerStatus.missed) {
        await _storageService.resetStreak();
      } else {
        await _storageService.incrementStreak();
        final newStreak = await _storageService.getStreak();
        if (_milestones.contains(newStreak)) {
          milestoneReached = newStreak;
        }
      }
    }

    currentStreak = await _storageService.getStreak();
    await _loadTodaysRecords();
  }

  void clearMilestone() {
    milestoneReached = null;
    notifyListeners();
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
