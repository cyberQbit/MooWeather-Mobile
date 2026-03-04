// lib/widgets/loading_shimmer.dart

// Modern yükleme animasyonu widget'ım.
// Not: Shimmer paketi ile iskelet ekranı gösteriyorum, kullanıcıya "veri yükleniyor" hissi veriyor.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

/// Yükleme sırasında gösterilen shimmer animasyonu
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // Ana renk (başlangıç)
      baseColor: Colors.white.withOpacity(0.1),
      // Parlak renk (animasyon sırasında)
      highlightColor: Colors.white.withOpacity(0.3),
      // Animasyon döngüsü süresi
      period: const Duration(milliseconds: 1500),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Şehir adı için shimmer kutusu
              _buildShimmerBox(
                width: 150,
                height: 30,
                borderRadius: AppDimens.radiusSmall,
              ),

              const SizedBox(height: AppDimens.paddingMedium),

              // Büyük sıcaklık için shimmer kutusu
              Center(
                child: _buildShimmerBox(
                  width: 200,
                  height: 120,
                  borderRadius: AppDimens.radiusMedium,
                ),
              ),

              const SizedBox(height: AppDimens.paddingSmall),

              // Hava durumu açıklaması için shimmer kutusu
              Center(
                child: _buildShimmerBox(
                  width: 180,
                  height: 20,
                  borderRadius: AppDimens.radiusSmall,
                ),
              ),

              const SizedBox(height: AppDimens.paddingXLarge),

              // Saatlik tahmin başlığı
              _buildShimmerBox(
                width: 120,
                height: 20,
                borderRadius: AppDimens.radiusSmall,
              ),

              const SizedBox(height: AppDimens.paddingMedium),

              // Saatlik tahmin kartları (yatay)
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                      right: AppDimens.paddingSmall,
                      left: index == 0 ? 0 : 0,
                    ),
                    child: _buildShimmerBox(
                      width: 80,
                      height: 140,
                      borderRadius: AppDimens.radiusMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.paddingXLarge),

              // Detay bilgileri başlığı
              _buildShimmerBox(
                width: 100,
                height: 20,
                borderRadius: AppDimens.radiusSmall,
              ),

              const SizedBox(height: AppDimens.paddingMedium),

              // Info kartları grid (2x2)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimens.paddingMedium,
                  crossAxisSpacing: AppDimens.paddingMedium,
                  childAspectRatio: 1.3,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => _buildShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: AppDimens.radiusMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer için placeholder box oluşturur
  ///
  /// Öğrenci Notu: Bu yardımcı fonksiyon, kod tekrarını önler (DRY prensibi)
  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }
}

/// Basit yükleme göstergesi (shimmer yerine alternatif)
///
/// Öğrenci Notu:
/// Bazı durumlarda basit bir loading indicator yeterli olabilir
/// Bu daha az kaynak tüketir
class SimpleLoadingIndicator extends StatelessWidget {
  final String? message;

  const SimpleLoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CircularProgressIndicator: Flutter'ın yerleşik loading widget'ı
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),

          if (message != null) ...[
            const SizedBox(height: AppDimens.paddingLarge),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
