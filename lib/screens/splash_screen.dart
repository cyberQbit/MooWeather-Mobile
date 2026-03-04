import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'home_screen.dart';
import 'onboarding_screen.dart'; // Birazdan oluşturacağımız karşılama ekranı

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeUser();
  }

  Future<void> _routeUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Eğer 'is_first_time' diye bir kayıt yoksa (null dönerse), demek ki ilk defa giriyordur (true kabul et)
    final isFirstTime = prefs.getBool('is_first_time') ?? true;

    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      if (isFirstTime) {
        // İlk defa giriyorsa kırmızı halıya (Onboarding) gönder
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        // Zaten eski müşteriyse direkt Ana Sayfaya (Home) al
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Karanlık tema arka planı
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png',
                height: 120), // Logonun yolu doğru olmalı
            const SizedBox(height: 20),
            const Text(
              'MooWeather',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sizin Hava Durumu Asistanınız',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
