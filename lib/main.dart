import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/prayer_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NamazTrackerApp());
}

class NamazTrackerApp extends StatelessWidget {
  const NamazTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
      ],
      child: MaterialApp(
        title: 'ئامرازی نوێژ',
        debugShowCheckedModeBanner: false,
        // RTL for Kurdish Sorani
        locale: const Locale('ckb'),
        supportedLocales: const [Locale('ckb'), Locale('ar'), Locale('en')],
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'NRT',
          primaryColor: const Color(0xFFD4AF37),
          scaffoldBackgroundColor: const Color(0xFF0D1226),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            secondary: Color(0xFF26D0CE),
            surface: Color(0xFF1A2340),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
