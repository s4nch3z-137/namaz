/// All UI strings in Kurdish Sorani (کوردی سۆرانی)
class KS {
  // App
  static const appName = 'ئامرازی نوێژ';

  // Prayer names
  static const fajr = 'فەجر';
  static const dhuhr = 'نیوەڕۆ';
  static const asr = 'عەسر';
  static const maghrib = 'مەغریب';
  static const isha = 'عیشا';
  static const sunrise = 'سووریانی';

  // Home screen
  static const nextPrayer = 'نوێژی داهاتوو';
  static const dailyForecast = 'پێشبینی ڕۆژانە';
  static const tomorrowFajr = 'فەجری سبەی';
  static const streak = 'زنجیرە';
  static const days = 'ڕۆژ';
  static const quoteLabel = 'بیرۆکەی ئەمڕۆ';
  static const weeklyStats = 'ئامارەکان';

  // Prayer status
  static const goldenTime = 'کاتی زێرین';
  static const late = 'درەنگ';
  static const missed = 'لەدەست‌چوو';
  static const pending = 'چاوەڕوان';

  // Prayer logger
  static const logPrayerTitle = 'تۆمارکردنی نوێژ';
  static const sealRecord = 'تۆمار بکە';
  static const sunnahBefore = 'سوننەی پێشوو';
  static const sunnahAfter = 'سوننەی دواوە';
  static const prayedInJamaah = 'بە جەماعەت';
  static const extraDeeds = 'کردەی زیادە';

  // Location
  static const locating = 'دیاریکردنی شوێن...';
  static const locationUnavailable = 'شوێن بەردەست نییە';
  static const changeLocation = 'گۆڕینی شوێن';
  static const useGPS = 'بەکارهێنانی ئاراستەکار';
  static const searchCityHint = 'گەڕان بۆ شار (ئەربیل، سلێمانی...)';
  static const noCitiesFound = 'هیچ ئەنجامێک نەدۆزرایەوە. شاری تر بنووسە.';
  static const searchFailed = 'گەڕان سەرنەکەوت. ئینتەرنەتت بپشکنە.';
  static const manualLocation = '📍 دیاریکراو';
  static const gpsLocation = '📡 ئاراستەکار';

  // Stats
  static const prayersOfDay = 'نوێژ';
  static const outOf = 'لە';
  static const thisWeek = 'ئەم هەفتانە';
  static const totalCompleted = 'کۆی تەواوکراو';

  // Days of week (Kurdish Sorani)
  static const weekDays = [
    'یەکشەممە', 'دووشەممە', 'سێشەممە',
    'چوارشەممە', 'پێنجشەممە', 'هەینی', 'شەممە'
  ];

  // Hijri months
  static const hijriMonths = [
    'مووحەڕەم', 'سەفەر', 'ڕەبیعولئەوول', 'ڕەبیعولئاخیر',
    'جەمادولئووڵا', 'جەمادولئاخیرە', 'ڕەجەب', 'شەعبان',
    'ڕەمەزان', 'شەووال', 'زولقەعدە', 'زولحەججە'
  ];

  // Milestone messages
  static String milestone(int n) =>
      '🎉 زنجیرەی $n ڕۆژت بەدەست هێنا!\nمبارەکباد! بەردەوام بە.';

  static const milestoneTitle = 'دەستکەوت! 🏆';
  static const ok = 'باشە';

  // Prayer name to Kurdish helper
  static String prayerNameKu(String en) {
    switch (en) {
      case 'Fajr': return fajr;
      case 'Dhuhr': return dhuhr;
      case 'Asr': return asr;
      case 'Maghrib': return maghrib;
      case 'Isha': return isha;
      default: return en;
    }
  }
}
