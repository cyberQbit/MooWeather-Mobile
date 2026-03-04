import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Map<String, dynamic> cityData;

  const WeatherDetailScreen({super.key, required this.cityData});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // --- HAVA DURUMU MOTORU ---
  _WeatherTheme _getTheme(String? condition, {bool isDark = true}) {
    final c = (condition ?? '').toLowerCase();

    if (c.contains('kar') || c.contains('snow') || c.contains('nieve')) {
      return _WeatherTheme(
        gradients: isDark
            ? [
                const Color(0xFFB0C4DE),
                const Color(0xFF778899),
                const Color(0xFF4A6272)
              ]
            : [
                const Color(0xFF78909C),
                const Color(0xFF607D8B),
                const Color(0xFF455A64)
              ],
        cardColor: isDark
            ? Colors.white.withOpacity(0.18)
            : Colors.white.withOpacity(0.25),
        iconData: Icons.ac_unit_rounded,
        iconColor: isDark ? Colors.white : const Color(0xFFE3F2FD),
        accentColor: const Color(0xFF90CAF9),
      );
    }
    if (c.contains('fırtına') ||
        c.contains('gök gürültü') ||
        c.contains('thunder') ||
        c.contains('tormenta')) {
      return _WeatherTheme(
        gradients: isDark
            ? [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460)
              ]
            : [
                const Color(0xFF5C6BC0),
                const Color(0xFF3949AB),
                const Color(0xFF283593)
              ],
        cardColor: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.22),
        iconData: Icons.thunderstorm_rounded,
        iconColor: const Color(0xFFFFEB3B),
        accentColor: const Color(0xFFFFEB3B),
      );
    }
    if (c.contains('yağmur') ||
        c.contains('sağanak') ||
        c.contains('çise') ||
        c.contains('rain') ||
        c.contains('drizzle') ||
        c.contains('lluvia')) {
      return _WeatherTheme(
        gradients: isDark
            ? [
                const Color(0xFF1B2631),
                const Color(0xFF2C3E50),
                const Color(0xFF34495E)
              ]
            : [
                const Color(0xFF1E88E5),
                const Color(0xFF1565C0),
                const Color(0xFF0D47A1)
              ],
        cardColor: isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.white.withOpacity(0.22),
        iconData: Icons.umbrella_rounded,
        iconColor: const Color(0xFF90CAF9),
        accentColor: const Color(0xFF64B5F6),
      );
    }
    if (c.contains('sis') ||
        c.contains('pus') ||
        c.contains('duman') ||
        c.contains('fog') ||
        c.contains('mist') ||
        c.contains('niebla')) {
      return _WeatherTheme(
        gradients: isDark
            ? [
                const Color(0xFF485563),
                const Color(0xFF29323C),
                const Color(0xFF1E2228)
              ]
            : [
                const Color(0xFF78909C),
                const Color(0xFF607D8B),
                const Color(0xFF455A64)
              ],
        cardColor: isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.22),
        iconData: Icons.foggy,
        iconColor: Colors.white60,
        accentColor: Colors.white60,
      );
    }
    if (c.contains('parçalı') ||
        c.contains('az bulutlu') ||
        c.contains('few') ||
        c.contains('scattered') ||
        c.contains('broken') ||
        c.contains('dispersas')) {
      return _WeatherTheme(
        gradients: isDark
            ? [
                const Color(0xFF1A3A5C),
                const Color(0xFF1E5B8A),
                const Color(0xFF2980B9)
              ]
            : [
                const Color(0xFF42A5F5),
                const Color(0xFF1E88E5),
                const Color(0xFF1565C0)
              ],
        cardColor: isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.22),
        iconData: Icons.cloud_queue_rounded,
        iconColor: Colors.white,
        accentColor: const Color(0xFF81D4FA),
      );
    }
    if (c.contains('bulut') ||
        c.contains('kapalı') ||
        c.contains('cloud') ||
        c.contains('overcast') ||
        c.contains('nublado') ||
        c.contains('nubes')) {
      return _WeatherTheme(
        gradients: isDark
            ? [
                const Color(0xFF373B44),
                const Color(0xFF4286F4),
                const Color(0xFF373B44)
              ]
            : [
                const Color(0xFF5C7AEA),
                const Color(0xFF3D5BE0),
                const Color(0xFF2545CC)
              ],
        cardColor: isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.white.withOpacity(0.22),
        iconData: Icons.cloud_rounded,
        iconColor: Colors.white70,
        accentColor: Colors.white70,
      );
    }
    // Default: açık / güneşli
    return _WeatherTheme(
      gradients: isDark
          ? [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364)
            ]
          : [
              const Color(0xFF4FC3F7),
              const Color(0xFF039BE5),
              const Color(0xFF0277BD)
            ],
      cardColor: isDark
          ? Colors.white.withOpacity(0.10)
          : Colors.white.withOpacity(0.22),
      iconData: Icons.wb_sunny_rounded,
      iconColor: const Color(0xFFFFD700),
      accentColor: const Color(0xFFFFD700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.cityData;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = _getTheme(data['condition'], isDark: isDark);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isFahrenheit = themeProvider.tempUnit == 'F';

    // Sıcaklık dönüştürür (string Celsius → gösterim string)
    String cvt(String? s) {
      if (s == null || s == '--') return '--';
      if (isFahrenheit) {
        try {
          return (double.parse(s) * 9 / 5 + 32).round().toString();
        } catch (_) {}
      }
      return s;
    }

    final size = MediaQuery.of(context).size;
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('d MMMM y', 'tr_TR').format(now);

    final String temp = cvt(data['temp']?.toString());
    final String high = cvt(data['high']?.toString());
    final String low = cvt(data['low']?.toString());
    // Ham Celsius değerleri (tahmin motoru için)
    final String rawTemp = data['temp']?.toString() ?? '--';
    final String rawHigh = data['high']?.toString() ?? '--';
    final String rawLow = data['low']?.toString() ?? '--';
    final String desc = (data['desc'] ?? '').toString().toUpperCase();
    final String name = data['name']?.toString() ?? '';
    final String humidity = data['humidity']?.toString() ?? '--';
    final String wind = data['wind']?.toString() ?? '--';
    final String visibility = data['visibility']?.toString() ?? '--';
    final String pressure = data['pressure']?.toString() ?? '--';
    final String clouds = data['clouds']?.toString() ?? '--';
    final String uvi = data['uvi']?.toString() ?? '--';
    final String rainProb = data['rain_prob']?.toString() ?? '0';
    final String sunriseUnix = data['sunrise']?.toString() ?? '--';
    final String sunsetUnix = data['sunset']?.toString() ?? '--';

    // Gün doğumu ve batımı saatlerini formatöyle
    String _formatUnixTime(String unix) {
      if (unix == '--') return '--';
      try {
        final ts = int.parse(unix);
        final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: false);
        return DateFormat('HH:mm').format(dt);
      } catch (_) {
        return '--';
      }
    }

    final String sunriseStr = _formatUnixTime(sunriseUnix);
    final String sunsetStr = _formatUnixTime(sunsetUnix);

    // Hissedilen sıcaklık: önce API değerini kullan, yoksa hesapla
    int? feelsLike;
    final String? apiFeelsStr = data['feels_like']?.toString();
    if (apiFeelsStr != null && apiFeelsStr != '--') {
      try {
        final rawC = double.parse(apiFeelsStr);
        feelsLike = isFahrenheit ? (rawC * 9 / 5 + 32).round() : rawC.round();
      } catch (_) {}
    }
    if (feelsLike == null) {
      try {
        final rawC = double.parse(data['temp']?.toString() ?? '');
        final w = double.tryParse(wind) ?? 10;
        final feelsC = rawC - (w * 0.08);
        feelsLike =
            isFahrenheit ? (feelsC * 9 / 5 + 32).round() : feelsC.round();
      } catch (_) {}
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
            ),
            Text(
              '$timeStr   •   $dateStr',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ARKA PLAN GRADYENİ
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.gradients,
              ),
            ),
          ),
          // Dekoratif daireler
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor.withOpacity(0.07),
              ),
            ),
          ),
          // İÇERİK
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // HERO
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: _buildHeroSection(theme, temp, desc, high, low),
                      ),

                      const SizedBox(height: 24),

                      // STATS GRID
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildStatsGrid(
                            theme, rainProb, wind, feelsLike, visibility),
                      ),

                      const SizedBox(height: 14),

                      // NEM ÇUBUĞU + METRİKLER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildMetricsCard(
                            theme, humidity, pressure, clouds, uvi),
                      ),

                      const SizedBox(height: 14),

                      // SAATLIK TAHMİN
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child:
                            _buildHourlySection(theme, rawTemp, isFahrenheit),
                      ),

                      const SizedBox(height: 14),

                      // HAFTALIK TAHMİN
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildWeeklySection(
                            theme, rawHigh, rawLow, isFahrenheit),
                      ),

                      const SizedBox(height: 14),

                      // GÜN DOĞUMU / BATIMI
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSunCard(theme, sunriseStr, sunsetStr),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HERO BÖLÜMÜ
  // ================================================================
  Widget _buildHeroSection(
      _WeatherTheme t, String temp, String desc, String high, String low) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _iconController,
          builder: (_, __) => Transform.translate(
            offset:
                Offset(0, math.sin(_iconController.value * math.pi * 2) * 8),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: t.iconColor.withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 10)
                ],
              ),
              child: Icon(t.iconData, size: 130, color: t.iconColor),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$temp°',
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            height: 1.0,
            shadows: [Shadow(color: Colors.black26, blurRadius: 20)],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: t.accentColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: t.accentColor.withOpacity(0.4)),
          ),
          child: Text(
            desc,
            style: TextStyle(
                fontSize: 12,
                color: t.accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tempBadge(
                Icons.arrow_upward_rounded, high, Colors.redAccent.shade100),
            const SizedBox(width: 20),
            _tempBadge(Icons.arrow_downward_rounded, low,
                Colors.lightBlueAccent.shade100),
          ],
        ),
      ],
    );
  }

  Widget _tempBadge(IconData icon, String val, Color color) => Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text('$val°',
              style: TextStyle(
                  fontSize: 16, color: color, fontWeight: FontWeight.w600)),
        ],
      );

  // ================================================================
  // STATS GRID (2x2)
  // ================================================================
  Widget _buildStatsGrid(_WeatherTheme t, String rainProb, String wind,
      int? feelsLike, String visibility) {
    // Görüş kalitesi etiketi
    String _visLabel(int km) {
      if (km >= 10) return 'Çok iyi';
      if (km >= 5) return 'Normal';
      if (km >= 2) return 'Düşük';
      return 'Zayıf';
    }

    final int visKm = int.tryParse(visibility) ?? 10;
    final int rainP = int.tryParse(rainProb) ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _statCard(
          t: t,
          icon: Icons.umbrella_rounded,
          label: 'Yağmur İhtimali',
          value: '%$rainP',
          sub: rainP < 20
              ? 'Düşük'
              : rainP < 50
                  ? 'Orta'
                  : rainP < 80
                      ? 'Yüksek'
                      : 'Çok Yüksek',
          color: const Color(0xFF64B5F6),
        ),
        _statCard(
          t: t,
          icon: Icons.air_rounded,
          label: 'Rüzgar',
          value: wind != '--' ? '$wind km/s' : '--',
          sub: wind != '--' ? _windLabel(int.tryParse(wind) ?? 10) : '',
          color: const Color(0xFF80CBC4),
        ),
        _statCard(
          t: t,
          icon: Icons.thermostat_rounded,
          label: 'Hissedilen',
          value: feelsLike != null ? '$feelsLike°' : '--',
          sub: feelsLike != null
              ? (feelsLike < 0
                  ? 'Dondurucu'
                  : feelsLike < 10
                      ? 'Soğuk'
                      : feelsLike < 20
                          ? 'Serin'
                          : feelsLike < 30
                              ? 'Ilık'
                              : 'Sıcak')
              : '',
          color: const Color(0xFFFFB74D),
        ),
        _statCard(
          t: t,
          icon: Icons.visibility_rounded,
          label: 'Görüş',
          value: visibility != '--' ? '$visKm km' : '--',
          sub: visibility != '--' ? _visLabel(visKm) : '',
          color: const Color(0xFFCE93D8),
        ),
      ],
    );
  }

  Widget _statCard({
    required _WeatherTheme t,
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 15),
                  ),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.1)),
                  if (sub.isNotEmpty)
                    Text(sub,
                        style: TextStyle(
                            color: color.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // METRİKLER KARTI
  // ================================================================
  Widget _buildMetricsCard(_WeatherTheme t, String humidity, String pressure,
      String clouds, String uvi) {
    final h = int.tryParse(humidity) ?? 60;
    // UV indeksi etiketi
    String _uviLabel(String uviStr) {
      final u = double.tryParse(uviStr) ?? 0;
      if (u <= 2) return 'İyi';
      if (u <= 5) return 'Orta';
      if (u <= 7) return 'Yüksek';
      if (u <= 10) return 'Çok Yüksek';
      return 'Aşırı';
    }

    final String basincVal = pressure != '--' ? '$pressure hPa' : '--';
    final String bulutVal = clouds != '--' ? '%$clouds' : '--';
    final String uviVal = uvi != '--' ? '$uvi (${_uviLabel(uvi)})' : '--';
    return _glassCard(
      t: t,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: const Color(0xFF64B5F6), size: 14),
              const SizedBox(width: 6),
              const Text('Nem Oranı',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
              const Spacer(),
              Text('$h%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: h / 100,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                h < 40
                    ? Colors.orange
                    : h < 70
                        ? const Color(0xFF64B5F6)
                        : const Color(0xFF1976D2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricPill(Icons.compress_rounded, 'Basınç', basincVal,
                  const Color(0xFFFFCC02)),
              _metricPill(Icons.cloud_done_outlined, 'Bulutluluk', bulutVal,
                  const Color(0xFF80CBC4)),
              _metricPill(Icons.wb_twilight_rounded, 'UV', uviVal,
                  const Color(0xFFFFB74D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricPill(IconData icon, String label, String val, Color color) =>
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      );

  // ================================================================
  // TAHMİN MOTORU — Gerçekçi varyasyon üretici
  // ================================================================

  /// Hava kodundan ikon + renk üretir
  _ForecastSlot _conditionToSlot(int condCode, int temp) {
    switch (condCode) {
      case 0: // Açık gündüz
        return _ForecastSlot(
            Icons.wb_sunny_rounded, const Color(0xFFFFD700), temp);
      case 1: // Gece açık
        return _ForecastSlot(
            Icons.nights_stay_rounded, const Color(0xFFBBDEFB), temp);
      case 2: // Az bulutlu
        return _ForecastSlot(Icons.cloud_queue_rounded, Colors.white70, temp);
      case 3: // Gece az bulutlu
        return _ForecastSlot(
            Icons.cloud_queue_rounded, Colors.blueGrey.shade200, temp);
      case 4: // Parçalı bulutlu
        return _ForecastSlot(Icons.wb_cloudy_rounded, Colors.white60, temp);
      case 5: // Çok bulutlu
        return _ForecastSlot(Icons.cloud_rounded, Colors.grey.shade400, temp);
      case 6: // Çise
        return _ForecastSlot(
            Icons.grain_rounded, const Color(0xFF90CAF9), temp);
      case 7: // Yağmur
        return _ForecastSlot(
            Icons.umbrella_rounded, const Color(0xFF64B5F6), temp);
      case 8: // Sağanak
        return _ForecastSlot(
            Icons.thunderstorm_rounded, const Color(0xFFFFEB3B), temp);
      case 9: // Kar
        return _ForecastSlot(
            Icons.ac_unit_rounded, const Color(0xFFE3F2FD), temp);
      default:
        return _ForecastSlot(
            Icons.wb_sunny_rounded, const Color(0xFFFFD700), temp);
    }
  }

  /// Mevcut duruma göre gerçekçi tahmin koşulu üretir
  int _forecastCondCode({
    required int hour,
    required int dayOffset,
    required int seed,
    required String currentCond,
  }) {
    final bool isNight = hour >= 21 || hour <= 5;
    final bool isEarlyMorning = hour >= 6 && hour <= 8;
    final bool isAfternoon = hour >= 11 && hour <= 16;

    final c = currentCond.toLowerCase();
    final bool isCloudy = c.contains('bulut') ||
        c.contains('cloud') ||
        c.contains('overcast') ||
        c.contains('nublado');
    final bool isRainy = c.contains('yağmur') ||
        c.contains('rain') ||
        c.contains('drizzle') ||
        c.contains('lluvia');
    final bool isSnowy =
        c.contains('karl') || c.contains('snow') || c.contains('nieve');
    final bool isThunder = c.contains('fırtına') ||
        c.contains('thunder') ||
        c.contains('tormenta');
    final bool isFoggy =
        c.contains('sis') || c.contains('fog') || c.contains('mist');

    // Deterministik ama gün + saat bazlı varyasyon
    final r = (seed.abs() + hour * 13 + dayOffset * 31) % 10;

    if (isSnowy) return 9; // Kar: değişmez
    if (isThunder) {
      if (r < 3) return 8; // sağanak
      if (r < 6) return 7; // yağmur
      return 8; // hala fırtına
    }
    if (isFoggy) {
      if (r < 5) return 5; // kapalı bulutlu
      return 4; // parçalı
    }
    if (isRainy) {
      if (isNight) return r < 5 ? 7 : 5;
      if (r < 2) return 8;
      if (r < 5) return 7;
      if (r < 8) return 6;
      return 4; // ara sıra açılır
    }
    if (isCloudy) {
      if (isNight) return r < 6 ? 5 : 3;
      if (r < 2) return 7; // ara yağmur
      if (r < 5) return 5;
      if (r < 8) return 4;
      return 2; // az bulut
    }
    // Açık / güneşli için: gece ay, sabah yarı bulutlu, öğle güneş
    if (isNight) return r < 7 ? 1 : 3; // gece açık ya da gece az bulutlu
    if (isEarlyMorning) return r < 5 ? 0 : 2; // sabah güneş ya da az bulut
    if (isAfternoon) return r < 8 ? 0 : 2; // öğle çoğunlukla güneş
    if (r < 6) return 0; // açık
    if (r < 8) return 2; // az bulut
    return 4; // parçalı
  }

  List<_ForecastSlot> _generateHourlySlots(String baseTemp, String condition) {
    final now = DateTime.now();
    final baseT = int.tryParse(baseTemp) ?? 10;
    final seed = (widget.cityData['name'] ?? 'city').hashCode;
    final tempPattern = [0, -1, -1, -2, -3, -2, -1, 0]; // gece soğuk

    return List.generate(8, (i) {
      final hour = (now.hour + i) % 24;
      final condCode = _forecastCondCode(
          hour: hour, dayOffset: 0, seed: seed + i, currentCond: condition);
      return _conditionToSlot(condCode, baseT + tempPattern[i]);
    });
  }

  List<_ForecastSlot> _generateWeeklySlots(
      String high, String low, String condition) {
    final highT = int.tryParse(high) ?? 12;
    final lowT = int.tryParse(low) ?? 4;
    final seed = (widget.cityData['name'] ?? 'city').hashCode;
    // Haftalık sıcaklık trendleri: belirgin iniş çıkışlar
    final highOffsets = [2, 4, 3, 1, -1, -2, 1];
    final lowOffsets = [1, 2, 2, 0, -1, -2, 0];

    return List.generate(7, (i) {
      // Günlük hava en sıcak saatte belirle (14:00)
      final condCode = _forecastCondCode(
          hour: 14,
          dayOffset: i + 1,
          seed: seed + i * 37,
          currentCond: condition);
      final h = highT + highOffsets[i];
      final l = lowT + lowOffsets[i];
      return _conditionToSlot(condCode, h) // high temp
        ..low = l;
    });
  }

  // ================================================================
  // SAATLIK TAHMİN
  // ================================================================
  Widget _buildHourlySection(
      _WeatherTheme t, String baseTemp, bool isFahrenheit) {
    final now = DateTime.now();
    final slots =
        _generateHourlySlots(baseTemp, widget.cityData['condition'] ?? '');

    String showT(int celsius) {
      if (isFahrenheit) return '${(celsius * 9 / 5 + 32).round()}';
      return '$celsius';
    }

    return _glassCard(
      t: t,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.access_time_rounded, 'SAATLIK TAHMİN'),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(slots.length, (i) {
                final slot = slots[i];
                final hour =
                    DateTime(now.year, now.month, now.day, now.hour + i);
                final bool isNow = i == 0;
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isNow
                        ? t.accentColor.withOpacity(0.22)
                        : Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNow
                          ? t.accentColor.withOpacity(0.6)
                          : Colors.white.withOpacity(0.10),
                      width: isNow ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isNow ? 'Şimdi' : DateFormat('HH:mm').format(hour),
                        style: TextStyle(
                          color: isNow ? t.accentColor : Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(slot.icon, color: slot.iconColor, size: 22),
                      const SizedBox(height: 8),
                      Text('${showT(slot.temp)}°',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HAFTALIK TAHMİN
  // ================================================================
  Widget _buildWeeklySection(
      _WeatherTheme t, String high, String low, bool isFahrenheit) {
    final now = DateTime.now();
    final highT = int.tryParse(high) ?? 12;
    final lowT = int.tryParse(low) ?? 4;
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final slots =
        _generateWeeklySlots(high, low, widget.cityData['condition'] ?? '');

    String dayName(int i) {
      final d = now.add(Duration(days: i + 1));
      return days[d.weekday - 1];
    }

    String showT(int celsius) {
      if (isFahrenheit) return '${(celsius * 9 / 5 + 32).round()}';
      return '$celsius';
    }

    // Tüm günlerin max ve min sıcaklığını bul (progress bar için normalize)
    final allHighs = slots.map((s) => s.temp).toList();
    final allLows = slots.map((s) => s.low).toList();
    final maxH = allHighs.reduce(math.max);
    final minL = allLows.reduce(math.min);
    final range = (maxH - minL).toDouble().clamp(1.0, 100.0);

    return _glassCard(
      t: t,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.calendar_month_rounded, '7 GÜNLÜK TAHMİN'),
          const SizedBox(height: 10),
          ...List.generate(7, (i) {
            final slot = slots[i];
            final h = slot.temp;
            final l = slot.low;
            final barValue = ((h - minL).toDouble() / range).clamp(0.1, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      i == 0 ? 'Yarın' : dayName(i),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(slot.icon, color: slot.iconColor, size: 17),
                  const Spacer(),
                  Text('${showT(l)}°',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 75,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: barValue,
                        minHeight: 5,
                        backgroundColor: Colors.white.withOpacity(0.10),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          h <= lowT - 2
                              ? const Color(0xFF90CAF9)
                              : h >= highT + 2
                                  ? Colors.orangeAccent
                                  : t.accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${showT(h)}°',
                      style: TextStyle(
                          color: t.accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================================================================
  // GÜN DOĞUMU / BATIMI
  // ================================================================
  Widget _buildSunCard(_WeatherTheme t, String sunriseStr, String sunsetStr) {
    return _glassCard(
      t: t,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.wb_twilight_rounded, 'GÜN DOĞUMU & BATIMI'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.wb_sunny_outlined,
                        color: Colors.orangeAccent.shade100, size: 32),
                    const SizedBox(height: 8),
                    Text('Gün Doğumu',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(sunriseStr != '--' ? sunriseStr : '--',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 44,
                child: CustomPaint(
                    painter:
                        _SunArcPainter(progress: 0.58, color: t.accentColor)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.nights_stay_outlined,
                        color: Colors.blue.shade200, size: 32),
                    const SizedBox(height: 8),
                    Text('Gün Batımı',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(sunsetStr != '--' ? sunsetStr : '--',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // YARDIMCILAR
  // ================================================================
  Widget _glassCard({required _WeatherTheme t, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) => Row(
        children: [
          Icon(icon, color: Colors.white54, size: 13),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4)),
        ],
      );

  String _humidityLabel(int h) {
    if (h < 30) return 'Kuru';
    if (h < 60) return 'Normal';
    if (h < 80) return 'Nemli';
    return 'Çok Nemli';
  }

  String _windLabel(int w) {
    if (w < 5) return 'Sakin';
    if (w < 20) return 'Hafif';
    if (w < 40) return 'Orta';
    if (w < 60) return 'Kuvvetli';
    return 'Fırtına';
  }
}

// ================================================================
// FORECAST SLOT
// ================================================================
class _ForecastSlot {
  final IconData icon;
  final Color iconColor;
  final int temp;
  int low;

  _ForecastSlot(this.icon, this.iconColor, this.temp) : low = temp - 4;
}

// ================================================================
// TEMA SINIFI
// ================================================================
class _WeatherTheme {
  final List<Color> gradients;
  final Color cardColor;
  final IconData iconData;
  final Color iconColor;
  final Color accentColor;

  _WeatherTheme({
    required this.gradients,
    required this.cardColor,
    required this.iconData,
    required this.iconColor,
    required this.accentColor,
  });
}

// ================================================================
// GÜN ARK ÇİZERİ (CustomPainter)
// ================================================================
class _SunArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SunArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        math.pi, false, bgPaint);

    final progPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        math.pi * progress, false, progPaint);

    final angle = math.pi + math.pi * progress;
    final sunPos = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawCircle(sunPos, 5, Paint()..color = color);
    canvas.drawCircle(
        sunPos,
        5,
        Paint()
          ..color = color.withOpacity(0.35)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
