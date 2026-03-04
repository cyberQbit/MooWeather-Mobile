import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import 'weather_detail_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TextEditingController _cityController = TextEditingController();

  Map<String, dynamic>? _currentLocationWeather;
  List<Map<String, dynamic>> _favoriteCitiesWeather = [];
  List<String> _places = [];
  String _searchQuery = "";

  bool _isLoadingCurrent = true;
  bool _isLoadingFavorites = true;
  bool _isLoggedIn = false;

  // Autocomplete alanını dışarıdan temizlemek için referans
  TextEditingController? _autocompleteTextController;

  // Locale değişimini takip etmek için
  Locale? _lastLocale;
  String? _lastUnit;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _initData();
    _loadPlacesJson();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = context.locale;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final newUnit = themeProvider.tempUnit;

    if (_lastLocale != null && _lastLocale != newLocale) {
      _initData();
    }
    if (_lastUnit != null && _lastUnit != newUnit) {
      // Birim değişti, sadece ekranı yenile (veri aynı, gösterim değişir)
      setState(() {});
    }
    _lastLocale = newLocale;
    _lastUnit = newUnit;
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadPlacesJson() async {
    try {
      final String response = await rootBundle.loadString('assets/places.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _places = data.map((e) => e['name'].toString()).toList();
      });
    } catch (e) {
      debugPrint('JSON okuma hatası: $e');
    }
  }

  Future<void> _initData() async {
    await _fetchCurrentLocationWeather();
    await _loadFavoritesWeather();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('jwt_token') != null;
    });
  }

  // --- EVRENSEL HAVA DURUM ÇEVİRMENİ (TR / EN / ES) ---
  // API her zaman İngilizce döner; bu fonksiyon İngilizce + İspanyolca fallback destekler.
  String _translateConditionLocally(String condition) {
    final String lang = context.locale.languageCode;
    final String c = condition.toLowerCase();

    if (lang == 'tr') {
      // --- İngilizce eşleşmeler ---
      if (c.contains('thunderstorm')) return 'Fırtınalı';
      if (c.contains('drizzle')) return 'Çiseleyen';
      if (c.contains('rain')) return 'Yağmurlu';
      if (c.contains('snow') || c.contains('sleet') || c.contains('blizzard'))
        return 'Karlı';
      if (c.contains('mist') ||
          c.contains('fog') ||
          c.contains('haze') ||
          c.contains('smoke')) return 'Sisli';
      if (c.contains('overcast')) return 'Çok Bulutlu';
      if (c.contains('broken') || c.contains('scattered'))
        return 'Parçalı Bulutlu';
      if (c.contains('few clouds')) return 'Az Bulutlu';
      if (c.contains('cloud') || c.contains('clouds')) return 'Bulutlu';
      if (c.contains('clear') || c.contains('sunny')) return 'Açık';
      if (c.contains('wind') || c.contains('squall')) return 'Rüzgarlı';
      // --- İspanyolca fallback (bazen API ES dönebilir) ---
      if (c.contains('tormenta')) return 'Fırtınalı';
      if (c.contains('llovizna')) return 'Çiseleyen';
      if (c.contains('lluvia')) return 'Yağmurlu';
      if (c.contains('nieve')) return 'Karlı';
      if (c.contains('niebla') || c.contains('bruma')) return 'Sisli';
      if (c.contains('dispersas') || c.contains('parcialmente'))
        return 'Parçalı Bulutlu';
      if (c.contains('pocas nubes')) return 'Az Bulutlu';
      if (c.contains('nubes') || c.contains('nublado')) return 'Bulutlu';
      if (c.contains('despejado')) return 'Açık';
      if (c.contains('ventoso')) return 'Rüzgarlı';
    } else if (lang == 'es') {
      // --- İngilizce → İspanyolca ---
      if (c.contains('thunderstorm')) return 'Tormenta';
      if (c.contains('drizzle')) return 'Llovizna';
      if (c.contains('rain')) return 'Lluvia';
      if (c.contains('snow') || c.contains('sleet') || c.contains('blizzard'))
        return 'Nieve';
      if (c.contains('mist') ||
          c.contains('fog') ||
          c.contains('haze') ||
          c.contains('smoke')) return 'Niebla';
      if (c.contains('overcast')) return 'Nublado';
      if (c.contains('broken') || c.contains('scattered'))
        return 'Parcialmente Nublado';
      if (c.contains('few clouds')) return 'Pocas Nubes';
      if (c.contains('cloud') || c.contains('clouds')) return 'Nublado';
      if (c.contains('clear') || c.contains('sunny')) return 'Despejado';
      if (c.contains('wind') || c.contains('squall')) return 'Ventoso';
      // --- İspanyolca pass-through ---
      if (c.contains('tormenta')) return 'Tormenta';
      if (c.contains('llovizna')) return 'Llovizna';
      if (c.contains('lluvia')) return 'Lluvia';
      if (c.contains('nieve')) return 'Nieve';
      if (c.contains('niebla') || c.contains('bruma')) return 'Niebla';
      if (c.contains('dispersas') || c.contains('parcialmente'))
        return 'Parcialmente Nublado';
      if (c.contains('nubes') || c.contains('nublado')) return 'Nublado';
      if (c.contains('despejado')) return 'Despejado';
    } else {
      // EN
      if (c.contains('thunderstorm')) return 'Thunderstorm';
      if (c.contains('drizzle')) return 'Drizzle';
      if (c.contains('rain')) return 'Rainy';
      if (c.contains('snow')) return 'Snowy';
      if (c.contains('mist') || c.contains('fog')) return 'Foggy';
      if (c.contains('overcast')) return 'Overcast';
      if (c.contains('broken') || c.contains('scattered'))
        return 'Partly Cloudy';
      if (c.contains('cloud')) return 'Cloudy';
      if (c.contains('clear') || c.contains('sunny')) return 'Clear';
    }
    // Hiç eşleşme yoksa ilk harfi büyült
    return condition.isEmpty
        ? condition
        : condition[0].toUpperCase() + condition.substring(1);
  }

  Future<void> _fetchCurrentLocationWeather() async {
    setState(() => _isLoadingCurrent = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingCurrent = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingCurrent = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      String? currentCity = place.administrativeArea;
      if (currentCity == null || currentCity.isEmpty)
        currentCity = place.subAdministrativeArea;
      if (currentCity == null || currentCity.isEmpty)
        currentCity = place.locality;

      if (currentCity != null) {
        currentCity = currentCity
            .replaceAll(' Province', '')
            .replaceAll(' İli', '')
            .trim();
        // API'den her zaman İngilizce açıklama al; çeviriyi Flutter tarafında yapıyoruz
        final weatherData =
            await _apiService.getWeather(cityName: currentCity, lang: 'en');
        if (weatherData != null) {
          setState(() {
            _currentLocationWeather = _formatWeatherData(weatherData);
          });
        }
      }
    } catch (e) {
      debugPrint('Konum çekilemedi: $e');
    }
    setState(() => _isLoadingCurrent = false);
  }

  Future<void> _loadFavoritesWeather() async {
    setState(() => _isLoadingFavorites = true);
    final cities = await _apiService.getFavoriteCities();
    List<Map<String, dynamic>> tempCities = [];

    // API'den her zaman İngilizce açıklama al; çeviriyi Flutter tarafında yapıyoruz
    for (var city in cities) {
      final weatherData =
          await _apiService.getWeather(cityName: city['name'], lang: 'en');
      final formattedData = _formatWeatherData(weatherData);
      tempCities.add({
        ...formattedData,
        'name': city['name'],
        'id': city['id'],
      });
    }
    setState(() {
      _favoriteCitiesWeather = tempCities;
      _isLoadingFavorites = false;
    });
  }

  Map<String, dynamic> _formatWeatherData(Map<String, dynamic>? data) {
    String safeRound(dynamic value) {
      if (value == null) return '--';
      try {
        if (value is num) return value.round().toString();
        if (value is String) return double.parse(value).round().toString();
        return '--';
      } catch (e) {
        return '--';
      }
    }

    if (data == null || data['Temp'] == null) {
      return {
        'name': data?['Name'] ?? 'Bilinmiyor',
        'temp': '--',
        'desc': 'not_found'.tr(),
        'high': '--',
        'low': '--',
        'condition': 'Clear',
        'humidity': '--',
        'wind': '--',
        'feels_like': '--',
        'visibility': '--',
        'pressure': '--',
        'clouds': '--',
        'uvi': '--',
        'sunrise': '--',
        'sunset': '--',
        'rain_prob': '0',
      };
    }

    // Gelen açıklamayı kendi yerel motorumuzdan geçiriyoruz
    // API'den gelen tüm alan adlarını logla (eksik veri tespiti için)
    debugPrint('*** MOOWEATHER_DEBUG_START ***');
    debugPrint('RAW_KEYS: ${data.keys.toList()}');
    debugPrint('RAW_DATA: $data');
    debugPrint('*** MOOWEATHER_DEBUG_END ***');
    String rawDesc = data['Description']?.toString() ?? '';
    String translatedDesc = _translateConditionLocally(rawDesc);

    // Alan adı varyantlarını dene (backend PascalCase veya camelCase dönebilir)
    dynamic _pick(List<String> keys) {
      for (final k in keys) {
        if (data[k] != null) return data[k];
      }
      return null;
    }

    // Görünürlük, Yağmur ve diğer metrikleri OWM yapısına göre tara
    String visibilityKm = '--';
    String rainProb = '0';

    final finalVis =
        _pick(['Visibility', 'visibility', 'Vis', 'vis']) ?? data['visibility'];
    if (finalVis != null) {
      try {
        final vis = double.parse(finalVis.toString());
        visibilityKm =
            (vis > 100 ? (vis / 1000).round() : vis.round()).toString();
      } catch (_) {}
    }

    final finalPop =
        _pick(['Pop', 'pop', 'PrecipProbability', 'precipProbability']) ??
            data['pop'];
    if (finalPop != null) {
      try {
        final pop = double.parse(finalPop.toString());
        rainProb = (pop > 1 ? pop.round() : (pop * 100).round()).toString();
      } catch (_) {}
    } else {
      final rawRain = _pick(['Rain', 'rain', 'Precipitation']) ??
          (data['rain'] is Map
              ? (data['rain']['1h'] ?? data['rain']['3h'])
              : null);
      if (rawRain != null) rainProb = safeRound(rawRain);
    }

    final finalClouds =
        _pick(['Clouds', 'clouds', 'CloudCoverage', 'Cloudiness']) ??
            (data['clouds'] is Map ? data['clouds']['all'] : null);
    final finalUvi = _pick(['Uvi', 'uvi', 'UvIndex', 'UVIndex', 'UV', 'uv']);
    final finalSunrise =
        _pick(['Sunrise', 'sunrise', 'SunriseTime', 'SunRise']) ??
            (data['sys'] is Map ? data['sys']['sunrise'] : null);
    final finalSunset = _pick(['Sunset', 'sunset', 'SunsetTime', 'SunSet']) ??
        (data['sys'] is Map ? data['sys']['sunset'] : null);
    final finalPressure = _pick(['Pressure', 'pressure', 'Pres', 'pres']) ??
        (data['main'] is Map ? data['main']['pressure'] : null);
    final finalHumidity = _pick(['Humidity', 'humidity', 'Hum', 'hum']) ??
        (data['main'] is Map ? data['main']['humidity'] : null);
    final finalWind = _pick(['WindSpeed', 'windSpeed', 'Wind', 'wind']) ??
        (data['wind'] is Map ? data['wind']['speed'] : null);
    final finalFeels =
        _pick(['FeelsLike', 'feelsLike', 'Feelslike', 'ApparentTemp']) ??
            (data['main'] is Map ? data['main']['feels_like'] : null);

    return {
      'name': _pick(['Name', 'name', 'CityName', 'cityName'])?.toString() ??
          'Bilinmiyor',
      'temp': safeRound(_pick(['Temp', 'temp', 'Temperature', 'temperature']) ??
          (data['main'] is Map ? data['main']['temp'] : null)),
      'desc': translatedDesc,
      'high': safeRound(
          _pick(['TempMax', 'tempMax', 'MaxTemp', 'maxTemp', 'TempHigh']) ??
              (data['main'] is Map ? data['main']['temp_max'] : null)),
      'low': safeRound(
          _pick(['TempMin', 'tempMin', 'MinTemp', 'minTemp', 'TempLow']) ??
              (data['main'] is Map ? data['main']['temp_min'] : null)),
      'condition': translatedDesc,
      'humidity': finalHumidity?.toString() ?? '--',
      'wind': finalWind != null ? safeRound(finalWind) : '--',
      'feels_like': safeRound(finalFeels),
      'visibility': visibilityKm,
      'pressure': finalPressure?.toString() ?? '--',
      'clouds': finalClouds?.toString() ?? '--',
      'uvi': finalUvi?.toString() ?? '--',
      'sunrise': finalSunrise?.toString() ?? '--',
      'sunset': finalSunset?.toString() ?? '--',
      'rain_prob': rainProb,
    };
  }

  Future<void> _addCityFromSearch() async {
    String cityName = _searchQuery.trim();
    if (cityName.contains(',')) {
      cityName = cityName.split(',')[0].trim();
    }

    if (cityName.isEmpty) return;

    // Sadece places.json listesindeki şehirlerin eklenmesine izin ver
    final isValidCity = _places.any(
      (p) => p.toLowerCase() == cityName.toLowerCase(),
    );

    if (!isValidCity) {
      _autocompleteTextController?.clear();
      setState(() => _searchQuery = "");
      FocusScope.of(context).unfocus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.location_off_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '"$cityName" desteklenen şehirler listesinde bulunamadı.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final success = await _apiService.addCity(cityName, "TR");
    if (success) {
      if (!mounted) return;
      // Arama alanını sıfırla
      _autocompleteTextController?.clear();
      setState(() => _searchQuery = "");
      FocusScope.of(context).unfocus();
      await _loadFavoritesWeather();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            duration: const Duration(seconds: 3),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2C3E), Color(0xFF0F1E2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC02).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFCC02).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.add_location_alt_rounded,
                        color: Color(0xFFFFCC02), size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'success_added'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Color(0xFF2ECC71), size: 15),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  Future<void> _deleteCity(int id) async {
    final success = await _apiService.removeCity(id);
    if (success) {
      await _loadFavoritesWeather();
    }
  }

  void _navigateToDetail(Map<String, dynamic> cityData) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WeatherDetailScreen(cityData: cityData)),
    );
  }

  Future<void> _loginAndSync() async {
    if (mounted) Navigator.pop(context);
    try {
      final token = await _authService.signInWithGoogle();
      if (token != null) {
        await _apiService.syncLocalToCloud();
        await _checkLoginStatus();
        await _initData();
      }
    } catch (e) {
      debugPrint('Login hatası: $e');
    }
  }

  Future<void> _logout() async {
    if (mounted) Navigator.pop(context);
    await _authService.signOut();
    await _checkLoginStatus();
    await _initData();
  }

  // --- SICAKLIK BİRİM DÖNÜŞTURUCU ---
  String _displayTemp(String celsiusStr) {
    if (celsiusStr == '--') return '--';
    final unit = Provider.of<ThemeProvider>(context, listen: false).tempUnit;
    if (unit == 'F') {
      try {
        final c = double.parse(celsiusStr);
        return (c * 9 / 5 + 32).round().toString();
      } catch (_) {}
    }
    return celsiusStr;
  }

  // --- İKON MOTORU ---
  IconData _weatherIcon(String? condition) {
    final cond = (condition ?? '').toLowerCase();
    if (cond.contains('açık') ||
        cond.contains('güneşli') ||
        cond.contains('clear') ||
        cond.contains('claro') ||
        cond.contains('despejado')) return Icons.wb_sunny_rounded;
    if (cond.contains('parçalı') ||
        cond.contains('az bulutlu') ||
        cond.contains('few clouds') ||
        cond.contains('scattered') ||
        cond.contains('broken') ||
        cond.contains('nubes dispersas')) return Icons.cloud_queue_rounded;
    if (cond.contains('kapalı') ||
        cond.contains('çok bulutlu') ||
        cond.contains('bulut') ||
        cond.contains('cloud') ||
        cond.contains('overcast') ||
        cond.contains('nublado') ||
        cond.contains('nubes')) return Icons.cloud_rounded;
    if (cond.contains('yağmur') ||
        cond.contains('sağanak') ||
        cond.contains('çise') ||
        cond.contains('rain') ||
        cond.contains('drizzle') ||
        cond.contains('lluvia') ||
        cond.contains('llovizna')) return Icons.umbrella_rounded;
    if (cond.contains('fırtına') ||
        cond.contains('gök gürültülü') ||
        cond.contains('thunderstorm') ||
        cond.contains('tormenta')) return Icons.thunderstorm_rounded;
    if (cond.contains('kar') || cond.contains('snow') || cond.contains('nieve'))
      return Icons.ac_unit_rounded;
    if (cond.contains('sis') ||
        cond.contains('pus') ||
        cond.contains('duman') ||
        cond.contains('fog') ||
        cond.contains('mist') ||
        cond.contains('niebla') ||
        cond.contains('bruma')) return Icons.foggy;
    return Icons.wb_sunny_rounded;
  }

  Color _weatherIconColor(String? condition, {bool isDark = true}) {
    final cond = (condition ?? '').toLowerCase();
    if (cond.contains('açık') ||
        cond.contains('güneşli') ||
        cond.contains('clear') ||
        cond.contains('claro') ||
        cond.contains('despejado')) return Colors.amber;
    if (cond.contains('parçalı') ||
        cond.contains('az bulutlu') ||
        cond.contains('few clouds') ||
        cond.contains('scattered') ||
        cond.contains('broken') ||
        cond.contains('nubes dispersas'))
      return isDark ? Colors.white70 : const Color(0xFF78909C);
    if (cond.contains('kapalı') ||
        cond.contains('çok bulutlu') ||
        cond.contains('bulut') ||
        cond.contains('cloud') ||
        cond.contains('overcast') ||
        cond.contains('nublado') ||
        cond.contains('nubes'))
      return isDark ? Colors.grey : const Color(0xFF546E7A);
    if (cond.contains('yağmur') ||
        cond.contains('sağanak') ||
        cond.contains('çise') ||
        cond.contains('rain') ||
        cond.contains('drizzle') ||
        cond.contains('lluvia') ||
        cond.contains('llovizna')) return const Color(0xFF4FC3F7);
    if (cond.contains('fırtına') ||
        cond.contains('gök gürültülü') ||
        cond.contains('thunderstorm') ||
        cond.contains('tormenta')) return const Color(0xFFFFEB3B);
    if (cond.contains('kar') ||
        cond.contains('snow') ||
        cond.contains('nieve') ||
        cond.contains('sis') ||
        cond.contains('pus') ||
        cond.contains('fog') ||
        cond.contains('mist') ||
        cond.contains('niebla'))
      return isDark ? Colors.white : const Color(0xFF90A4AE);
    return Colors.amber;
  }

  Widget _buildGlassContainer(
      {required Widget child,
      EdgeInsetsGeometry? padding,
      bool isDark = true}) {
    if (isDark) {
      // KOYU TEMA: Klasik glassmorphism
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.white.withOpacity(0.13), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 24,
                    spreadRadius: -4),
              ],
            ),
            child: child,
          ),
        ),
      );
    } else {
      // AÇIK TEMA: Beyaz kart + yumuşak gölge (glassmorphism ışıkta kötü görünür)
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFDDE6F0), width: 1),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF4A7AB5).withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 6)),
            BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 6,
                offset: const Offset(0, -2)),
          ],
        ),
        child: child,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(DateTime.now());
    String formattedDate = DateFormat('d MMM yyyy').format(DateTime.now());

    // TEMA KONTROLLERİ
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // KOYU TEMA: Derin gece mavisi gradyeni
    const darkGradient = [
      Color(0xFF0A0F1E),
      Color(0xFF0F2027),
      Color(0xFF1A3045)
    ];
    // AÇIK TEMA: Sabah sisi hissi — üstte sıcak beyaz, altta soft mavi-gri
    const lightGradient = [
      Color(0xFFF5F8FC),
      Color(0xFFEBF2FA),
      Color(0xFFDCEBF7)
    ];

    final List<Color> bgGradient = isDark ? darkGradient : lightGradient;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2744);
    final Color subTextColor =
        isDark ? Colors.white60 : const Color(0xFF5A6B85);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildModernDrawer(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF1A2744)),
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 35, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MooWeather',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: textColor,
                        letterSpacing: 1.0)),
                Text('$formattedTime | $formattedDate',
                    style: TextStyle(
                        fontSize: 11, color: subTextColor, letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: bgGradient)),
          ),
          SafeArea(
            child: Column(
              children: [
                // ARAMA ÇUBUĞU
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: _buildGlassContainer(
                    isDark: isDark,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty || _places.isEmpty)
                          return const Iterable<String>.empty();
                        return _places.where((String option) => option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        _searchQuery = selection;
                        _addCityFromSearch();
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        // Controller referansını sakla (dışarıdan temizleyebilmek için)
                        _autocompleteTextController = textEditingController;
                        textEditingController.addListener(
                            () => _searchQuery = textEditingController.text);
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: TextStyle(color: textColor, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'search_hint'.tr(),
                            hintStyle:
                                TextStyle(color: subTextColor, fontSize: 14),
                            icon: Icon(Icons.search, color: subTextColor),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add_location_alt,
                                  color: Colors.amber, size: 28),
                              onPressed: () {
                                _addCityFromSearch();
                                textEditingController.clear();
                              },
                            ),
                          ),
                          onSubmitted: (_) {
                            _addCityFromSearch();
                            textEditingController.clear();
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1C2A3D)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black12),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(option,
                                        style: TextStyle(color: textColor)),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // LİSTELER
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.amber,
                    backgroundColor:
                        isDark ? const Color(0xFF1A2A35) : Colors.white,
                    onRefresh: _initData,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text('current_location'.tr(),
                              style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0)),
                        ),
                        _isLoadingCurrent
                            ? const SizedBox(
                                height: 150,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.amber)))
                            : _currentLocationWeather == null
                                ? _buildGlassContainer(
                                    isDark: isDark,
                                    child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Text("not_found".tr(),
                                            style: TextStyle(
                                                color: subTextColor))))
                                : _buildHeroWeatherCard(
                                    _currentLocationWeather!, isDark),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text('saved_locations'.tr(),
                              style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0)),
                        ),
                        _isLoadingFavorites
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.amber))
                            : _favoriteCitiesWeather.isEmpty
                                ? _buildGlassContainer(
                                    isDark: isDark,
                                    child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                            child: Text(
                                                "no_saved_location".tr(),
                                                style: TextStyle(
                                                    color: subTextColor)))))
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                      childAspectRatio:
                                          0.82, // Kutuların boyunu hafif uzattık ki taşma olmasın
                                    ),
                                    itemCount: _favoriteCitiesWeather.length,
                                    itemBuilder: (context, index) {
                                      final city =
                                          _favoriteCitiesWeather[index];
                                      return _buildGridGlassCard(city, isDark);
                                    },
                                  ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroWeatherCard(Map<String, dynamic> data, bool isDark) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2744);
    final Color subTextColor =
        isDark ? Colors.white70 : const Color(0xFF5A6B85);

    return GestureDetector(
      onTap: () => _navigateToDetail(data),
      child: _buildGlassContainer(
        isDark: isDark,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text(data['name'],
                        style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8)),
                  ],
                ),
                Expanded(
                  child: Text(
                    data['desc'].toString().toUpperCase(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: subTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_weatherIcon(data['condition']),
                        color: _weatherIconColor(data['condition']),
                        size: 56,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 16)
                        ]),
                    const SizedBox(width: 12),
                    Text('${_displayTemp(data['temp']?.toString() ?? '--')}°',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 70,
                            fontWeight: FontWeight.w200,
                            height: 1.0)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      Icon(Icons.arrow_upward, color: subTextColor, size: 16),
                      Text('${_displayTemp(data['high']?.toString() ?? '--')}°',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.arrow_downward, color: subTextColor, size: 16),
                      Text('${_displayTemp(data['low']?.toString() ?? '--')}°',
                          style: TextStyle(color: subTextColor, fontSize: 16)),
                    ]),
                    const SizedBox(height: 8),
                    if (data['humidity'] != '--')
                      Row(children: [
                        const Icon(Icons.water_drop_outlined,
                            color: Colors.lightBlueAccent, size: 14),
                        const SizedBox(width: 2),
                        Text('%${data['humidity']}',
                            style:
                                TextStyle(color: subTextColor, fontSize: 13)),
                      ]),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridGlassCard(Map<String, dynamic> data, bool isDark) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2744);
    final Color subTextColor =
        isDark ? Colors.white70 : const Color(0xFF5A6B85);

    return GestureDetector(
      onTap: () => _navigateToDetail(data),
      child: _buildGlassContainer(
        isDark: isDark,
        padding: const EdgeInsets.fromLTRB(
            16, 16, 8, 16), // Sağ padding'i kıstık buton için
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: 28.0), // Silme butonuna yer aç
                  child: Row(
                    children: [
                      const Icon(Icons.near_me, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(data['name'],
                            style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(_weatherIcon(data['condition']),
                        color: _weatherIconColor(data['condition'],
                            isDark: isDark),
                        size: 36,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 10)
                        ]),
                    Text('${_displayTemp(data['temp'])}°',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w300)),
                  ],
                ),
                const SizedBox(height: 8),

                // MÜKEMMEL TAŞMA ÖNLEYİCİ (ELLIPSIS)
                Text(
                  data['desc'].toString().toUpperCase(),
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Divider(
                    color: isDark ? Colors.white24 : const Color(0xFFDDE6F0),
                    height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Y: ${_displayTemp(data['high'])}°',
                        style: TextStyle(color: textColor, fontSize: 11)),
                    Text('D: ${_displayTemp(data['low'])}°',
                        style: TextStyle(color: subTextColor, fontSize: 11)),
                  ],
                ),
              ],
            ),
            Positioned(
              top: -12,
              right: -8,
              child: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                onPressed: () => _deleteCity(data['id']),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KUSURSUZ GÜNDÜZ/GECE UYUMLU ÇEKMECE ---
  Widget _buildModernDrawer(bool isDark) {
    final Color bgColor =
        isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF8FAFD);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2744);
    final Color subTextColor =
        isDark ? Colors.white54 : const Color(0xFF5A6B85);
    final Color dividerColor =
        isDark ? Colors.white12 : const Color(0xFFDDE6F0);

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 80),
                  const SizedBox(height: 16),
                  Text(_isLoggedIn ? 'member'.tr() : 'guest'.tr(),
                      style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_isLoggedIn ? 'sync_on'.tr() : 'sync_off'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subTextColor, fontSize: 12)),
                ],
              ),
            ),
            Divider(color: dividerColor, thickness: 1),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              leading:
                  Icon(Icons.settings_outlined, color: subTextColor, size: 26),
              title: Text('settings'.tr(),
                  style: TextStyle(color: textColor, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              leading: Icon(Icons.info_outline, color: subTextColor, size: 26),
              title: Text('about'.tr(),
                  style: TextStyle(color: textColor, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()));
              },
            ),
            const Spacer(),
            if (!_isLoggedIn)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loginAndSync,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_sync,
                            color: Colors.amber, size: 28),
                        const SizedBox(width: 20),
                        Text('login_register'.tr(),
                            style: TextStyle(color: textColor, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              )
            else
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    child: Row(
                      children: [
                        const Icon(Icons.logout,
                            color: Colors.redAccent, size: 28),
                        const SizedBox(width: 20),
                        Text('logout'.tr(),
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text('MooWeather v1.0.0',
                style: TextStyle(color: subTextColor, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
