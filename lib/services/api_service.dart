import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ApiService {
  static const String baseUrl = 'https://mooweather-api.onrender.com/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ÇOK DİLLİ VE ZIRHLI HAVA DURUMU GETİRİCİ
  Future<Map<String, dynamic>?> getWeather(
      {String? cityName, double? lat, double? lon, String lang = 'tr'}) async {
    try {
      String url = '';
      if (cityName != null) {
        url = '$baseUrl/weather/$cityName?lang=$lang';
      } else if (lat != null && lon != null) {
        url = '$baseUrl/weather/coord?lat=$lat&lon=$lon&lang=$lang';
      } else {
        return null;
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Hava durumu hatası: $e');
      return null;
    }
  }

  Future<List<dynamic>> getFavoriteCities() async {
    final token = await _getToken();

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/cities'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        );
        if (response.statusCode == 200) return jsonDecode(response.body);
      } catch (e) {
        debugPrint('Buluttan şehir çekilemedi: $e');
      }
      return [];
    } else {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('local_cities');
      if (localData != null) {
        return jsonDecode(localData);
      }
      return [];
    }
  }

  Future<bool> addCity(String name, String countryCode) async {
    final token = await _getToken();

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/cities'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'name': name, 'countryCode': countryCode}),
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (e) {
        return false;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('local_cities');
      List<dynamic> localCities =
          localData != null ? jsonDecode(localData) : [];
      localCities.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': name,
        'countryCode': countryCode
      });
      await prefs.setString('local_cities', jsonEncode(localCities));
      return true;
    }
  }

  Future<bool> removeCity(int id) async {
    final token = await _getToken();

    if (token != null) {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/cities/$id'),
          headers: {'Authorization': 'Bearer $token'},
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        return false;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('local_cities');
      if (localData == null) return false;

      List<dynamic> localCities = jsonDecode(localData);
      localCities.removeWhere((city) => city['id'] == id);
      await prefs.setString('local_cities', jsonEncode(localCities));
      return true;
    }
  }

  Future<void> syncLocalToCloud() async {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getString('local_cities');

    if (localData != null) {
      List<dynamic> localCities = jsonDecode(localData);
      for (var city in localCities) {
        await addCity(city['name'], city['countryCode']);
      }
      await prefs.remove('local_cities');
    }
  }
}
