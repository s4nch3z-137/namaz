import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/prayer_provider.dart';
import '../services/storage_service.dart';
import '../data/quotes.dart';
import 'prayer_log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuote();
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
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(provider.currentStreak),
                    const SizedBox(height: 32),
                    _buildNextPrediction(provider),
                    const SizedBox(height: 32),
                    _buildDailyQuote(),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFD4AF37), // Metallic Gold
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrayerLogScreen()),
                        );
                      },
                      child: const Text(
                        "Log Today's Prayers",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF141A31),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(int streak) {
    return Row(
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
    );
  }

  Widget _buildNextPrediction(PrayerProvider provider) {
    if (provider.prayerTimes == null) {
      return const Text("Location needed to calculate times.",
          style: TextStyle(color: Colors.white70));
    }

    final nextPrayer = provider.prayerTimes!.nextPrayer();
    final time = provider.prayerTimes!.timeForPrayer(nextPrayer);
    final String nextPrayerStr = nextPrayer.toString().split('.').last;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
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
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            nextPrayerStr.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (time != null)
            Text(
              DateFormat.jm().format(time),
              style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.w600),
            ),
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
}
