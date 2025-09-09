import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/models/user_data.dart';

// Provider per l'utente corrente - null inizialmente, verrà popolato da Google Auth
final userProvider = StateProvider<UserData?>((ref) => null);