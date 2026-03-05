import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // C# API Adresimiz
  static const String baseUrl = 'https://mooweather-api.onrender.com/api';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // DİKKAT: O uzun Web Client ID'ni buraya yapıştırmayı unutma!
    serverClientId:
        '1039347948230-83vugh16vq6iqo9ur948844f1kus9hqu.apps.googleusercontent.com',
    scopes: <String>['email', 'profile'],
  );

  // Giriş Yapma Fonksiyonu
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Google Giriş ekranını aç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Kullanıcı Google girişini iptal etti veya ekran kapandı.');
        return null;
      }

      debugPrint('Google user: ${googleUser.email} | id: ${googleUser.id}');

      // 2. Google'dan Referans Mektubunu (IdToken) al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('Google idToken null döndü. auth: $googleAuth');
        throw Exception('Google Token alınamadı!');
      }
      debugPrint('Google idToken alındı (uzunluk: ${idToken.length})');

      // 3. Mektubu bizim C# API'ye (Bodyguard'a) gönder
      final response = await http.post(
        Uri.parse('$baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      // 4. Bodyguard mektubu onaylarsa
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String jwtToken = responseData['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwtToken);

        debugPrint("Giriş Başarılı! VIP Kart Alındı: $jwtToken");
        return jwtToken;
      } else {
        debugPrint("API Girişi Reddetti. Hata Kodu: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint('Giriş sırasında hata oluştu: $e');
      return null;
    }
  }

  // Çıkış Yapma Fonksiyonu
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
