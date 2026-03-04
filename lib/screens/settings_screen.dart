import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF5F8FC);
    final Color cardBg = isDark ? const Color(0xFF141E2E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A2744);
    final Color subText = isDark ? Colors.white54 : const Color(0xFF5A6B85);
    final Color divider = isDark ? Colors.white12 : const Color(0xFFDDE6F0);
    final Color accent = const Color(0xFFFFCC02);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFEBF2FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: textColor, size: 16),
          ),
        ),
        title: Text('settings'.tr(),
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── GÖRÜNÜM ─────────────────────────────────────
          _sectionLabel(
              'section_appearance'.tr(), Icons.palette_outlined, accent),
          _card(cardBg, divider, [
            // Tema seçici — görsel kutucuklar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('theme_title'.tr(),
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _themeChip(
                        label: 'theme_system'.tr(),
                        icon: Icons.brightness_auto_rounded,
                        selected: themeProvider.themeMode == ThemeMode.system,
                        onTap: () => themeProvider.setTheme(ThemeMode.system),
                        isDark: isDark,
                        accent: accent,
                      ),
                      const SizedBox(width: 10),
                      _themeChip(
                        label: 'theme_light'.tr(),
                        icon: Icons.wb_sunny_rounded,
                        selected: themeProvider.themeMode == ThemeMode.light,
                        onTap: () => themeProvider.setTheme(ThemeMode.light),
                        isDark: isDark,
                        accent: accent,
                      ),
                      const SizedBox(width: 10),
                      _themeChip(
                        label: 'theme_dark'.tr(),
                        icon: Icons.nights_stay_rounded,
                        selected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () => themeProvider.setTheme(ThemeMode.dark),
                        isDark: isDark,
                        accent: accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: divider, height: 1),

            // Sıcaklık birimi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('temp_unit_title'.tr(),
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _unitChip(
                        label: '°C — Celsius',
                        selected: themeProvider.tempUnit == 'C',
                        onTap: () => themeProvider.setTempUnit('C'),
                        isDark: isDark,
                        accent: accent,
                      ),
                      const SizedBox(width: 10),
                      _unitChip(
                        label: '°F — Fahrenheit',
                        selected: themeProvider.tempUnit == 'F',
                        onTap: () => themeProvider.setTempUnit('F'),
                        isDark: isDark,
                        accent: accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── DİL ─────────────────────────────────────────
          _sectionLabel(
              'section_language'.tr(), Icons.language_rounded, accent),
          _card(cardBg, divider, [
            _langTile(context, '🇹🇷', 'Türkçe', 'tr', 'TR', textColor, subText,
                accent, divider),
            _langTile(context, '🇬🇧', 'English', 'en', 'US', textColor,
                subText, accent, divider),
            _langTile(context, '🇪🇸', 'Español', 'es', 'ES', textColor,
                subText, accent, null),
          ]),

          const SizedBox(height: 20),

          // ── BİLDİRİMLER ─────────────────────────────────
          _sectionLabel('section_notifications'.tr(),
              Icons.notifications_outlined, accent),
          _card(cardBg, divider, [
            _comingSoonTile(
              icon: Icons.notifications_active_outlined,
              iconColor: const Color(0xFFFF7043),
              label: 'notif_alerts'.tr(),
              sub: 'notif_alerts_sub'.tr(),
              textColor: textColor,
              subText: subText,
              divider: divider,
              accent: accent,
              isDark: isDark,
            ),
            _comingSoonTile(
              icon: Icons.wb_sunny_outlined,
              iconColor: const Color(0xFFFFCC02),
              label: 'notif_daily'.tr(),
              sub: 'notif_daily_sub'.tr(),
              textColor: textColor,
              subText: subText,
              divider: null,
              accent: accent,
              isDark: isDark,
            ),
          ]),

          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Image.asset('assets/logo.png',
                    height: 44, opacity: const AlwaysStoppedAnimation(0.4)),
                const SizedBox(height: 8),
                Text('MooWeather v1.0.0',
                    style: TextStyle(
                        color: subText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('Made by cyberQbit',
                    style: TextStyle(
                        color: subText.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── YARDIMCI WİDGETLER ──────────────────────────────────────

  Widget _sectionLabel(String title, IconData icon, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: accent),
          const SizedBox(width: 6),
          Text(title,
              style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6)),
        ],
      ),
    );
  }

  Widget _card(Color bg, Color border, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A7AB5).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _themeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
    required Color accent,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.15)
                : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF0F4F8)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected
                      ? accent
                      : (isDark ? Colors.white54 : Colors.grey),
                  size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: selected
                          ? accent
                          : (isDark ? Colors.white60 : Colors.grey.shade600),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
    required Color accent,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.15)
                : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF0F4F8)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected
                        ? accent
                        : (isDark ? Colors.white60 : Colors.grey.shade600),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _langTile(
    BuildContext context,
    String flag,
    String title,
    String lang,
    String country,
    Color textColor,
    Color subText,
    Color accent,
    Color? divider,
  ) {
    final selected = context.locale.languageCode == lang;
    return Column(
      children: [
        InkWell(
          onTap: () => context.setLocale(Locale(lang, country)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Text(title,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                if (selected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withOpacity(0.5)),
                    ),
                    child: Text('active_label'.tr(),
                        style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: subText, size: 18),
              ],
            ),
          ),
        ),
        if (divider != null) Divider(color: divider, height: 1, indent: 56),
      ],
    );
  }

  Widget _comingSoonTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sub,
    required Color textColor,
    required Color subText,
    required Color? divider,
    required Color accent,
    required bool isDark,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor.withOpacity(0.5), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text(sub,
                        style: TextStyle(
                            color: subText.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Text('coming_soon'.tr(),
                    style: TextStyle(
                        color: accent.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        if (divider != null) Divider(color: divider, height: 1, indent: 56),
      ],
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color subText,
    required Color? divider,
    required bool isDark,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text(sub, style: TextStyle(color: subText, fontSize: 11)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFFFFCC02),
              ),
            ],
          ),
        ),
        if (divider != null) Divider(color: divider, height: 1, indent: 56),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textColor,
    required Color subText,
    required Color? divider,
    required bool isDark,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(value,
                  style: TextStyle(
                      color: subText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (divider != null) Divider(color: divider, height: 1, indent: 56),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color textColor,
    required Color subText,
    required Color? divider,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: subText, size: 18),
              ],
            ),
          ),
        ),
        if (divider != null) Divider(color: divider, height: 1, indent: 56),
      ],
    );
  }
}
