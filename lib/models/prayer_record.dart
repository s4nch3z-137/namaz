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
  final bool sunnahBefore;
  final bool sunnahAfter;
  final bool jamaah;

  PrayerRecord({
    required this.date,
    required this.prayerName,
    required this.status,
    this.sunnahBefore = false,
    this.sunnahAfter = false,
    this.jamaah = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayerName': prayerName,
      'status': status.index,
      'sunnahBefore': sunnahBefore,
      'sunnahAfter': sunnahAfter,
      'jamaah': jamaah,
    };
  }

  factory PrayerRecord.fromJson(Map<String, dynamic> json) {
    return PrayerRecord(
      date: json['date'],
      prayerName: json['prayerName'],
      status: PrayerStatus.values[json['status']],
      sunnahBefore: json['sunnahBefore'] ?? false,
      sunnahAfter: json['sunnahAfter'] ?? false,
      jamaah: json['jamaah'] ?? false,
    );
  }
}
