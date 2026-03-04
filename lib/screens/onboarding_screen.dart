import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  int _currentPage = 0;
  bool _isLoading = false;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Future<void> _loginAndContinue() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.signInWithGoogle();
      if (token != null) {
        await _apiService.syncLocalToCloud();
        await _completeOnboarding();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aktif temayı kontrol et (Arka plan rengi için)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildLanguagePage(isDarkMode), // 1. Adım: Dil
                      _buildThemePage(isDarkMode),    // 2. Adım: Tema
                      _buildFinalPage(isDarkMode),    // 3. Adım: Giriş
                    ],
                  ),
                ),
                // İLERİ BUTONU VE NOKTALAR
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? Colors.amber : Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      _currentPage == 2
                          ? const SizedBox.shrink()
                          : TextButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: Text(
                                'next'.tr(), // ÇEVİRİ KULLANILDI
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.amber)),
            )
        ],
      ),
    );
  }

  // --- 1. ADIM: DİL SEÇİM EKRANI ---
  Widget _buildLanguagePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, size: 80, color: isDark ? Colors.white : Colors.black87),
          const SizedBox(height: 30),
          Text(
            'choose_lang'.tr(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _langCard('Türkçe', 'tr', 'TR', isDark),
          const SizedBox(height: 15),
          _langCard('English', 'en', 'US', isDark),
          const SizedBox(height: 15),
          _langCard('Español', 'es', 'ES', isDark),
        ],
      ),
    );
  }

  Widget _langCard(String title, String langCode, String countryCode, bool isDark) {
    bool isSelected = context.locale.languageCode == langCode;
    return InkWell(
      onTap: () {
        context.setLocale(Locale(langCode, countryCode)); // DİLİ DEĞİŞTİRİR
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.amber.withOpacity(0.2) 
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  // --- 2. ADIM: TEMA SEÇİM EKRANI ---
  Widget _buildThemePage(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette_outlined, size: 80, color: isDark ? Colors.white : Colors.black87),
          const SizedBox(height: 30),
          Text(
            'choose_theme'.tr(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _themeCard('theme_light'.tr(), Icons.wb_sunny, ThemeMode.light, themeProvider, isDark),
              _themeCard('theme_dark'.tr(), Icons.nightlight_round, ThemeMode.dark, themeProvider, isDark),
              _themeCard('theme_system'.tr(), Icons.settings_suggest, ThemeMode.system, themeProvider, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themeCard(String title, IconData icon, ThemeMode mode, ThemeProvider provider, bool isDark) {
    bool isSelected = provider.themeMode == mode;
    return GestureDetector(
      onTap: () => provider.setTheme(mode), // TEMAYI DEĞİŞTİRİR
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.amber.withOpacity(0.2) 
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
            ),
            child: Icon(icon, size: 30, color: isSelected ? Colors.amber : (isDark ? Colors.white54 : Colors.black54)),
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // --- 3. ADIM: GİRİŞ EKRANI ---
  Widget _buildFinalPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 100),
          const SizedBox(height: 40),
          Text(
            'welcome'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: _loginAndContinue,
            icon: const Icon(Icons.login, color: Colors.black),
            label: Text('login_google'.tr(), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'skip_guest'.tr(),
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
