// lib/constants/app_colors.dart

import 'package:flutter/material.dart';

// Uygulamanın tüm renk paletini burada topluyorum.
// Not: Renkleri merkezi bir yerde tutmak, ileride tema değişikliği veya yeni hava durumu eklemek için çok kolaylık sağlar.
// Kendi notum: Her bir hava durumu için gradient tanımlamak, UI'da dinamik ve modern bir his veriyor.
class AppColors {
  // Ana renkler (logo, buton, başlık vs. için)
  static const primary = Color(0xFF4A90E2); // Ana mavi
  static const primaryBlue = Color(0xFF4A90E2); // Yedek ana mavi
  static const darkBlue = Color(0xFF2C3E50); // Koyu mavi
  static const lightGrey = Color(0xFFF0F4F8); // Açık gri (arka plan)
  static const darkGrey = Color(0xFF95A5A6); // Koyu gri (ikincil yazı)
  static const white = Color(0xFFFFFFFF); // Saf beyaz

  // Hava durumuna göre gradient renkleri
  // Açık Hava (Clear/Sunny) için gradient
  static const List<Color> clearDayGradient = [
    Color(0xFF56CCF2), // Açık mavi (gündüz gökyüzü)
    Color(0xFF2F80ED), // Koyu mavi (ufuk)
  ];

  // Gece açık hava için gradient
  static const List<Color> clearNightGradient = [
    Color(0xFF0F2027), // Koyu lacivert (gece gökyüzü)
    Color(0xFF203A43), // Orta lacivert
    Color(0xFF2C5364), // Açık lacivert
  ];

  // Bulutlu hava için gradient
  static const List<Color> cloudsGradient = [
    Color(0xFF536976), // Koyu gri (bulut)
    Color(0xFFBBD2C5), // Açık gri-yeşil (gökyüzü)
  ];

  // Yağmurlu hava için gradient
  static const List<Color> rainGradient = [
    Color(0xFF2C3E50), // Koyu gri-mavi (yağmur bulutu)
    Color(0xFF3498DB), // Mavi (yağmur damlası)
  ];

  // Karlı hava için gradient
  static const List<Color> snowGradient = [
    Color(0xFFE0EAFC), // Çok açık mavi (kar)
    Color(0xFFCFDEF3), // Açık mavi (buz)
  ];

  // Fırtına için gradient
  static const List<Color> stormGradient = [
    Color(0xFF141E30), // Çok koyu mavi (fırtına bulutu)
    Color(0xFF243B55), // Koyu mavi
  ];

  // Thunderstorm için alias (fırtına ile aynı gradient)
  static const List<Color> thunderstormGradient = stormGradient;

  // Sisli/Dumanlı hava için gradient (devamı aşağıda)
  static const List<Color> mistGradient = [
    Color(0xFF757F9A), // Gri-mavi
    Color(0xFFD7DDE8), // Açık gri
  ];

  // Kart renkleri (glassmorphism efekti için)
  static const cardLight = Color(0xCCFFFFFF); // %80 opacity beyaz
  static const cardDark = Color(0xCC1E1E1E); // %80 opacity siyah

  // Metin renkleri
  static const textLight = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2C3E50);
  static const textGrey = Color(0xFF7F8C8D);

  // İkon renkleri
  static const iconLight = Color(0xFFFFFFFF);
  static const iconDark = Color(0xFF34495E);

  /// Hava durumuna göre gradient döndüren yardımcı fonksiyon
  ///
  /// Parametreler:
  ///   condition: Hava durumu (örn: "Clear", "Rain", "Snow")
  ///   isDay: Gündüz mü gece mi (true = gündüz)
  ///
  /// Örnek kullanım:
  ///   List<Color> colors = AppColors.getWeatherGradient("Clear", true);
  static List<Color> getWeatherGradient(String condition, {bool isDay = true}) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return isDay ? clearDayGradient : clearNightGradient;
      case 'clouds':
      case 'cloudy':
        return cloudsGradient;
      case 'rain':
      case 'drizzle':
        return rainGradient;
      case 'snow':
        return snowGradient;
      case 'thunderstorm':
      case 'storm':
        return stormGradient;
      case 'mist':
      case 'fog':
      case 'haze':
        return mistGradient;
      default:
        return isDay ? clearDayGradient : clearNightGradient;
    }
  }
}

/// Metin stilleri için constant değerler
///
/// Öğrenci Notu: TextStyle'ları merkezi bir yerden yönetmek,
/// tutarlı bir tasarım dili oluşturmanızı sağlar
class AppTextStyles {
  // Başlıklar
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Gövde metinleri
  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textGrey,
  );

  // Özel stiller
  static const temperatureMassive = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w200, // Extra thin
    color: AppColors.textLight,
    height: 1.0,
  );

  static const temperatureLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: AppColors.textLight,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textGrey,
  );
}

/// Widget boyutları ve padding değerleri
///
/// Öğrenci Notu: Sabit padding ve margin değerleri kullanmak,
/// tasarımınızın tutarlı olmasını sağlar
class AppDimens {
  // Padding değerleri
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius değerleri
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusCircular = 50.0;

  // İkon boyutları
  static const double iconSmall = 20.0;
  static const double iconMedium = 32.0;
  static const double iconLarge = 48.0;
  static const double iconXLarge = 80.0;
  static const double iconHuge = 120.0; // Çok büyük ikonlar için

  // Kart boyutları
  static const double cardHeight = 120.0;
  static const double cardElevation = 4.0;
}
