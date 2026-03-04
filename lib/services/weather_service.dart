// lib/services/weather_service.dart

// Tüm hava durumu API işlemlerimi burada topluyorum.
// Not: Her fonksiyonun başına ve önemli bloklara açıklama ekliyorum, ilerde API yönetimini hızlıca kavrayabilmek için.

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../models/weather_model.dart';
import '../models/weather_exceptions.dart';

class WeatherService {
  // Logger: hata ayıklama ve log için kullanıyorum
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  /// .env dosyasından API anahtarlarını çeker
  static List<String> get _apiKeys {
    final keys = <String>[];
    for (int i = 1; i <= 4; i++) {
      final key = i == 1
          ? dotenv.env['OPENWEATHER_API_KEY']
          : dotenv.env['OPENWEATHER_API_KEY_' + i.toString()];
      if (key != null && key.isNotEmpty) keys.add(key);
    }
    return keys;
  }

  // API anahtarları arasında geçiş için index
  static int _currentKeyIndex = 0;

  /// Şu an kullanılan API anahtarı
  static String get _currentApiKey {
    final keys = _apiKeys;
    if (keys.isEmpty) throw InvalidApiKeyException();
    return keys[_currentKeyIndex % keys.length];
  }

  /// API anahtarını döngüsel olarak değiştirir (rate limit için)
  static void _rotateApiKey() {
    _currentKeyIndex++;
    if (kDebugMode)
      _logger.w('API Key rotated to #' +
          (_currentKeyIndex % _apiKeys.length + 1).toString());
  }

  // API endpoint sabitleri
  static const String CURRENT_WEATHER_BASE_URL =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String GEOCODING_BASE_URL =
      'https://api.openweathermap.org/geo/1.0/direct';

  // Son istek zamanı (rate limit için)
  DateTime? _lastRequestTime;

  /// API rate limitine takılmamak için istekler arası bekleme
  Future<void> _checkRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < const Duration(milliseconds: 1100)) {
        await Future.delayed(const Duration(milliseconds: 1100) - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// API'ye istek atar, hata olursa tekrar dener
  Future<http.Response> _makeRequest(Uri url, {int maxRetries = 3}) async {
    await _checkRateLimit();
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) _logger.i('API Request attempt ' + attempt.toString());
        final response =
            await http.get(url).timeout(const Duration(seconds: 10));
        if (kDebugMode)
          _logger.i('Response: ' + response.statusCode.toString());

        if (response.statusCode == 200) return response;

        if (response.statusCode == 429 &&
            _apiKeys.length > 1 &&
            attempt < maxRetries) {
          if (kDebugMode) _logger.w('API Limit! Rotating key...');
          _rotateApiKey();
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        switch (response.statusCode) {
          case 401:
          case 403:
            throw InvalidApiKeyException();
          case 404:
            throw CityNotFoundException('Unknown');
          case 429:
            throw ApiLimitExceededException();
          case >= 500:
            throw ServerException(response.statusCode);
          default:
            throw WeatherException(
                'HTTP ' + response.statusCode.toString(), 'Error');
        }
      } catch (e) {
        if (e is WeatherException) rethrow;
        if (attempt == maxRetries) throw NoInternetException();
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    throw NoInternetException();
  }

  Future<Map<String, double>?> _getCoordinatesFromCity(String cityName) async {
    try {
      final url = Uri.parse(GEOCODING_BASE_URL +
          '?q=' +
          cityName +
          '&limit=1&appid=' +
          _currentApiKey);
      final response = await _makeRequest(url);
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) return null;
      if (kDebugMode) _logger.i('City found: ' + jsonList[0]['name']);
      return {
        'lat': (jsonList[0]['lat'] as num).toDouble(),
        'lon': (jsonList[0]['lon'] as num).toDouble(),
      };
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw ParseException();
    }
  }

  Future<Weather> getWeatherByCoordinates(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(CURRENT_WEATHER_BASE_URL +
          '?lat=' +
          latitude.toString() +
          '&lon=' +
          longitude.toString() +
          '&units=metric&appid=' +
          _currentApiKey +
          '&lang=tr');
      final response = await _makeRequest(url);
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (kDebugMode) _logger.i('Weather data received: ' + json['name']);

      // Öğrenci Notu: API'den gelen current weather verisini
      // One Call API formatına dönüştürüyoruz
      final convertedJson = {
        'lat': (json['coord']['lat'] as num).toDouble(),
        'lon': (json['coord']['lon'] as num).toDouble(),
        'current': {
          'dt': json['dt'],
          'temp': (json['main']['temp'] as num).toDouble(),
          'humidity': (json['main']['humidity'] as num).toDouble(),
          'wind_speed': (json['wind']['speed'] as num).toDouble(),
          'pressure': (json['main']['pressure'] as num).toDouble(),
          'feels_like': (json['main']['feels_like'] as num).toDouble(),
          'weather': json['weather'],
        },
        'hourly': [],
        'daily': [],
        'fetched_city_name': json['name'],
      };
      return Weather.fromJson(convertedJson);
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw ParseException();
    }
  }

  Future<Weather> getWeather(String cityName) async {
    final coords = await _getCoordinatesFromCity(cityName);
    if (coords == null) throw CityNotFoundException(cityName);
    return getWeatherByCoordinates(coords['lat']!, coords['lon']!);
  }
}
