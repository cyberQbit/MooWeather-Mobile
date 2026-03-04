// lib/screens/weather_screen.dart
//
// Ana hava durumu ekranı.
// Not: Modern hava durumu uygulamalarındaki (AccuWeather, Google Weather vb.) tasarım prensiplerini burada uyguluyorum.
// - Gradient arka plan (hava durumuna göre dinamik)
// - Glassmorphism (yarı saydam, bulanık kartlar)
// - Pull-to-refresh (aşağı çekerek yenile)
// - Smooth animations (yumuşak geçişler)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'search_screen.dart';
import '../constants/app_colors.dart';
import '../widgets/weather_card.dart';
import '../widgets/loading_shimmer.dart';
import '../utils/weather_translator.dart';

/// Ana hava durumu ekranı (Riverpod ile state yönetimi)
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hata durumunda kullanıcıya SnackBar ile bildirim gösteriyorum
    ref.listen<AsyncValue<Weather?>>(weatherProvider, (previous, current) {
      if (current.hasError && !current.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Veri çekilemedi. Hata: ${current.error.toString().split(':')[0]}',
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              ),
            ),
          );
        });
      }
    });

    // Hava durumu state'ini izliyorum
    final weatherAsyncValue = ref.watch(weatherProvider);

    return Scaffold(
      // Arka planı gradient ile boyuyorum (hava durumuna göre dinamik renkler)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getWeatherGradient(weatherAsyncValue.value?.mainCondition),
          ),
        ),
        // RefreshIndicator: Aşağı çekerek yenile özelliği
        // Öğrenci Notu: Modern uygulamalarda standart bir UX pattern'dir
        child: RefreshIndicator(
          onRefresh: () async {
            // Yeni veri çek
            await ref
                .read(weatherProvider.notifier)
                .fetchWeatherByCurrentLocation();
          },
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            // Slivers: ScrollView içinde özel layout'lar için kullanılır
            slivers: [
              // AppBar (üst menü)
              _buildAppBar(context, ref),

              // Ana içerik
              SliverToBoxAdapter(
                child: weatherAsyncValue.when(
                  // Veri başarıyla yüklendi
                  data: (weather) {
                    if (weather == null) {
                      return _buildErrorState(
                        'Veri yüklenemedi. Lütfen tekrar deneyin veya farklı bir şehir arayın.',
                      );
                    }
                    return _buildWeatherContent(weather);
                  },
                  // Yükleniyor
                  loading: () =>
                      const SizedBox(height: 600, child: LoadingShimmer()),
                  // Hata oluştu
                  error: (err, stack) {
                    return _buildErrorState(
                      'Veri yüklenemedi. Lütfen tekrar deneyin veya farklı bir şehir arayın.',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar widget'ı (üst menü çubuğu)
  ///
  /// Öğrenci Notu: SliverAppBar, scroll edildiğinde küçülebilen bir AppBar'dır
  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true, // Scroll yukarı hareket ettiğinde tekrar görünür
      snap: true, // Hızlıca geri gelir
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          ref.watch(currentCityProvider),
          style: AppTextStyles.heading2,
        ),
      ),
      actions: [
        // Yenile butonu
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Yenile',
          onPressed: () {
            ref.read(weatherProvider.notifier).fetchWeatherByCurrentLocation();
          },
        ),
        // Arama butonu
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white),
          tooltip: 'Şehir Ara',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
            // Kullanıcı şehir seçtiyse, o şehrin havasını çek
            if (result != null && result is String && result.isNotEmpty) {
              ref.read(weatherProvider.notifier).fetchWeatherByCity(result);
            }
          },
        ),
      ],
    );
  }

  /// Ana içerik (hava durumu bilgileri)
  Widget _buildWeatherContent(Weather weather) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppDimens.paddingMedium),

          // Ana hava durumu kartı (büyük sıcaklık ve ikon)
          _buildMainWeatherCard(weather),

          const SizedBox(height: AppDimens.paddingXLarge),

          // Detaylı bilgi kartları (nem, rüzgar, basınç, hissedilen)
          _buildDetailedInfoGrid(weather),

          const SizedBox(height: AppDimens.paddingXLarge),

          // Saatlik tahmin (yatay scroll)
          if (weather.hourlyForecasts.isNotEmpty)
            _buildHourlyForecast(weather.hourlyForecasts),

          const SizedBox(height: AppDimens.paddingXLarge),

          // 7 günlük tahmin
          if (weather.dailyForecasts.isNotEmpty)
            _buildDailyForecast(weather.dailyForecasts),

          const SizedBox(height: AppDimens.paddingXLarge),
        ],
      ),
    );
  }

  /// Büyük sıcaklık kartı (hero section)
  Widget _buildMainWeatherCard(Weather weather) {
    return WeatherCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.paddingXLarge,
        horizontal: AppDimens.paddingLarge,
      ),
      child: Column(
        children: [
          // Hava durumu ikonu
          _buildWeatherIcon(weather.mainCondition, AppDimens.iconHuge),

          const SizedBox(height: AppDimens.paddingMedium),

          // Büyük sıcaklık
          Text(
            '${weather.temperature.toStringAsFixed(0)}°',
            style: AppTextStyles.temperatureMassive,
          ),

          const SizedBox(height: AppDimens.paddingSmall),

          // Hava durumu açıklaması (Türkçe)
          Text(
            WeatherTranslator.translateAndCapitalize(weather.mainCondition),
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: AppDimens.paddingSmall),

          // Şehir adı
          Text(
            weather.cityName,
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Detaylı bilgi grid'i (2x2)
  ///
  /// Öğrenci Notu: GridView, elemanları grid (tablo) düzeninde gösterir
  Widget _buildDetailedInfoGrid(Weather weather) {
    return GridView.count(
      // shrinkWrap: GridView'in yüksekliğini içeriğe göre ayarla
      shrinkWrap: true,
      // physics: Scroll'u devre dışı bırak (üst scroll yeterli)
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, // 2 sütun
      mainAxisSpacing: AppDimens.paddingMedium,
      crossAxisSpacing: AppDimens.paddingMedium,
      childAspectRatio: 1.3, // Kart en/boy oranı
      children: [
        // Nem kartı
        InfoCard(
          icon: Icons.water_drop_rounded,
          title: 'Nem',
          value: weather.humidity.toStringAsFixed(0),
          unit: '%',
        ),
        // Rüzgar kartı
        InfoCard(
          icon: Icons.air_rounded,
          title: 'Rüzgar',
          value: weather.windSpeed.toStringAsFixed(1),
          unit: 'm/s',
        ),
        // Basınç kartı
        InfoCard(
          icon: Icons.compress_rounded,
          title: 'Basınç',
          value: weather.pressure.toStringAsFixed(0),
          unit: 'hPa',
        ),
        // Hissedilen sıcaklık kartı
        InfoCard(
          icon: Icons.thermostat_rounded,
          title: 'Hissedilen',
          value: weather.feelsLike.toStringAsFixed(0),
          unit: '°C',
        ),
      ],
    );
  }

  /// Saatlik tahmin listesi (yatay scroll)
  Widget _buildHourlyForecast(List<HourlyForecast> hourly) {
    // Sadece ilk 24 saati göster
    final displayList = hourly.length > 24 ? hourly.sublist(0, 24) : hourly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.paddingSmall),
          child: Text('Saatlik Tahmin', style: AppTextStyles.heading2),
        ),

        const SizedBox(height: AppDimens.paddingMedium),

        // Yatay kaydırılabilir liste
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final forecast = displayList[index];
              final time = DateTime.fromMillisecondsSinceEpoch(
                forecast.timeStamp * 1000,
              );

              return HourlyWeatherCard(
                time: '${time.hour}:00',
                temperature: '${forecast.temperature.toStringAsFixed(0)}°',
                weatherIcon: _getWeatherIconData(forecast.condition),
                condition: WeatherTranslator.translate(forecast.condition),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 7 günlük tahmin listesi
  Widget _buildDailyForecast(List<DailyForecast> daily) {
    // İlk günü (bugün) atla, sadece gelecek günleri göster
    final displayList = daily.length > 1 ? daily.sublist(1) : daily;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.paddingSmall),
          child: Text('7 Günlük Tahmin', style: AppTextStyles.heading2),
        ),

        const SizedBox(height: AppDimens.paddingMedium),

        // Günlük tahmin kartları
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final forecast = displayList[index];
            final date = DateTime.fromMillisecondsSinceEpoch(
              forecast.timeStamp * 1000,
            );

            // Gün adını Türkçe olarak al
            final dayName = _getDayName(date.weekday);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.paddingMedium),
              child: DailyWeatherCard(
                day: dayName,
                weatherIcon: _getWeatherIconData(forecast.condition),
                condition: WeatherTranslator.translateAndCapitalize(
                    forecast.condition),
                maxTemp: '${forecast.tempMax.toStringAsFixed(0)}°',
                minTemp: '${forecast.tempMin.toStringAsFixed(0)}°',
              ),
            );
          },
        ),
      ],
    );
  }

  /// Hata durumu ekranı
  Widget _buildErrorState(String message) {
    return SizedBox(
      height: 600,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hata ikonu
              Icon(
                Icons.error_outline_rounded,
                size: AppDimens.iconHuge,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              // Hata mesajı
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hava durumuna göre gradient renkleri döndürür
  ///
  /// Öğrenci Notu: Her hava durumu için farklı renkler kullanıyoruz
  /// Bu, kullanıcıya görsel bir ipucu verir
  List<Color> _getWeatherGradient(String? condition) {
    if (condition == null) return AppColors.cloudsGradient;

    switch (condition.toLowerCase()) {
      case 'clear':
        return AppColors.clearDayGradient;
      case 'clouds':
        return AppColors.cloudsGradient;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return AppColors.rainGradient;
      case 'thunderstorm':
        return AppColors.thunderstormGradient;
      case 'snow':
        return AppColors.snowGradient;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return AppColors.mistGradient;
      default:
        return AppColors.cloudsGradient;
    }
  }

  /// Hava durumu ikonu döndürür
  Widget _buildWeatherIcon(String? condition, double size) {
    return Icon(
      _getWeatherIconData(condition),
      size: size,
      color: AppColors.iconLight,
    );
  }

  /// Hava durumuna göre ikon türünü belirler
  ///
  /// Öğrenci Notu: Switch-case yapısı, if-else zincirinden daha okunabilir
  IconData _getWeatherIconData(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Icons.water_drop_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.cloud_rounded;
    }
  }

  /// Gün numarasına göre Türkçe gün adı döndürür
  ///
  /// Öğrenci Notu: DateTime.weekday 1-7 arası değer verir (Pazartesi=1)
  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }
}
