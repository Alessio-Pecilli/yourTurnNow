import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:your_turn/src/models/user_data.dart';
import 'package:your_turn/src/models/expense_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
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

      // 5) aggiungi transazioni automatiche per il nuovo utente
      _addInitialTransactions(account.id);

      
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

  /// Aggiunge transazioni iniziali automatiche per un nuovo utente
  void _addInitialTransactions(String userId) {
    final transactionsCtrl = ref.read(transactionsProvider.notifier);
    final now = DateTime.now();

    // Verifica se l'utente ha già delle transazioni
    final existingTxs = ref.read(transactionsProvider);
    final userHasTxs = existingTxs.any((tx) => tx.roommateId == userId);
    
    // Se ha già transazioni, non aggiungere nulla
    if (userHasTxs) return;

    // Lista di transazioni varie e colorate per il profilo
    final initialTransactions = [
      // Spese recenti
      {'amount': -25.0, 'note': 'Spesa supermercato 🛒', 'days': 1, 'category': ExpenseCategory.spesa},
      {'amount': -45.0, 'note': 'Quota bolletta luce 💡', 'days': 2, 'category': ExpenseCategory.bolletta},
      {'amount': -12.0, 'note': 'Detersivo cucina 🧴', 'days': 3, 'category': ExpenseCategory.spesa},
      {'amount': 30.0, 'note': 'Rimborso cena con amici 🍕', 'days': 4, 'category': ExpenseCategory.prestito},
      {'amount': -60.0, 'note': 'Bolletta gas 🔥', 'days': 5, 'category': ExpenseCategory.bolletta},
      
      // Settimana scorsa
      {'amount': -18.0, 'note': 'Pizza a domicilio 🍕', 'days': 8, 'category': ExpenseCategory.altro},
      {'amount': -8.0, 'note': 'Prodotti bagno 🚿', 'days': 10, 'category': ExpenseCategory.pulizia},
      {'amount': 25.0, 'note': 'Prestito Marco per benzina ⛽', 'days': 12, 'category': ExpenseCategory.trasporti},
      {'amount': -35.0, 'note': 'Internet casa 📶', 'days': 14, 'category': ExpenseCategory.bolletta},
      {'amount': -22.0, 'note': 'Aperitivo coinquilini 🍻', 'days': 16, 'category': ExpenseCategory.altro},
    ];

    // Aggiunge ogni transazione
    for (final txData in initialTransactions) {
      transactionsCtrl.addTx(
        roommateId: userId,
        amount: txData['amount'] as double,
        note: txData['note'] as String,
        when: now.subtract(Duration(days: txData['days'] as int)),
        category: txData['category'] as ExpenseCategory,
      );
    }
  }
}
