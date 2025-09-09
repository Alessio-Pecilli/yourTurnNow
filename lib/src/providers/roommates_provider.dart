import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/mock_db.dart';
import 'package:your_turn/src/models/roommate.dart';


class RoommatesCtrl extends StateNotifier<List<Roommate>> {
  RoommatesCtrl() : super(mockRoommates);

  void ensure(String id, {String? name, String? photoUrl}) {
    final i = state.indexWhere((e) => e.id == id);
    if (i >= 0) {
      final r = state[i];
      state = [...state]..[i] = r.copyWith(
        name: name ?? r.name,
        photoUrl: photoUrl ?? r.photoUrl,
      );
      return;
    }
    state = [...state, Roommate(id: id, name: name ?? id, photoUrl: photoUrl)];
  }

  void setBudget(String roommateId, double budget) {
    final i = state.indexWhere((e) => e.id == roommateId);
    if (i >= 0) state = [...state]..[i] = state[i].copyWith(monthlyBudget: budget);
  }

  void adjustCompletedFor(String roommateId, int delta) {
    final i = state.indexWhere((e) => e.id == roommateId);
    if (i < 0) return;
    final r = state[i];
    final newVal = (r.tasksCompleted + delta).clamp(0, 1 << 30);
    state = [...state]..[i] = r.copyWith(tasksCompleted: newVal);
  }

  void adjustBudgetFor(String roommateId, double delta) {
    final i = state.indexWhere((e) => e.id == roommateId);
    if (i < 0) return;
    final r = state[i];
    state = [...state]..[i] = r.copyWith(monthlyBudget: r.monthlyBudget + delta);
  }

  void remove(String roommateId) {
    state = state.where((r) => r.id != roommateId).toList();
  }
}

final roommatesProvider =
    StateNotifierProvider<RoommatesCtrl, List<Roommate>>((ref) => RoommatesCtrl());