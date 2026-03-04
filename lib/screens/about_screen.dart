import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text('about'.tr(),
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── HAKKINDA ─────────────────────────────────────
          _sectionLabel(
              'section_about'.tr(), Icons.info_outline_rounded, accent),
          _card(cardBg, divider, [
            _infoTile(
              icon: Icons.apps_rounded,
              iconColor: const Color(0xFF64B5F6),
              label: 'app_label'.tr(),
              value: 'MooWeather',
              textColor: textColor,
              subText: subText,
              divider: divider,
              isDark: isDark,
            ),
            _infoTile(
              icon: Icons.tag_rounded,
              iconColor: const Color(0xFF81C784),
              label: 'version_label'.tr(),
              value: 'v1.0.0',
              textColor: textColor,
              subText: subText,
              divider: divider,
              isDark: isDark,
            ),
            _infoTile(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFFCE93D8),
              label: 'developer_label'.tr(),
              value: 'cyberQbit',
              textColor: textColor,
              subText: subText,
              divider: divider,
              isDark: isDark,
            ),
            _infoTile(
              icon: Icons.cloud_outlined,
              iconColor: const Color(0xFF80CBC4),
              label: 'data_source_label'.tr(),
              value: 'OpenWeatherMap',
              textColor: textColor,
              subText: subText,
              divider: divider,
              isDark: isDark,
            ),
            _actionTile(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFFFFB74D),
              label: 'privacy_policy'.tr(),
              textColor: textColor,
              subText: subText,
              divider: divider,
              isDark: isDark,
              onTap: () {},
            ),
            _actionTile(
              icon: Icons.star_outline_rounded,
              iconColor: const Color(0xFFFFCC02),
              label: 'rate_app'.tr(),
              textColor: textColor,
              subText: subText,
              divider: null,
              isDark: isDark,
              onTap: () {},
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
