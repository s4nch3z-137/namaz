import '../l10n/kurdish_strings.dart';

class HijriService {
  /// Returns a formatted Hijri date string in Kurdish Sorani
  static String getTodayHijri() {
    final now = DateTime.now();
    final h = _toHijri(now.year, now.month, now.day);
    final monthName = KS.hijriMonths[h['month']! - 1];
    return '${h['day']} $monthName ${h['year']}';
  }

  static Map<String, int> _toHijri(int year, int month, int day) {
    // Convert Gregorian to Julian Day Number
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    final jdn = day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;

    // Convert JDN to Hijri
    final l = jdn - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = (((10985 - l2) / 5316).floor()) *
            (((50 * l2) / 17719).floor()) +
        ((l2 / 5670).floor()) * (((43 * l2) / 15238).floor());
    final l3 = l2 -
        (((30 - j) / 20).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 20).floor()) * (((15238 * j) / 43).floor()) +
        29;
    final hMonth = ((24 * l3) / 709).floor();
    final hDay = l3 - ((709 * hMonth) / 24).floor();
    final hYear = 30 * n + j - 30;

    return {'year': hYear, 'month': hMonth, 'day': hDay};
  }
}
