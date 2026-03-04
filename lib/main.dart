import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Motorları başlatmadan önce Flutter'ın hazır olduğundan emin ol
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    // 1. DİL MOTORU:
    EasyLocalization(
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
        Locale('es', 'ES')
      ],
      path: 'assets/translations',
      fallbackLocale:
          const Locale('tr', 'TR'), // Herhangi bir hata olursa Türkçe aç
      child: MultiProvider(
        // 2. TEMA MOTORU:
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema motoruna bağlan
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MooWeather',
      debugShowCheckedModeBanner: false,

      // Dil ayarları
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Tema ayarları (Motorun seçtiği temayı uygular)
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F2027),
      ),

      home: const SplashScreen(),
    );
  }
}
