// lib/utils/weather_translator.dart
//
// Hava durumu İngilizce-Türkçe çeviri yardımcısı.
// Not: OpenWeatherMap API İngilizce veri döndürür, bu yüzden UI'da Türkçe göstermek için bu sınıfı kullanıyorum.

class WeatherTranslator {
  // Ana hava durumu çeviri tablosu
  // Not: Map<String, String> ile hızlıca eşleştirme yapabiliyorum.
  static const Map<String, String> _conditions = {
    // Ana durumlar
    'Clear': 'Açık',
    'Clouds': 'Bulutlu',
    'Rain': 'Yağmurlu',
    'Drizzle': 'Çiseleyen',
    'Thunderstorm': 'Fırtınalı',
    'Snow': 'Karlı',
    'Mist': 'Sisli',
    'Smoke': 'Dumanlı',
    'Haze': 'Puslu',
    'Dust': 'Tozlu',
    'Fog': 'Sisli',
    'Sand': 'Kumlu',
    'Ash': 'Küllü',
    'Squall': 'Fırtınalı',
    'Tornado': 'Kasırgalı',

    // Detaylı açıklamalar
    'clear sky': 'açık hava',
    'few clouds': 'az bulutlu',
    'scattered clouds': 'parçalı bulutlu',
    'broken clouds': 'çok bulutlu',
    'overcast clouds': 'kapalı',
    'shower rain': 'sağanak yağışlı',
    'light rain': 'hafif yağmurlu',
    'moderate rain': 'orta şiddette yağmurlu',
    'heavy intensity rain': 'şiddetli yağmurlu',
    'very heavy rain': 'çok şiddetli yağmurlu',
    'extreme rain': 'aşırı yağmurlu',
    'freezing rain': 'dondurucu yağmur',
    'light intensity shower rain': 'hafif sağanak',
    'heavy intensity shower rain': 'şiddetli sağanak',
    'ragged shower rain': 'düzensiz sağanak',
    'thunderstorm with light rain': 'hafif yağmurlu fırtına',
    'thunderstorm with rain': 'yağmurlu fırtına',
    'thunderstorm with heavy rain': 'şiddetli yağmurlu fırtına',
    'light thunderstorm': 'hafif fırtına',
    'thunderstorm': 'fırtına',
    'heavy thunderstorm': 'şiddetli fırtına',
    'ragged thunderstorm': 'düzensiz fırtına',
    'thunderstorm with light drizzle': 'hafif çisentili fırtına',
    'thunderstorm with drizzle': 'çisentili fırtına',
    'thunderstorm with heavy drizzle': 'şiddetli çisentili fırtına',
    'light intensity drizzle': 'hafif çisenti',
    'drizzle': 'çisenti',
    'heavy intensity drizzle': 'şiddetli çisenti',
    'light intensity drizzle rain': 'hafif çisentili yağmur',
    'drizzle rain': 'çisentili yağmur',
    'heavy intensity drizzle rain': 'şiddetli çisentili yağmur',
    'shower rain and drizzle': 'sağanak ve çisenti',
    'heavy shower rain and drizzle': 'şiddetli sağanak ve çisenti',
    'shower drizzle': 'sağanak çisenti',
    'light snow': 'hafif kar',
    'snow': 'kar',
    'heavy snow': 'yoğun kar',
    'sleet': 'karla karışık yağmur',
    'light shower sleet': 'hafif sulu kar',
    'shower sleet': 'sulu kar',
    'light rain and snow': 'hafif kar yağışlı',
    'rain and snow': 'kar yağışlı',
    'light shower snow': 'hafif kar sağanağı',
    'shower snow': 'kar sağanağı',
    'heavy shower snow': 'yoğun kar sağanağı',
    'mist': 'sis',
    'smoke': 'duman',
    'haze': 'pus',
    'dust': 'toz',
    'fog': 'sis',
    'sand': 'kum',
    'ash': 'kül',
    'squall': 'fırtına',
    'tornado': 'kasırga',
  };

  /// Hava durumunu Türkçeye çevir
  ///
  /// Öğrenci Notu:
  /// - toLowerCase() ile case-insensitive (büyük/küçük harf duyarsız) yapıyoruz
  /// - ?? operatörü: Sol taraf null ise sağ tarafı kullan
  static String translate(String condition) {
    // Önce tam eşleşme ara (case-insensitive)
    final lowerCondition = condition.toLowerCase();

    // Tam eşleşme varsa döndür
    if (_conditions.containsKey(condition)) {
      return _conditions[condition]!;
    }

    // Küçük harfle eşleşme ara
    for (var entry in _conditions.entries) {
      if (entry.key.toLowerCase() == lowerCondition) {
        return entry.value;
      }
    }

    // Hiçbir eşleşme yoksa, orijinali döndür
    return condition;
  }

  /// İlk harfi büyük yap
  /// Örnek: "açık" -> "Açık"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Hava durumunu çevir ve ilk harfi büyüt
  static String translateAndCapitalize(String condition) {
    return capitalize(translate(condition));
  }
}
