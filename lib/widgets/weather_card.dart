// lib/widgets/weather_card.dart

// Modern glassmorphism efektli hava durumu kartı widget'ım.
// Not: Yarı saydam, bulanık arka planlı kartlar ile modern bir UI elde ediyorum.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Ana hava durumu kartı (glassmorphism efektli)
class WeatherCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? height;
  final double? width;

  const WeatherCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        // Yarı saydam beyaz arka plan (glassmorphism)
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        // İnce beyaz border
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        // Hafif gölge efekti
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Küçük bilgi kartı (ör: nem, rüzgar, UV indeksi için)
// Not: Bu widget ile küçük bilgileri şık şekilde gösterebiliyorum.
/// standart bir format sağlar. DRY (Don't Repeat Yourself) prensibine uygundur
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? unit;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return WeatherCard(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // İkon
          Icon(
            icon,
            size: AppDimens.iconMedium,
            color: AppColors.iconLight,
          ),
          const SizedBox(height: AppDimens.paddingSmall),

          // Başlık
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.paddingXSmall),

          // Değer ve birim
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.heading2,
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Saatlik hava durumu kartı
///
/// Liste halinde gösterilen saatlik tahminler için
class HourlyWeatherCard extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData weatherIcon;
  final String condition;

  const HourlyWeatherCard({
    super.key,
    required this.time,
    required this.temperature,
    required this.weatherIcon,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppDimens.paddingSmall),
      child: WeatherCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingMedium,
          horizontal: AppDimens.paddingSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Saat
            Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: AppDimens.paddingSmall),

            // Hava durumu ikonu
            Icon(
              weatherIcon,
              size: AppDimens.iconMedium,
              color: AppColors.iconLight,
            ),

            const SizedBox(height: AppDimens.paddingSmall),

            // Sıcaklık
            Text(
              temperature,
              style: AppTextStyles.heading3,
            ),

            // Durum (isteğe bağlı, küçük fontla)
            if (condition.isNotEmpty)
              Text(
                condition,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

/// Günlük hava durumu kartı
///
/// 7 günlük tahmin için kullanılan kart
class DailyWeatherCard extends StatelessWidget {
  final String day;
  final IconData weatherIcon;
  final String condition;
  final String maxTemp;
  final String minTemp;

  const DailyWeatherCard({
    super.key,
    required this.day,
    required this.weatherIcon,
    required this.condition,
    required this.maxTemp,
    required this.minTemp,
  });

  @override
  Widget build(BuildContext context) {
    return WeatherCard(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol: Gün ve durum
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  condition,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Orta: İkon
          Icon(
            weatherIcon,
            size: AppDimens.iconMedium,
            color: AppColors.iconLight,
          ),

          const SizedBox(width: AppDimens.paddingMedium),

          // Sağ: Min/Max sıcaklık
          Row(
            children: [
              // Min sıcaklık (soluk)
              Text(
                minTemp,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              // Max sıcaklık (belirgin)
              Text(
                maxTemp,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
