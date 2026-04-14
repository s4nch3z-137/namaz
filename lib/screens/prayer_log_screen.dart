import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../models/prayer_record.dart';

class PrayerLogScreen extends StatelessWidget {
  const PrayerLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Scaffold(
      backgroundColor: const Color(0xFF141A31),
      appBar: AppBar(
        title: const Text('Log Today\'s Salah'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: prayers.length,
        itemBuilder: (context, index) {
          final prayerName = prayers[index];
          final loggedRecord =
              provider.todaysRecords.cast<PrayerRecord?>().firstWhere(
                    (r) => r?.prayerName == prayerName,
                    orElse: () => null,
                  );

          return _buildPrayerCard(context, prayerName, loggedRecord, provider);
        },
      ),
    );
  }

  Widget _buildPrayerCard(BuildContext context, String prayerName,
      PrayerRecord? record, PrayerProvider provider) {
    Color cardColor = Colors.white.withOpacity(0.05);
    Color borderColor = Colors.white.withOpacity(0.1);

    if (record != null) {
      if (record.status == PrayerStatus.prayedGoldenTime) {
        cardColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
      } else if (record.status == PrayerStatus.late) {
        cardColor = Colors.orange.withOpacity(0.2);
        borderColor = Colors.orange;
      } else if (record.status == PrayerStatus.missed) {
        cardColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prayerName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              if (record != null) _buildStatusBadge(record.status),
            ],
          ),
          const SizedBox(height: 16),
          if (record == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionBtn(context, provider, prayerName,
                    PrayerStatus.prayedGoldenTime, "Golden", Colors.green),
                _buildActionBtn(context, provider, prayerName,
                    PrayerStatus.late, "Late", Colors.orange),
                _buildActionBtn(context, provider, prayerName,
                    PrayerStatus.missed, "Missed", Colors.red),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PrayerStatus status) {
    String text = "";
    Color color = Colors.white;
    switch (status) {
      case PrayerStatus.prayedGoldenTime:
        text = "Golden Time!";
        color = Colors.greenAccent;
        break;
      case PrayerStatus.late:
        text = "Late";
        color = Colors.orangeAccent;
        break;
      case PrayerStatus.missed:
        text = "Missed";
        color = Colors.redAccent;
        break;
      default:
        text = "Pending";
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionBtn(BuildContext context, PrayerProvider provider,
      String name, PrayerStatus status, String label, Color color) {
    return InkWell(
      onTap: () {
        provider.logPrayer(name, status);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
