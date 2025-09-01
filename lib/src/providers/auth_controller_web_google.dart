import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:your_turn/src/models/user_data.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';


final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile', 'openid']);

final authControllerProvider = Provider((ref) => AuthController(ref));

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<void> login() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;

      // 1) prova dalla libreria
      String? photo = account.photoUrl;

      // 2) fallback: OIDC userinfo → picture
      if ((photo == null || photo.isEmpty) && (auth.accessToken != null)) {
        final pic = await _fetchPictureFromUserInfo(auth.accessToken!);
        if (pic != null && pic.isNotEmpty) {
          photo = pic;
        }
      }

      // 3) salva utente
      ref.read(userProvider.notifier).state = UserData(
        id: account.id,
        name: account.displayName ?? account.email.split('@').first,
        email: account.email,
        photoUrl: photo,
      );

      // 4) tieni allineati i roommates
      ref.read(roommatesProvider.notifier).ensure(
        account.id,
        name: account.displayName ?? account.email.split('@').first,
        photoUrl: photo,
      );

      
    } catch (e) {
      // log compatto
      // ignore: avoid_print
      print('Errore login: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      ref.read(userProvider.notifier).state = null;
    } catch (_) {}
  }

  Future<String?> _fetchPictureFromUserInfo(String accessToken) async {
    final uri = Uri.parse('https://openidconnect.googleapis.com/v1/userinfo');
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return map['picture'] as String?;
    }
    return null;
    }
}
