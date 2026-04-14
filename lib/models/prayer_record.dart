enum PrayerStatus {
  notPrayed,
  prayedGoldenTime,
  late,
  missed
}

class PrayerRecord {
  final String date; // YYYY-MM-DD format
  final String prayerName; // Fajr, Dhuhr, Asr, Maghrib, Isha
  final PrayerStatus status;

  PrayerRecord({
    required this.date,
    required this.prayerName,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayerName': prayerName,
      'status': status.index,
    };
  }

  factory PrayerRecord.fromJson(Map<String, dynamic> json) {
    return PrayerRecord(
      date: json['date'],
      prayerName: json['prayerName'],
      status: PrayerStatus.values[json['status']],
    );
  }
}
