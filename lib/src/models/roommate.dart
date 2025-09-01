import 'package:flutter/foundation.dart';

@immutable
class Roommate {
  final String id;
  final String name;
  final String? photoUrl;
  final double monthlyBudget;
  final int tasksCompleted;

  const Roommate({
    required this.id,
    required this.name,
    this.photoUrl,
    this.monthlyBudget = 0,
    this.tasksCompleted = 0,
  });

  Roommate copyWith({
    String? id,
    String? name,
    String? photoUrl,
    double? monthlyBudget,
    int? tasksCompleted,
  }) {
    return Roommate(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
    );
  }
}