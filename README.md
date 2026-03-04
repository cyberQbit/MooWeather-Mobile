
# 🌤️ MooWeather - Advanced Full-Stack Weather App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![UI/UX](https://img.shields.io/badge/UI%2FUX-Glassmorphism-purple?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🇹🇷 TÜRKÇE (Turkish)

MooWeather, Flutter ile geliştirilmiş, modern ve zengin özelliklere sahip bir hava durumu uygulamasıdır. Basit bir API veri çekme işleminin ötesine geçerek, kullanıcı kimlik doğrulaması ve cihazlar arası bulut senkronizasyonu için özel bir **C# .NET Backend** entegrasyonu sunar.

> ⚠️ **Not:** Bu depo sadece frontend (Mobil Uygulama) kaynak kodunu içerir. Uygulamayı tam işlevsellikle çalıştırmak için Backend API'sine ihtiyacınız vardır.
> 👉 **[MooWeather C# .NET Backend Reposu için buraya tıklayın](https://github.com/cyberQbit/MooWeather-Backend)**

### ✨ Temel Özellikler

* **🎨 Premium Glassmorphism (Buzlu Cam) UI:** Seçilen temaya (Gündüz/Gece) göre değişen dinamik arka plan geçişlerine sahip şık, buzlu cam tasarımı.
* **🌍 Çoklu Dil Desteği:** `easy_localization` paketi kullanılarak İngilizce, Türkçe ve İspanyolca dillerinde tam yerelleştirme.
* **🌓 Dinamik Temalar:** `provider` kullanarak Açık, Koyu veya Sistem varsayılan temaları arasında sorunsuz geçiş.
* **🔐 Google ile Giriş ve Bulut Senkronizasyonu:** Kullanıcılar uygulamayı Misafir olarak (verileri yerel kaydederek) kullanabilir veya favori konumlarını bulut veritabanıyla senkronize etmek için Google ile giriş yapabilirler.
* **📍 Akıllı Konum ve Otomatik Tamamlama:** Mevcut hava durumunu almak için GPS kullanır ve dünya çapında yeni şehirler keşfetmek için hızlı, otomatik tamamlamalı bir arama çubuğu sunar.
* **🛡️ Güçlü Hata Yönetimi:** JSON ayrıştırma hatalarına ve API çökmelerine karşı yerleşik korumalar sayesinde pürüzsüz bir deneyim sağlar.

### 📸 Ekran Görüntüleri

<p align="center">
  <a href="https://freeimage.host/i/qCBs5Yl"><img src="https://iili.io/qCBs5Yl.md.png" alt="Light Mode" border="0" width="30%"></a>
  <a href="https://freeimage.host/i/qCBsTEG"><img src="https://iili.io/qCBsTEG.md.png" alt="Dark Mode" border="0" width="30%"></a>
  <a href="https://freeimage.host/i/qCBsECu"><img src="https://iili.io/qCBsECu.md.png" alt="Detail Screen" border="0" width="30%"></a>
</p>

### 🚀 Başlangıç

#### Ön Koşullar
- Flutter SDK (en son kararlı sürüm)
- Çalışır durumda bir MooWeather C# API'si (`lib/services/api_service.dart` dosyasındaki `baseUrl` adresini güncelleyin)

#### Kurulum
1. Repoyu klonlayın:
```bash
git clone [https://github.com/cyberQbit/MooWeather-Mobile.git](https://github.com/cyberQbit/MooWeather-Mobile.git)
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```


---

## 🇬🇧 ENGLISH

MooWeather is a modern, feature-rich weather application built with Flutter. It goes beyond simple API fetching by integrating a custom **C# .NET Backend** for user authentication and cross-device cloud synchronization.

> ⚠️ **Note:** This repository contains only the frontend (Mobile App) source code. To run this app with full functionality, you need the Backend API.
> 👉 **[Click here for the MooWeather C# .NET Backend Repository](https://github.com/cyberQbit/MooWeather-Backend)**

### ✨ Key Features

* **🎨 Premium Glassmorphism UI:** A sleek, frosted-glass design with dynamic gradients that change based on the selected theme (Day/Night).
* **🌍 Multi-Language Support:** Fully localized in English, Turkish, and Spanish using `easy_localization`.
* **🌓 Dynamic Themes:** Switch seamlessly between Light, Dark, or System default themes using `provider`.
* **🔐 Google Sign-In & Cloud Sync:** Users can use the app as a Guest (saving data locally) or sign in with Google to sync their favorite locations to the cloud database.
* **📍 Smart Location & Autocomplete:** Uses GPS to fetch current weather and features a fast, auto-completing search bar for discovering new cities globally.
* **🛡️ Robust Error Handling:** Built-in safeguards against JSON parsing errors and API failures ensuring a crash-free experience.

### 📸 Screenshots

<p align="center">
<a href="https://freeimage.host/i/qCBs5Yl"><img src="https://iili.io/qCBs5Yl.md.png" alt="Light Mode" border="0" width="30%"></a>
<a href="https://freeimage.host/i/qCBsTEG"><img src="https://iili.io/qCBsTEG.md.png" alt="Dark Mode" border="0" width="30%"></a>
<a href="https://freeimage.host/i/qCBsECu"><img src="https://iili.io/qCBsECu.md.png" alt="Detail Screen" border="0" width="30%"></a>
</p>

### 🚀 Getting Started

#### Prerequisites

* Flutter SDK (latest stable version)
* A running instance of the MooWeather C# API (Update `baseUrl` in `lib/services/api_service.dart`)

#### Installation

1. Clone the repository:
```bash
git clone [https://github.com/cyberQbit/MooWeather-Mobile.git](https://github.com/cyberQbit/MooWeather-Mobile.git)

```


2. Install dependencies:
```bash
flutter pub get

```


3. Run the app:
```bash
flutter run
