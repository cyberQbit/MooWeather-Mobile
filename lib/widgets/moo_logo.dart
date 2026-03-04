// lib/widgets/moo_logo.dart
//
// MooWeather özel logo widget'ım.
// Not: Hem animasyonlu hem statik versiyonu var. Gradient renklerle modern bir görünüm sağlıyor.

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Ana logo widget'ı (animasyonlu veya statik)
class MooLogo extends StatelessWidget {
  final double size;
  final bool animated;

  const MooLogo({
    super.key,
    this.size = 120,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    // Animasyonlu logo mu gösterilecek?
    if (animated) {
      return _AnimatedMooLogo(size: size);
    }
    // Yoksa statik logo
    return _StaticMooLogo(size: size);
  }
}

/// Statik logo (ör: app icon için)
class _StaticMooLogo extends StatelessWidget {
  final double size;

  const _StaticMooLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MooLogoPainter(),
      ),
    );
  }
}

/// Animasyonlu logo (ör: splash screen için)
class _AnimatedMooLogo extends StatefulWidget {
  final double size;

  const _AnimatedMooLogo({required this.size});

  @override
  State<_AnimatedMooLogo> createState() => _AnimatedMooLogoState();
}

class _AnimatedMooLogoState extends State<_AnimatedMooLogo>
    with SingleTickerProviderStateMixin {
  // Animasyon controller'ı
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _MooLogoPainter(),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Logo çizim sınıfı
class _MooLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Arka plan gradient (yuvarlak)
    final bgGradient = RadialGradient(
      colors: [
        const Color(0xFF4A90E2),
        const Color(0xFF357ABD),
      ],
    );
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, bgPaint);

    // Güneş (sağ üstte)
    final sunCenter = Offset(size.width * 0.65, size.height * 0.35);
    final sunRadius = size.width * 0.25;
    final sunGradient = RadialGradient(
      colors: [
        const Color(0xFFFDB813),
        const Color(0xFFF89D1C),
      ],
    );
    final sunPaint = Paint()
      ..shader = sunGradient.createShader(
        Rect.fromCircle(center: sunCenter, radius: sunRadius),
      );
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Güneş ışınları
    final rayPaint = Paint()
      ..color = const Color(0xFFFDB813).withOpacity(0.6)
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 8;
      final startX = sunCenter.dx + math.cos(angle) * sunRadius * 1.2;
      final startY = sunCenter.dy + math.sin(angle) * sunRadius * 1.2;
      final endX = sunCenter.dx + math.cos(angle) * sunRadius * 1.6;
      final endY = sunCenter.dy + math.sin(angle) * sunRadius * 1.6;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        rayPaint,
      );
    }

    // Büyük bulut (sol altta)
    _drawCloud(
      canvas,
      Offset(size.width * 0.35, size.height * 0.65),
      size.width * 0.35,
      Colors.white.withOpacity(0.95),
    );

    // Küçük bulut (sağ ortada)
    _drawCloud(
      canvas,
      Offset(size.width * 0.7, size.height * 0.55),
      size.width * 0.2,
      Colors.white.withOpacity(0.85),
    );

    // "M" harfi (merkezde, minimalist)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'M',
        style: TextStyle(
          fontSize: size.width * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double cloudSize, Color color) {
    final cloudPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 3 daireden oluşan bulut
    canvas.drawCircle(
      Offset(center.dx - cloudSize * 0.3, center.dy),
      cloudSize * 0.4,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - cloudSize * 0.15),
      cloudSize * 0.5,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + cloudSize * 0.3, center.dy),
      cloudSize * 0.4,
      cloudPaint,
    );

    // Alt kısım (bulutun tabanı)
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + cloudSize * 0.1),
        width: cloudSize * 1.4,
        height: cloudSize * 0.6,
      ),
      Radius.circular(cloudSize * 0.3),
    );
    canvas.drawRRect(rect, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Logo export fonksiyonu (PNG olarak kaydetmek için)
class MooLogoExporter {
  static Future<void> exportLogo({
    required double size,
    required String outputPath,
  }) async {
    // Bu fonksiyon gerekirse logo'yu PNG olarak kaydedebilir
    // Şu an için sadece widget olarak kullanacağız
  }
}
