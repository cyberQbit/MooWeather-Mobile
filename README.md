## 🌤️ MooWeather - Advanced Full-Stack Weather App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![UI/UX](https://img.shields.io/badge/UI%2FUX-Glassmorphism-purple?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

MooWeather is a modern, feature-rich weather application built with Flutter. It goes beyond simple API fetching by integrating a custom **C# .NET Backend** for user authentication and cross-device cloud synchronization.

> ⚠️ **Note:** This repository contains only the frontend (Mobile App) source code. To run this app with full functionality, you need the Backend API.
> 👉 **[Click here for the MooWeather C# .NET Backend Repository](https://github.com/cyberQbit/MooWeather-Backend)**

## ✨ Key Features

* **🎨 Premium Glassmorphism UI:** A sleek, frosted-glass design with dynamic gradients that change based on the selected theme (Day/Night).
* **🌍 Multi-Language Support:** Fully localized in English, Turkish, and Spanish using `easy_localization`.
* **🌓 Dynamic Themes:** Switch seamlessly between Light, Dark, or System default themes using `provider`.
* **🔐 Google Sign-In & Cloud Sync:** Users can use the app as a Guest (saving data locally) or sign in with Google to sync their favorite locations to the cloud database.
* **📍 Smart Location & Autocomplete:** Uses GPS to fetch current weather and features a fast, auto-completing search bar for discovering new cities globally.
* **🛡️ Robust Error Handling:** Built-in safeguards against JSON parsing errors and API failures ensuring a crash-free experience.

## 📸 Screenshots

<p align="center">
  <a href="https://freeimage.host/i/qCBs5Yl"><img src="https://iili.io/qCBs5Yl.md.png" alt="qCBs5Yl.md.png" border="0"></a>
  <a href="https://freeimage.host/i/qCBsTEG"><img src="https://iili.io/qCBsTEG.md.png" alt="qCBsTEG.md.png" border="0"></a>
  <a href="https://freeimage.host/i/qCBsECu"><img src="https://iili.io/qCBsECu.md.png" alt="qCBsECu.md.png" border="0"></a>
</p>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- A running instance of the MooWeather C# API (Update `baseUrl` in `lib/services/api_service.dart`)

### Installation
1. Clone the repository:
   ```
   git clone [https://github.com/SENIN_KULLANICI_ADIN/MooWeather-Mobile.git](https://github.com/SENIN_KULLANICI_ADIN/MooWeather-Mobile.git)

2. Install dependencies:
```
flutter pub get
```

3. Run the app:
```
flutter run
```
