// lib/models/weather_exceptions.dart

// Tüm hava durumu ile ilgili özel hata tiplerimi burada topluyorum.
// Not: Her exception'ın hem teknik hem kullanıcıya uygun mesajı var. İleride hata ayıklarken ve kullanıcıya bildirim gösterirken çok işime yarıyor.

/// Tüm hava durumu hatalarının temel sınıfı.
class WeatherException implements Exception {
  /// Teknik hata mesajı (log için)
  final String technicalMessage;

  /// Kullanıcıya gösterilecek dost mesaj
  final String userFriendlyMessage;

  WeatherException(this.technicalMessage, this.userFriendlyMessage);

  @override
  String toString() => technicalMessage;
}

/// İnternet bağlantısı yoksa fırlatılır.
class NoInternetException extends WeatherException {
  NoInternetException()
      : super('No internet connection available',
            'İnternet bağlantınızı kontrol edin ve tekrar deneyin');
}

/// API anahtarı geçersiz veya yetkilendirme hatası varsa fırlatılır.
class InvalidApiKeyException extends WeatherException {
  InvalidApiKeyException()
      : super('Invalid API key or authorization failed',
            'API anahtarı geçersiz. Lütfen geliştiriciye bildirin.');
}

/// API limiti aşılırsa fırlatılır.
class ApiLimitExceededException extends WeatherException {
  ApiLimitExceededException()
      : super('API rate limit exceeded',
            'API limit aşımı. Lütfen birkaç dakika sonra tekrar deneyin.');
}

/// Şehir bulunamazsa fırlatılır.
class CityNotFoundException extends WeatherException {
  /// Aranan şehir adı
  final String cityName;

  CityNotFoundException(this.cityName)
      : super('City not found: $cityName',
            'Şehir bulunamadı. Farklı bir isim deneyin veya Türkçe karakter kullanın.');
}

/// Sunucuya istek zaman aşımına uğrarsa fırlatılır.
class TimeoutException extends WeatherException {
  TimeoutException()
      : super('Request timeout',
            'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
}

/// Sunucu hata kodu dönerse fırlatılır.
class ServerException extends WeatherException {
  /// Sunucudan dönen hata kodu
  final int statusCode;

  ServerException(this.statusCode)
      : super('Server error: $statusCode',
            'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.');
}

/// Veri parse hatası (devamı aşağıda)
class ParseException extends WeatherException {
  ParseException()
      : super('Failed to parse weather data',
            'Hava durumu verileri okunamadı. Lütfen uygulamayı yeniden başlatın.');
}
