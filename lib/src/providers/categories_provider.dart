import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/models/todo_category.dart';

class CategoriesNotifier extends StateNotifier<List<TodoCategory>> {
  CategoriesNotifier() : super(stockCategories);

  void addCategory(TodoCategory category) {
    state = [...state, category];
  }

  void removeCategory(String categoryId) {
    state = state.where((category) => category.id != categoryId).toList();
  }

  void updateCategory(TodoCategory updatedCategory) {
    state = state.map((category) {
      return category.id == updatedCategory.id ? updatedCategory : category;
    }).toList();
  }

  TodoCategory? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<TodoCategory>>((ref) {
  return CategoriesNotifier();
});
