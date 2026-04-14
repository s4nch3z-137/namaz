import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import '../providers/prayer_provider.dart';
import '../providers/prayer_provider.dart';
import '../services/storage_service.dart';
import '../data/quotes.dart';
import '../models/prayer_record.dart';
import '../widgets/prayer_logger_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _quoteIndex = 0;
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final provider = Provider.of<PrayerProvider>(context, listen: false);
      if (provider.prayerTimes != null) {
        final next = provider.prayerTimes!.nextPrayer();
        final time = provider.prayerTimes!.timeForPrayer(next);
        if (time != null) {
          final diff = time.difference(DateTime.now());
          setState(() {
            _timeRemaining = diff.isNegative ? Duration.zero : diff;
          });
        }
      }
    });
  }

  Future<void> _loadQuote() async {
    final storage = StorageService();
    final index = await storage.getDailyQuoteIndex(dailyQuotes.length);
    setState(() {
      _quoteIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF141A31), // Deep rich blue
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(provider.currentStreak, provider.cityName),
                    const SizedBox(height: 32),
                    _buildNextPrediction(provider),
                    const SizedBox(height: 32),
                    const Text(
                      "Daily Forecast",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineForecast(provider),
                    const SizedBox(height: 32),
                    _buildDailyQuote(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(int streak, String city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Namaz Tracker",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Color(0xFFD4AF37), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "$streak",
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white54, size: 16),
            const SizedBox(width: 4),
            Text(
              city,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  LinearGradient _getPrayerGradient(Prayer? prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF8E44AD)]);
      case Prayer.sunrise:
        return const LinearGradient(colors: [Color(0xFFF39C12), Color(0xFFE74C3C)]);
      case Prayer.dhuhr:
        return const LinearGradient(colors: [Color(0xFFF1C40F), Color(0xFFE67E22)]);
      case Prayer.asr:
        return const LinearGradient(colors: [Color(0xFFE67E22), Color(0xFFD35400)]);
      case Prayer.maghrib:
        return const LinearGradient(colors: [Color(0xFF8E44AD), Color(0xFF2C3E50)]);
      case Prayer.isha:
        return const LinearGradient(colors: [Color(0xFF141A31), Color(0xFF000000)]);
      default:
        return const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF3498DB)]);
    }
  }

  Widget _buildNextPrediction(PrayerProvider provider) {
    if (provider.prayerTimes == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text("Locating...", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final nextPrayer = provider.prayerTimes!.nextPrayer();
    final time = provider.prayerTimes!.timeForPrayer(nextPrayer);
    final String nextPrayerStr = nextPrayer.toString().split('.').last;

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$hours:$minutes:$seconds";
    }

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: _getPrayerGradient(nextPrayer),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Next Prayer",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            nextPrayer == Prayer.none ? "TOMORROW" : nextPrayerStr.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            formatDuration(_timeRemaining),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()]),
          ),
          if (time != null) ...[
            const SizedBox(height: 4),
            Text(
              "at ${DateFormat.jm().format(time)}",
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDailyQuote() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Colors.amber, size: 32),
          const SizedBox(height: 12),
          Text(
            dailyQuotes[_quoteIndex],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineForecast(PrayerProvider provider) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Column(
      children: prayers.map((pName) {
        final record = provider.todaysRecords.cast<PrayerRecord?>().firstWhere(
              (r) => r?.prayerName == pName,
              orElse: () => null,
            );

        Color dotColor = Colors.white24;
        if (record != null) {
          if (record.status == PrayerStatus.missed) dotColor = Colors.redAccent.shade700;
          else if (record.sunnahBefore || record.sunnahAfter || record.jamaah) dotColor = Colors.cyanAccent.shade400;
          else dotColor = Colors.greenAccent.shade400;
        }

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => PrayerLoggerDialog(
                prayerName: pName,
                existingRecord: record,
                provider: provider,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: record != null ? dotColor.withOpacity(0.5) : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: record != null
                        ? [
                            BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 8)
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    pName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (record != null)
                  Icon(
                    record.status == PrayerStatus.missed
                        ? Icons.close
                        : Icons.check,
                    color: dotColor,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
