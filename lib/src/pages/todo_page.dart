import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/todo_item.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';
import 'package:your_turn/src/widgets/todo/todo_add_dialog.dart';
import 'package:your_turn/src/widgets/todo/empty_state.dart';
import 'package:your_turn/src/widgets/todo/assignees_avatars.dart';
import 'package:your_turn/src/widgets/weather/weather_card.dart';
import 'profile_page.dart';
import 'admin_page.dart';

final todosCategoryFilterProvider = StateProvider<TodoCategory?>((ref) => null);

// Provider for "just you" filter
final todosJustYouFilterProvider = StateProvider<bool>((ref) => false);

// Provider for pagination
final currentPageProvider = StateProvider<int>((ref) => 0);
const int todosPerPage = 16; // Aumentato per sfruttare la griglia a 4 colonne (4x4 = 16)

// Provider for paginated todos
final paginatedTodosProvider = Provider<List<TodoItem>>((ref) {
  final allTodos = ref.watch(filteredTodosProvider);
  final currentPage = ref.watch(currentPageProvider);
  
  final startIndex = currentPage * todosPerPage;
  final endIndex = (startIndex + todosPerPage).clamp(0, allTodos.length);
  
  if (startIndex >= allTodos.length) return [];
  return allTodos.sublist(startIndex, endIndex);
});

// Provider for total pages
final totalPagesProvider = Provider<int>((ref) {
  final allTodos = ref.watch(filteredTodosProvider);
  return (allTodos.length / todosPerPage).ceil();
});

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  Color _hexColor(String hex) {
    final value = int.parse(hex.substring(1), radix: 16) + 0xFF000000;
    return Color(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final categories = ref.watch(categoriesProvider);
    final tasks = ref.watch(paginatedTodosProvider);
    final allTasks = ref.watch(filteredTodosProvider);
    final currentPage = ref.watch(currentPageProvider);
    final totalPages = ref.watch(totalPagesProvider);
    final roommates = ref.watch(roommatesProvider);

    // Reset pagina quando cambiano i filtri
    ref.listen(todosCategoryFilterProvider, (previous, next) {
      if (previous != next) {
        ref.read(currentPageProvider.notifier).state = 0;
      }
    });
    
    ref.listen(todosJustYouFilterProvider, (previous, next) {
      if (previous != next) {
        ref.read(currentPageProvider.notifier).state = 0;
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF6EC), Color(0xFFE0EAFD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Meteo a sinistra
                      const CompactWeather(city: 'Roma,IT'),
                      // Admin e profilo a destra
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings, size: 18),
                          label: const Text('Admin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      if (user != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.shade700,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user.photoUrl?.isNotEmpty == true
                                  ? Image.network(
                                      user.photoUrl!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _fallbackAvatar(user.name),
                                    )
                                  : _fallbackAvatar(user.name),
                            ),
                          ),
                        ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Stato (Toggle)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(12),
                              borderWidth: 2,
                              selectedBorderColor: Colors.blue.shade700,
                              borderColor: Colors.grey.shade400,
                              fillColor: Colors.blue.shade700,
                              selectedColor: Colors.white,
                              color: Colors.grey.shade700,
                              constraints: const BoxConstraints(minHeight: 40, minWidth: 84),
                              isSelected: [
                                ref.watch(todosFilterProvider) == null,
                                ref.watch(todosFilterProvider) == TodoStatus.done,
                                ref.watch(todosFilterProvider) == TodoStatus.open,
                              ],
                              onPressed: (idx) {
                                if (idx == 0) {
                                  ref.read(todosFilterProvider.notifier).state = null;
                                } else if (idx == 1) {
                                  ref.read(todosFilterProvider.notifier).state = TodoStatus.done;
                                } else {
                                  ref.read(todosFilterProvider.notifier).state = TodoStatus.open;
                                }
                              },
                              children: const [
                                _ToggleBtn(icon: Icons.list, text: 'Tutti'),
                                _ToggleBtn(icon: Icons.check_circle, text: 'Fatti'),
                                _ToggleBtn(icon: Icons.radio_button_unchecked, text: 'Da fare'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Ordina (Toggle)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(12),
                              borderWidth: 2,
                              selectedBorderColor: Colors.orange.shade600,
                              borderColor: Colors.grey.shade400,
                              fillColor: Colors.orange.shade600,
                              selectedColor: Colors.white,
                              color: Colors.grey.shade700,
                              constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
                              isSelected: [
                                ref.watch(todosOrderProvider) == 'data_desc',
                                ref.watch(todosOrderProvider) == 'costo_desc',
                                ref.watch(todosOrderProvider) == 'inserimento_asc',
                              ],
                              onPressed: (idx) {
                                if (idx == 0) {
                                  ref.read(todosOrderProvider.notifier).state = 'data_desc';
                                } else if (idx == 1) {
                                  ref.read(todosOrderProvider.notifier).state = 'costo_desc';
                                } else {
                                  ref.read(todosOrderProvider.notifier).state = 'inserimento_asc';
                                }
                              },
                              children: const [
                                _ToggleBtn(icon: Icons.calendar_today, text: 'Data'),
                                _ToggleBtn(icon: Icons.euro, text: 'Costo'),
                                _ToggleBtn(icon: Icons.add_circle, text: 'Nuovo'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Categorie (wrap inside a row)
                          Row(
                            children: [
                              ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.label_outline, size: 18, color: ref.watch(todosCategoryFilterProvider) == null ? Colors.blue.shade700 : Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    const Text('Tutte'),
                                  ],
                                ),
                                selected: ref.watch(todosCategoryFilterProvider) == null,
                                onSelected: (_) => ref.read(todosCategoryFilterProvider.notifier).state = null,
                                backgroundColor: Colors.grey.shade50,
                                selectedColor: Colors.blue.shade100,
                                labelStyle: TextStyle(
                                  color: ref.watch(todosCategoryFilterProvider) == null ? Colors.blue.shade700 : Colors.grey.shade600,
                                  fontWeight: ref.watch(todosCategoryFilterProvider) == null ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              const SizedBox(width: 8),
                              ...categories.map((category) {
                                final categoryColor = Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(category.icon, size: 18, color: categoryColor),
                                        const SizedBox(width: 4),
                                        Text(category.name),
                                      ],
                                    ),
                                    selected: ref.watch(todosCategoryFilterProvider)?.id == category.id,
                                    onSelected: (_) => ref.read(todosCategoryFilterProvider.notifier).state = category,
                                    backgroundColor: Colors.grey.shade50,
                                    selectedColor: Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color: categoryColor,
                                      fontWeight: ref.watch(todosCategoryFilterProvider)?.id == category.id ? FontWeight.bold : FontWeight.w600,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Lista task con separatore manuale (compatibile con Flutter stabile)
            if (tasks.isEmpty)
              const EmptyStateSliver()
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    // Calcola dimensioni dinamiche per i todo
                    final screenWidth = constraints.crossAxisExtent;
                    final minCardWidth = 280.0; // Larghezza minima per leggibilità
                    final maxCardWidth = 400.0; // Larghezza massima
                    
                    // Calcola numero ottimale di colonne
                    int crossAxisCount = (screenWidth / minCardWidth).floor();
                    if (crossAxisCount < 1) crossAxisCount = 1;
                    if (crossAxisCount > 6) crossAxisCount = 6;
                    
                    // Calcola larghezza effettiva delle card
                    final cardWidth = screenWidth / crossAxisCount;
                    final clampedCardWidth = cardWidth.clamp(minCardWidth, maxCardWidth);
                    
                    // Aspect ratio dinamico per altezza ottimale
                    final aspectRatio = clampedCardWidth / 220.0; // Altezza fissa 220px per vedere tutto
                    
                    return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = tasks[index];
                      final assigned = roommates.where((r) => t.assigneeIds.contains(r.id)).toList();
                      final dueStr = t.dueDate == null
                          ? null
                          : MaterialLocalizations.of(context).formatShortDate(t.dueDate!.toLocal());
                      final completedStr = (t.status == TodoStatus.done && t.completedAt != null)
                          ? MaterialLocalizations.of(context).formatShortDate(t.completedAt!.toLocal())
                          : null;
                      final isCompleted = t.status == TodoStatus.done;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2), // Solo margine verticale
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: isCompleted
                                ? [Colors.green.shade50.withOpacity(0.3), Colors.green.shade50.withOpacity(0.7)]
                                : [Colors.white, Colors.grey.shade100], // niente più celestino
                            begin: isCompleted ? Alignment.bottomRight : Alignment.topLeft,
                            end: isCompleted ? Alignment.topLeft : Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isCompleted
                                  ? Colors.green
                                  : Colors.blue)
                                  .withOpacity(0.07),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border: Border.all(
                            color: isCompleted ? Colors.green.shade200 : Colors.blue.shade200,
                            width: 0.7,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => ref.read(todosProvider.notifier).toggleDone(t.id),
                            child: Padding(
                              padding: const EdgeInsets.all(5), // Bilanciato per 4 colonne
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildCheckbox(isCompleted),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: _buildTitleArea(t, isCompleted, maxLines: 1),
                                        ),
                                        _buildActions(context, ref, t),
                                      ],
                                    ),
                                    const SizedBox(height: 6), // Aumentato per migliore separazione
                                    if (assigned.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: AssigneesAvatars(assignees: assigned),
                                      ),
                                      const SizedBox(height: 12), // Aumentato da 6 a 12 per più spazio
                                    ],
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        for (final cat in t.categories)
                                          _buildCategoryChip(
                                            _hexColor(cat.color),
                                            cat.icon,
                                            cat.name,
                                          ),
                                        if (t.cost != null)
                                          _infoChip(
                                            bg: Colors.green.shade100,
                                            border: Colors.green.shade300,
                                            icon: Icons.euro_rounded,
                                            iconColor: Colors.green.shade700,
                                            text: '€${t.cost!.toStringAsFixed(2)}',
                                            textColor: Colors.green.shade700,
                                          ),
                                        if (dueStr != null)
                                          _infoChip(
                                            bg: Colors.orange.shade100,
                                            border: Colors.orange.shade300,
                                            icon: Icons.schedule_rounded,
                                            iconColor: Colors.orange.shade700,
                                            text: 'Scade: $dueStr',
                                            textColor: Colors.orange.shade700,
                                          ),
                                        if (completedStr != null)
                                          _infoChip(
                                            bg: Colors.green.shade100,
                                            border: Colors.green.shade300,
                                            icon: Icons.check_circle_rounded,
                                            iconColor: Colors.green.shade700,
                                            text: 'Fatto: $completedStr',
                                            textColor: Colors.green.shade700,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: tasks.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Dinamico!
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12, // Spazio uniforme tra le card
                    childAspectRatio: aspectRatio, // Dinamico!
                  ),
                );
                  },
                ),
              ),

            // Controlli di paginazione
            if (totalPages > 1)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bottone Precedente
                      IconButton(
                        onPressed: currentPage > 0
                            ? () => ref.read(currentPageProvider.notifier).state = currentPage - 1
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 0 ? Colors.blue.shade50 : Colors.grey.shade200,
                          foregroundColor: currentPage > 0 ? Colors.blue.shade700 : Colors.grey,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Indicatori pagine
                      ...List.generate(totalPages, (index) {
                        final isCurrentPage = index == currentPage;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => ref.read(currentPageProvider.notifier).state = index,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isCurrentPage ? Colors.blue.shade700 : Colors.transparent,
                                border: Border.all(
                                  color: isCurrentPage ? Colors.blue.shade700 : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrentPage ? Colors.white : Colors.grey.shade600,
                                    fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).take(7), // Mostra massimo 7 pagine per volta
                      
                      const SizedBox(width: 16),
                      
                      // Bottone Successivo
                      IconButton(
                        onPressed: currentPage < totalPages - 1
                            ? () => ref.read(currentPageProvider.notifier).state = currentPage + 1
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage < totalPages - 1 ? Colors.blue.shade50 : Colors.grey.shade200,
                          foregroundColor: currentPage < totalPages - 1 ? Colors.blue.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Info conteggio todos
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Mostrando ${tasks.length} di ${allTasks.length} todos${totalPages > 1 ? ' (Pagina ${currentPage + 1} di $totalPages)' : ''}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTodoAddDialog(context, ref),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'Nuovo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _fallbackAvatar(String name) => Container(
    color: Colors.blue.shade700,
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  );

  Widget _buildCheckbox(bool done) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: done ? Colors.green.shade600 : Colors.transparent,
      border: Border.all(
        color: done ? Colors.green.shade600 : Colors.grey.shade400,
        width: 2.5,
      ),
    ),
    child: done
        ? const Icon(
      Icons.check,
      color: Colors.white,
      size: 18,
    )
        : null,
  );

  Widget _buildTitleArea(dynamic t, bool isCompleted, {int maxLines = 2}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        t.title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isCompleted ? Colors.green.shade700 : Colors.grey.shade800,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: Colors.green.shade400,
          decorationThickness: 2,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
      if (t.notes?.isNotEmpty ?? false) ...[
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Text(
            t.notes!,
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ],
  );

  Widget _buildActions(BuildContext context, WidgetRef ref, dynamic t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          tooltip: 'Modifica',
          icon: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 20),
          onPressed: () => showTodoAddDialog(context, ref, preset: t),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          tooltip: 'Elimina',
          icon: Icon(Icons.delete_rounded, color: Colors.red.shade700, size: 20),
          onPressed: () => ref.read(todosProvider.notifier).remove(t.id),
        ),
      ),
    ],
  );

  Widget _infoChip({
    required Color bg,
    required Color border,
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildCategoryChip(Color base, IconData icon, String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: base.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: base.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: base),
        const SizedBox(width: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: base,
          ),
        ),
      ],
    ),
  );

  // Order and filter helper methods removed because UI is inlined above.
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ToggleBtn({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}