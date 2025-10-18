import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/todo_item.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';
import 'package:your_turn/src/widgets/todo/todo_add_dialog.dart';
import 'package:your_turn/src/widgets/todo/empty_state.dart';
import 'package:your_turn/src/widgets/todo/assignees_avatars.dart';
import 'package:your_turn/src/widgets/weather/weather_card.dart';
import 'profile_page.dart';
import 'package:intl/intl.dart';
import 'admin_page.dart';
import 'package:your_turn/src/widgets/common_action_button.dart';

final todosCategoryFilterProvider = StateProvider<TodoCategory?>((ref) => null);

// Provider for "just you" filter
final todosJustYouFilterProvider = StateProvider<bool>((ref) => false);

// Provider for pagination
final currentPageProvider = StateProvider<int>((ref) => 0);
const int todosPerPage = 7; // Aumentato per sfruttare la griglia a 4 colonne (4x6 = 24)

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

  
Widget _buildActionButton(
  BuildContext context, {
  required String letter,
  required String label,
  required MaterialColor color,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color.shade700, width: 2),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 18),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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

    

    return KeyboardListener(
  focusNode: FocusNode(),
  autofocus: true,
  onKeyEvent: (KeyEvent  event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // 🔹 N = apre dialog nuovo To-Do
      if (key == LogicalKeyboardKey.keyN) {
        showTodoAddDialog(context, ref);
      }

      // 🔹 A = vai alla pagina amministratore
      if (key == LogicalKeyboardKey.keyA) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      }

      // 🔹 P = vai alla pagina profilo
      if (key == LogicalKeyboardKey.keyP) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      }

      
    }
  },

  child: Scaffold(
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
                      
                     Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisSize: MainAxisSize.min,
  children: [
    // Pulsante A - Admin
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 46,
        child: _buildActionButton(
          context,
          letter: 'A',
          label: 'ADMIN',
          color: Colors.blue,
          icon: Icons.admin_panel_settings,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPage()),
          ),
        ),
      ),
    ),
    const SizedBox(width: 16),

    // Pulsante P - Profilo
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 46,
        child: _buildActionButton(
          context,
          letter: 'P',
          label: 'PROFILO',
          color: Colors.blue,
          icon: Icons.person,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
        ),
      ),
    ),
  ],
)


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
                    int crossAxisCount = 1;
                    //int crossAxisCount = (screenWidth / minCardWidth).floor();
                    //if (crossAxisCount < 1) crossAxisCount = 1;
                    //if (crossAxisCount > 6) crossAxisCount = 6;
                    
                    // Calcola larghezza effettiva delle card
                    final cardWidth = screenWidth / crossAxisCount;
                    final clampedCardWidth = cardWidth.clamp(minCardWidth, maxCardWidth);
                    
                    // Aspect ratio dinamico per altezza ottimale
                    final aspectRatio = clampedCardWidth /90.0;
                    // Altezza fissa per vedere tutto
                    
                    return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
  (context, index) {
    final t = tasks[index];
    final assigned = roommates.where((r) => t.assigneeIds.contains(r.id)).toList();

    final completedStr = (t.status == TodoStatus.done && t.completedAt != null)
        ? DateFormat('d/M', 'it_IT').format(t.completedAt!.toLocal())
        : null;
    final isCompleted = t.status == TodoStatus.done;
    final dueStr = DateFormat('d/M', 'it_IT').format(t.createdAt.toLocal());

    // ✅ Chiudi qui la funzione builder
    return _buildTodoCard(context, ref, t, roommates);
  },
  // ✅ Poi fuori dalla funzione metti childCount
  childCount: tasks.length,
),

                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 9999,
  mainAxisExtent: 140,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
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
      
      floatingActionButton: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade400, Colors.blue.shade600],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showTodoAddDialog(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade700, width: 2),
              ),
              child: Center(
                child: Text(
                  'N',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'NUOVO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),

    ),);
  }

 Widget _buildTodoCard(BuildContext context, WidgetRef ref, TodoItem t, List<Roommate> roommates) {
  final isCompleted = t.status == TodoStatus.done;
  final createdStr = DateFormat('d MMM yyyy, HH:mm', 'it_IT').format(t.createdAt.toLocal());

  // 👤 Creator (con fallback automatico)
  final creator = roommates.firstWhere(
    (r) => r.id == t.creatorId,
    orElse: () => Roommate(
      id: 'none',
      name: '—',
      photoUrl:
          "https://api.dicebear.com/7.x/adventurer/png?seed=Ale&backgroundColor=ffdfbf,c0aede,d1d4f9&scale=80",
    ),
  );

  // 👥 Assegnati
  final assigned = roommates.where((r) => t.assigneeIds.contains(r.id)).toList();

  return InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () => ref.read(todosProvider.notifier).toggleDone(t.id),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade300,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.7),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  physics: const BouncingScrollPhysics(),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Checkbox
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: _buildCheckbox(isCompleted),
          ),

          // TITOLO
          ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 250),
            child: Text(
              t.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isCompleted ? Colors.grey.shade600 : Colors.black87,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          // CATEGORIE (mostra tutte le categorie come chips)
          ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final cat in t.categories)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _hexColor(cat.color),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            cat.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // COSTO (chip)
          ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 250),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.euro_rounded, size: 14, color: Colors.green.shade800),
                    const SizedBox(width: 4),
                    Text(
                      t.cost != null ? t.cost!.toStringAsFixed(2) : '—',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // DATA (chip) + etichetta 'Creato il' in bold sotto
          ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'Data creazione ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800, fontSize: 12)),
                     
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        createdStr,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                
              ],
            ),
          ),

          // 👤 CREATORE (avatar + nome) - migliorata leggibilit e0
          ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 250),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: creator.photoUrl != null && creator.photoUrl!.isNotEmpty
                      ? NetworkImage(creator.photoUrl!)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: (creator.photoUrl == null || creator.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 120, maxWidth: 250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        creator.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                      ),
                      Text('Autore', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 👥 ASSEGNATI (avatar compact + label)
          ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 250),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Assegnato a:', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        for (int i = 0; i < assigned.length && i < 4; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Tooltip(
                              message: assigned[i].name,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(assigned[i].photoUrl ?? ''),
                                backgroundColor: Colors.grey.shade200,
                                child: assigned[i].photoUrl == null ? const Icon(Icons.person, size: 16, color: Colors.grey) : null,
                              ),
                            ),
                          ),
                        if (assigned.length > 4)
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text('+${assigned.length - 4}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AZIONI
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue.shade600),
                onPressed: () => showTodoAddDialog(context, ref, preset: t),
                tooltip: 'Modifica',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade400),
                onPressed: () => ref.read(todosProvider.notifier).remove(t.id),
                tooltip: 'Elimina',
              ),
            ],
          ),
        ],
      ),
    ),
  ),);
}



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
          color: Colors.blue.shade100,
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
