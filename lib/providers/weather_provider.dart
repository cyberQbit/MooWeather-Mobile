// lib/providers/weather_provider.dart

// Tüm state yönetimi ve servis sağlayıcılarımı burada topluyorum.
// Not: Riverpod ile state yönetimi, test edilebilirlik ve kodun okunabilirliği için çok avantajlı.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/weather_exceptions.dart';
import '../services/weather_service.dart';

// WeatherService'i sağlayan provider. Tüm servis çağrıları buradan yapılır.
final weatherServiceProvider =
    Provider<WeatherService>((ref) => WeatherService());

// Hava durumu state'ini yöneten ana Notifier sınıfım.
// Not: AutoDisposeAsyncNotifier ile hem asenkron veri çekiyorum hem de gereksiz state'leri dispose ediyorum.
class WeatherNotifier extends AutoDisposeAsyncNotifier<Weather?> {
  // Son kullanılan şehir adı (default: İstanbul)
  String currentCity = "İstanbul";

  @override
  Future<Weather?> build() {
    // Uygulama ilk açıldığında konuma göre hava durumu çek
    return fetchWeatherByCurrentLocation();
  }

  /// Kullanıcının mevcut konumuna göre hava durumu verisi çeker.
  Future<Weather?> fetchWeatherByCurrentLocation() async {
    state = const AsyncValue.loading(); // Yükleniyor durumuna al
    try {
      final weatherService = ref.read(weatherServiceProvider);
      // Konum izinlerini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        // Kullanıcı izin vermezse varsayılan şehirden devam et
        return fetchWeatherByCity(currentCity);
      }
      // Konumu al
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      // Konuma göre hava durumu çek
      final weather = await weatherService.getWeatherByCoordinates(
          position.latitude, position.longitude);
      state = AsyncValue.data(weather); // State'i güncelle
      currentCity = weather.cityName; // Son şehri güncelle
      return weather;
    } catch (e, stack) {
      debugPrint("Konum tabanlı hava durumu hatası: ${e.toString()}");

      // Kullanıcıya gösterilecek hata mesajı
      String errorMessage = 'Konum alınamadı, varsayılan şehir deneniyor...';
      if (e is WeatherException) {
        errorMessage = e.userFriendlyMessage;
      }

      state = AsyncValue.error(errorMessage, stack); // Hata durumunu güncelle
      return fetchWeatherByCity(currentCity); // Varsayılan şehirden devam et
    }
  }

  /// Şehir adına göre hava durumu verisi çeker.
  Future<Weather?> fetchWeatherByCity(String cityName) async {
    state = const AsyncValue.loading();
    try {
      final weatherService = ref.read(weatherServiceProvider);
      final weather = await weatherService.getWeather(cityName);
      state = AsyncValue.data(weather);
      currentCity = cityName;
      return weather;
    } catch (e, stack) {
      debugPrint("Şehir adına göre çekme hatası: ${e.toString()}");

      // Kullanıcı dostu hata mesajı
      String errorMessage = 'Veri çekilemedi. Lütfen tekrar deneyin.';
      if (e is WeatherException) {
        errorMessage = e.userFriendlyMessage;
      }

      state = AsyncValue.error(errorMessage, stack);
      return null;
    }
  }
}

// Global Provider Tanımı
final weatherProvider =
    AsyncNotifierProvider.autoDispose<WeatherNotifier, Weather?>(
  () => WeatherNotifier(),
);

final currentCityProvider = Provider<String>((ref) {
  final weatherState = ref.watch(weatherProvider);
  return weatherState.when(
    data: (weather) =>
        weather?.cityName ?? ref.read(weatherProvider.notifier).currentCity,
    error: (_, __) => ref.read(weatherProvider.notifier).currentCity,
    loading: () => ref.read(weatherProvider.notifier).currentCity,
  );
});
