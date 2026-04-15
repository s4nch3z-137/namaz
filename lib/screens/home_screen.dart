import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import '../providers/prayer_provider.dart';
import '../services/storage_service.dart';
import '../services/hijri_service.dart';
import '../data/quotes.dart';
import '../models/prayer_record.dart';
import '../widgets/prayer_logger_dialog.dart';
import '../widgets/location_picker_sheet.dart';
import '../l10n/kurdish_strings.dart';
import '../screens/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _quoteIndex = 0;
  Timer? _countdownTimer;
  Timer? _quoteTimer;
  Duration _timeRemaining = Duration.zero;
  late AnimationController _pulseController;

  static const _prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startCountdown();
    _startQuoteRotation();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _quoteTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final provider = Provider.of<PrayerProvider>(context, listen: false);
      if (provider.prayerTimes == null) return;
      final next = provider.prayerTimes!.nextPrayer();
      if (next == Prayer.none) {
        // After Isha — show time to tomorrow's Fajr
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final fajrTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 4, 30);
        final diff = fajrTomorrow.difference(DateTime.now());
        setState(() => _timeRemaining = diff.isNegative ? Duration.zero : diff);
      } else {
        final time = provider.prayerTimes!.timeForPrayer(next);
        if (time != null) {
          final diff = time.difference(DateTime.now());
          setState(() => _timeRemaining = diff.isNegative ? Duration.zero : diff);
        }
      }
    });
  }

  void _startQuoteRotation() {
    // Rotate quotes every 60 seconds
    _quoteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % dailyQuotes.length;
      });
    });
  }

  DateTime? _getPrayerTime(PrayerTimes times, String prayerName) {
    switch (prayerName) {
      case 'Fajr': return times.fajr;
      case 'Dhuhr': return times.dhuhr;
      case 'Asr': return times.asr;
      case 'Maghrib': return times.maghrib;
      case 'Isha': return times.isha;
      default: return null;
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  LinearGradient _getPrayerGradient(Prayer? prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF7D3C98)]);
      case Prayer.dhuhr:
        return const LinearGradient(colors: [Color(0xFFD4AC0D), Color(0xFFCA6F1E)]);
      case Prayer.asr:
        return const LinearGradient(colors: [Color(0xFFBA4A00), Color(0xFF922B21)]);
      case Prayer.maghrib:
        return const LinearGradient(colors: [Color(0xFF7D3C98), Color(0xFF1A5276)]);
      case Prayer.isha:
        return const LinearGradient(colors: [Color(0xFF1C2833), Color(0xFF0B0C10)]);
      default:
        return const LinearGradient(colors: [Color(0xFF1A2980), Color(0xFF26D0CE)]);
    }
  }

  void _checkMilestone(PrayerProvider provider) {
    if (provider.milestoneReached != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A2340),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              KS.milestoneTitle,

              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
            ),
            content: Text(
              KS.milestone(provider.milestoneReached!),

              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  provider.clearMilestone();
                  Navigator.pop(context);
                },
                child: Text(KS.ok, style: const TextStyle(color: Color(0xFFD4AF37))),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    _checkMilestone(provider);

    return Scaffold(
        body: Stack(
          children: [
            // Background wallpaper
            Positioned.fill(
              child: Image.asset(
                'assets/images/mosque_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            // Dark gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xCC0A0E1A),
                      Color(0xBB0D1226),
                      Color(0x990A0E1A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: provider.isLoading
                  ? _buildLoadingScreen()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(provider),
                          const SizedBox(height: 24),
                          _buildNextPrayerCard(provider),
                          const SizedBox(height: 28),
                          _buildSectionTitle(KS.dailyForecast),
                          const SizedBox(height: 12),
                          _buildTimelineForecast(provider),
                          const SizedBox(height: 28),
                          _buildQuoteCard(),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Opacity(
              opacity: 0.6 + 0.4 * _pulseController.value,
              child: child,
            ),
            child: const Text('☪', style: TextStyle(fontSize: 64, color: Color(0xFFD4AF37))),
          ),
          const SizedBox(height: 20),
          const Text(
            'دیاریکردنی کات و شوێن...',

            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PrayerProvider provider) {
    final hijriDate = HijriService.getTodayHijri();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Right side: title + dates
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                KS.appName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hijriDate,

                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const LocationPickerSheet(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.cityName,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on, color: Color(0xFFD4AF37), size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Left side: streak + stats button
        Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StatsScreen())),
              child: _buildStreakBadge(provider.currentStreak),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StatsScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white54, size: 14),
                    SizedBox(width: 4),
                    Text('ئامار', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF5CBA7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 22),
          const SizedBox(height: 2),
          Text(
            '$streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('ڕۆژ', style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(PrayerProvider provider) {
    if (provider.prayerTimes == null) {
      return _glassMorphCard(
        child: const Center(
          child: Text('دیاریکردنی شوێن...', style: TextStyle(color: Colors.white60)),
        ),
      );
    }

    final next = provider.prayerTimes!.nextPrayer();
    final isAfterIsha = next == Prayer.none;
    final nextName = isAfterIsha ? KS.tomorrowFajr : KS.prayerNameKu(_prayerOrder[
        isAfterIsha ? 0 : _prayerOrder.indexWhere((p) =>
            p.toLowerCase() == next.toString().split('.').last.toLowerCase())]);

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: _getPrayerGradient(isAfterIsha ? Prayer.fajr : next),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            KS.nextPrayer,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Opacity(
              opacity: 0.7 + 0.3 * _pulseController.value,
              child: child,
            ),
            child: Text(
              _formatDuration(_timeRemaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (!isAfterIsha && provider.prayerTimes!.timeForPrayer(next) != null) ...[
            const SizedBox(height: 6),
            Text(
              DateFormat('h:mm a').format(provider.prayerTimes!.timeForPrayer(next)!),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,

      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTimelineForecast(PrayerProvider provider) {
    return Column(
      children: _prayerOrder.map((pName) {
        final record = provider.todaysRecords.cast<PrayerRecord?>().firstWhere(
          (r) => r?.prayerName == pName,
          orElse: () => null,
        );

        final prayerTime = provider.prayerTimes != null
            ? _getPrayerTime(provider.prayerTimes!, pName)
            : null;

        // Score badge
        String badge = '';
        Color badgeColor = Colors.white24;
        Color borderColor = Colors.white10;

        if (record != null) {
          if (record.status == PrayerStatus.missed) {
            badge = '✗';
            badgeColor = Colors.redAccent.shade700;
            borderColor = Colors.redAccent.withOpacity(0.4);
          } else if (record.sunnahBefore || record.sunnahAfter || record.jamaah) {
            badge = '✨';
            badgeColor = Colors.cyanAccent.shade400;
            borderColor = Colors.cyanAccent.withOpacity(0.4);
          } else if (record.status == PrayerStatus.prayedGoldenTime) {
            badge = '⭐';
            badgeColor = Colors.greenAccent.shade400;
            borderColor = Colors.greenAccent.withOpacity(0.4);
          } else {
            badge = '⏰';
            badgeColor = Colors.orangeAccent;
            borderColor = Colors.orangeAccent.withOpacity(0.4);
          }
        }

        return GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => PrayerLoggerDialog(
              prayerName: pName,
              existingRecord: record,
              provider: provider,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                // Status badge (left in RTL = visual right)
                if (badge.isNotEmpty)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: badgeColor.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(badge, style: const TextStyle(fontSize: 16)),
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                      child: Icon(Icons.radio_button_unchecked, color: Colors.white30, size: 18),
                    ),
                  ),
                const SizedBox(width: 14),
                // Prayer name + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        KS.prayerNameKu(pName),

                        style: TextStyle(
                          color: record != null ? Colors.white : Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (prayerTime != null)
                        Text(
                          DateFormat('h:mm a').format(prayerTime),
                          style: TextStyle(
                            color: record != null
                                ? badgeColor.withOpacity(0.8)
                                : Colors.white30,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuoteCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_quoteIndex + 1}/${dailyQuotes.length}',
                    style: const TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                  Row(
                    children: [
                      Text(
                        KS.quoteLabel,

                        style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.format_quote, color: Color(0xFFD4AF37), size: 20),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  dailyQuotes[_quoteIndex],
                  key: ValueKey(_quoteIndex),

                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassMorphCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: child,
        ),
      ),
    );
  }
}
