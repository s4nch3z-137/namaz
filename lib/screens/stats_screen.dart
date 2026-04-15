import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/prayer_record.dart';
import '../l10n/kurdish_strings.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StorageService _storage = StorageService();
  static const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  List<_DayStat> _stats = [];
  bool _loading = true;
  int _totalThisWeek = 0;
  int _bestDay = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final now = DateTime.now();
    final stats = <_DayStat>[];
    int total = 0;
    int best = 0;

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr = day.toIso8601String().split('T').first;
      final records = await _storage.getPrayerRecordsForDate(dateStr);

      int completed = 0;
      int missed = 0;
      int withSunnah = 0;

      for (final r in records) {
        if (r.status != PrayerStatus.missed) {
          completed++;
          if (r.sunnahBefore || r.sunnahAfter || r.jamaah) withSunnah++;
        } else {
          missed++;
        }
      }

      total += completed;
      if (completed > best) best = completed;

      stats.add(_DayStat(
        date: day,
        completed: completed,
        missed: missed,
        withSunnah: withSunnah,
        records: records,
      ));
    }

    if (mounted) {
      setState(() {
        _stats = stats;
        _totalThisWeek = total;
        _bestDay = best;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1226),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ئامارەکانی هەفتانە',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('📊 ئامارەکانی ٧ ڕۆژی ڕابردوو'),
                  const SizedBox(height: 16),
                  _buildBarChart(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('📅 داتاڵی ڕۆژانە'),
                  const SizedBox(height: 12),
                  ..._stats.reversed.map(_buildDayDetail).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    final completionPct =
        _totalThisWeek > 0 ? (_totalThisWeek * 100 ~/ 35) : 0;
    return Row(
      children: [
        _summaryCard(
          icon: '🕌',
          label: 'کۆی هەفتانە',
          value: '$_totalThisWeek',
          sub: 'لە ٣٥',
          color: const Color(0xFF26D0CE),
        ),
        const SizedBox(width: 12),
        _summaryCard(
          icon: '🏆',
          label: 'باشترین ڕۆژ',
          value: '$_bestDay',
          sub: 'لە ٥',
          color: const Color(0xFFD4AF37),
        ),
        const SizedBox(width: 12),
        _summaryCard(
          icon: '📈',
          label: 'ڕێژەی تەواوکردن',
          value: '$completionPct%',
          sub: 'ئەم هەفتانە',
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(75)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_stats.isEmpty) return const SizedBox.shrink();
    const maxVal = 5.0;
    return Container(
      height: 190,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _stats.map((stat) {
          final ratio = (stat.completed / maxVal).clamp(0.0, 1.0);
          final dayIdx = stat.date.weekday % 7; // 0=Sun ... 6=Sat
          final dayLabel = KS.weekDays[dayIdx];
          final short =
              dayLabel.length > 3 ? dayLabel.substring(0, 3) : dayLabel;
          final isToday = _isSameDay(stat.date, DateTime.now());

          Color barColor;
          if (stat.completed == 5) barColor = Colors.greenAccent;
          else if (stat.completed >= 3) barColor = Colors.amber;
          else if (stat.completed > 0) barColor = Colors.orangeAccent;
          else barColor = Colors.redAccent;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${stat.completed}',
                    style: TextStyle(
                      color: barColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    height: (100 * ratio + 4).clamp(4.0, 120.0),
                    decoration: BoxDecoration(
                      color: isToday ? barColor : barColor.withAlpha(128),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isToday
                          ? [BoxShadow(
                              color: barColor.withAlpha(100), blurRadius: 8)]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    short,
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white38,
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayDetail(_DayStat stat) {
    final isToday = _isSameDay(stat.date, DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? const Color(0xFFD4AF37).withAlpha(128)
              : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stat.completed}/٥ نوێژ',
                style: TextStyle(
                  color:
                      stat.completed == 5 ? Colors.greenAccent : Colors.white60,
                  fontSize: 13,
                ),
              ),
              Text(
                isToday ? 'ئەمڕۆ' : DateFormat('dd/MM').format(stat.date),
                style: TextStyle(
                  color: isToday ? const Color(0xFFD4AF37) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (stat.records.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _prayers.map((p) {
                final r = stat.records.cast<PrayerRecord?>().firstWhere(
                  (r) => r?.prayerName == p,
                  orElse: () => null,
                );
                String icon = '⬜';
                if (r != null) {
                  if (r.status == PrayerStatus.missed) {
                    icon = '❌';
                  } else if (r.sunnahBefore || r.sunnahAfter || r.jamaah) {
                    icon = '✨';
                  } else if (r.status == PrayerStatus.prayedGoldenTime) {
                    icon = '✅';
                  } else {
                    icon = '🕐';
                  }
                }
                final kuName = KS.prayerNameKu(p);
                final short =
                    kuName.length >= 2 ? kuName.substring(0, 2) : kuName;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        short,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 9),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            const SizedBox(height: 6),
            const Text(
              'هیچ نوێژێک تۆمار نەکراوە',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayStat {
  final DateTime date;
  final int completed;
  final int missed;
  final int withSunnah;
  final List<PrayerRecord> records;

  _DayStat({
    required this.date,
    required this.completed,
    required this.missed,
    required this.withSunnah,
    required this.records,
  });
}
