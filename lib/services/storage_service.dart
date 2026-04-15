import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_record.dart';

class StorageService {
  static const String _streakKey = 'user_streak';
  static const String _recordsKey = 'prayer_records';
  static const String _quoteIndexKey = 'daily_quote_index';
  static const String _lastQuoteDateKey = 'last_quote_date';
  static const String _manualLatKey = 'manual_lat';
  static const String _manualLngKey = 'manual_lng';
  static const String _manualCityKey = 'manual_city';

  Future<void> saveManualLocation(double lat, double lng, String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_manualLatKey, lat);
    await prefs.setDouble(_manualLngKey, lng);
    await prefs.setString(_manualCityKey, city);
  }

  Future<Map<String, dynamic>?> getManualLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_manualLatKey);
    final lng = prefs.getDouble(_manualLngKey);
    final city = prefs.getString(_manualCityKey);
    if (lat == null || lng == null || city == null) return null;
    return {'lat': lat, 'lng': lng, 'city': city};
  }

  Future<void> clearManualLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_manualLatKey);
    await prefs.remove(_manualLngKey);
    await prefs.remove(_manualCityKey);
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> incrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int currentStreak = await getStreak();
    await prefs.setInt(_streakKey, currentStreak + 1);
  }

  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, 0);
  }

  Future<void> savePrayerRecord(PrayerRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recordsJson = prefs.getStringList(_recordsKey) ?? [];
    
    // Remove if already exists for this date and prayer to avoid duplicates
    recordsJson.removeWhere((item) {
        final r = PrayerRecord.fromJson(jsonDecode(item));
        return r.date == record.date && r.prayerName == record.prayerName;
    });

    recordsJson.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_recordsKey, recordsJson);
  }

  Future<List<PrayerRecord>> getPrayerRecordsForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recordsJson = prefs.getStringList(_recordsKey) ?? [];
    
    return recordsJson
        .map((e) => PrayerRecord.fromJson(jsonDecode(e)))
        .where((record) => record.date == date)
        .toList();
  }

  Future<int> getDailyQuoteIndex(int maxQuotes) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T').first;
    final String? lastDate = prefs.getString(_lastQuoteDateKey);
    int index = prefs.getInt(_quoteIndexKey) ?? 0;

    if (lastDate != today) {
       index = (index + 1) % maxQuotes;
       await prefs.setString(_lastQuoteDateKey, today);
       await prefs.setInt(_quoteIndexKey, index);
    }
    return index;
  }
}
