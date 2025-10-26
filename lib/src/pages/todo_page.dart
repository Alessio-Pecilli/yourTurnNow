import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/l10n/app_localizations.dart';
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
// removed duplicate import
import 'package:your_turn/src/providers/locale_provider.dart';


final todosCategoryFilterProvider = StateProvider<TodoCategory?>((ref) => null);

// Provider for "just you" filter
final todosJustYouFilterProvider = StateProvider<bool>((ref) => false);

// Provider for pagination
final currentPageProvider = StateProvider<int>((ref) => 0);
const int todosPerPage = 10; // Aumentato per sfruttare la griglia a 4 colonne (4x6 = 24)

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


class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  late FocusNode _keyboardFocusNode;

@override
void initState() {
  super.initState();
  _keyboardFocusNode = FocusNode();
  // assegna subito il focus alla pagina
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _keyboardFocusNode.requestFocus();
  });
}

@override
void dispose() {
  _keyboardFocusNode.dispose();
  super.dispose();
}

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
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
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
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;

    final categories = ref.watch(categoriesProvider);
    final tasks = ref.watch(paginatedTodosProvider);
    final allTasks = ref.watch(filteredTodosProvider);
    final currentPage = ref.watch(currentPageProvider);
    final totalPages = ref.watch(totalPagesProvider);
    final roommates = ref.watch(roommatesProvider);
    final Map<int, TableColumnWidth> kTodoColumnWidths = {
  0: FlexColumnWidth(0.6),
  1: FlexColumnWidth(2.5),
  2: FlexColumnWidth(2.0),
  3: FlexColumnWidth(1.2),
  4: FlexColumnWidth(1.6),
  5: FlexColumnWidth(1.4),
  6: FlexColumnWidth(1.4),
  7: FlexColumnWidth(1.0),
};
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
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
  if (event is KeyDownEvent) {
    // 🔒 Evita di catturare tasti quando stai scrivendo
    if (FocusManager.instance.primaryFocus != null &&
        FocusManager.instance.primaryFocus!.context?.widget is EditableText) {
      return;
    }

    final key = event.logicalKey;

    // 🔹 N = apre dialog nuovo To-Do
    if (key == LogicalKeyboardKey.keyN) {
  showTodoAddDialog(context, ref);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _keyboardFocusNode.requestFocus();
  });
}

    // 🔹 A = vai alla pagina amministratore
    if (key == LogicalKeyboardKey.keyA) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      ).then((_) {
        // 👇 Quando torni indietro, riprendi il focus
        _keyboardFocusNode.requestFocus();
      });
    }

    // 🔹 P = vai alla pagina profilo
    if (key == LogicalKeyboardKey.keyP) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      ).then((_) {
        // 👇 Riprendi focus anche qui
        _keyboardFocusNode.requestFocus();
      });
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
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Meteo a sinistra
          const CompactWeather(city: 'Roma,IT'),

          // Pulsanti a destra
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsante A - Admin
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildActionButton(
                  context,
                  letter: 'A',
                  label: AppLocalizations.of(context)!.nav_admin,
                  color: Colors.blue,
                  icon: Icons.admin_panel_settings,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPage()),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Pulsante P - Profilo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildActionButton(
                  context,
                  letter: 'P',
                  label: AppLocalizations.of(context)!.nav_profile,
                  color: Colors.blue,
                  icon: Icons.person,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Language switcher
              Container(
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.blue.shade200),
  ),
  child: IconButton(
    tooltip: AppLocalizations.of(context)!.common_language,
    icon: const Icon(Icons.language, color: Colors.white),
    onPressed: () {
      final current = ref.read(localeProvider);
      // se è italiano → passa a inglese, altrimenti torna italiano
      final newLocale = (current.languageCode == 'it')
          ? const Locale('en')
          : const Locale('it');
      ref.read(localeProvider.notifier).state = newLocale;
    },
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
                    child:
                    Center(
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
                              children: [
                                _ToggleBtn(icon: Icons.list, text: AppLocalizations.of(context)!.todos_filter_all),
                                _ToggleBtn(icon: Icons.check_circle, text: AppLocalizations.of(context)!.todos_filter_done),
                                _ToggleBtn(icon: Icons.radio_button_unchecked, text: AppLocalizations.of(context)!.todos_filter_open),
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
                              children: [
                                _ToggleBtn(icon: Icons.calendar_today, text: AppLocalizations.of(context)!.todos_order_date),
                                _ToggleBtn(icon: Icons.euro, text: AppLocalizations.of(context)!.todos_order_cost),
                                _ToggleBtn(icon: Icons.add_circle, text: AppLocalizations.of(context)!.todos_order_new),
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
                                    Text(AppLocalizations.of(context)!.categories_all),
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
                    ),),
                  ),
                ),
              ),
            ),

            // Lista task con separatore manuale (compatibile con Flutter stabile)
            if (tasks.isEmpty)
              const EmptyStateSliver()
            else
            SliverPersistentHeader(
  pinned: true,
  delegate: _FixedHeaderDelegate(
    height: 80, // altezza della riga header
    child: buildTodoHeaderRow(context),
  ),
),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    // Calcola dimensioni dinamiche per i todo
                    final screenWidth = constraints.crossAxisExtent;
                    final minCardWidth = 100.0; // Larghezza minima per leggibilità
                    final maxCardWidth = 300.0; // Larghezza massima
                    
                    // Calcola numero ottimale di colonne
                    int crossAxisCount = 1;
                    //int crossAxisCount = (screenWidth / minCardWidth).floor();
                    //if (crossAxisCount < 1) crossAxisCount = 1;
                    //if (crossAxisCount > 6) crossAxisCount = 6;
                    
                    // Calcola larghezza effettiva delle card
                    final cardWidth = screenWidth / crossAxisCount;
                    final clampedCardWidth = cardWidth.clamp(minCardWidth, maxCardWidth);
                    
                    // Aspect ratio dinamico per altezza ottimale
                    final aspectRatio = clampedCardWidth /5.0;
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
  maxCrossAxisExtent: 2000,
  mainAxisExtent: 80, // Altezza fissa per vedere tutto
  mainAxisSpacing: 4/3,
  crossAxisSpacing: 4,
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
                  '${tasks.length} / ${allTasks.length} to-do ${totalPages > 1 ? ' (${currentPage + 1} / $totalPages)' : ''}',
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
      
      floatingActionButton: SizedBox(
  child: _buildActionButton(
    context,
    letter: 'N',
  label: AppLocalizations.of(context)!.nav_new,
    color: Colors.blue,
    icon: Icons.add, // o qualunque icona vuoi, anche Icons.add_circle_outline
    onTap: () => showTodoAddDialog(context, ref),
  ),
),

    ),);
  }


 Widget _buildTodoCard(BuildContext context, WidgetRef ref, TodoItem t, List<Roommate> roommates) {
  final isCompleted = t.status == TodoStatus.done;
  final createdStr = DateFormat('d MMM yyyy, HH:mm', 'it_IT').format(t.createdAt.toLocal());

  final creator = roommates.firstWhere(
    (r) => r.id == t.creatorId,
    orElse: () => Roommate(
      id: 'none',
      name: '—',
      photoUrl:
          "https://api.dicebear.com/7.x/adventurer/png?seed=Ale&backgroundColor=ffdfbf,c0aede,d1d4f9&scale=80",
    ),
  );

  final assigned = roommates.where((r) => t.assigneeIds.contains(r.id)).toList();

  return InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () => ref.read(todosProvider.notifier).toggleDone(t.id),
    
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade300,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.6),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),

      // 🔹 Altezza fissa e centratura verticale
      child: SizedBox(
        width: double.infinity,
        height: 128, // Altezza fissa per centratura verticale
         child: Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 1300, // 
        ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths:  {
  0: FlexColumnWidth(0.6),
  1: FlexColumnWidth(2.5),
  2: FlexColumnWidth(2.0),
  3: FlexColumnWidth(1.2),
  4: FlexColumnWidth(1.6),
  5: FlexColumnWidth(1.4),
  6: FlexColumnWidth(1.4),
  7: FlexColumnWidth(0.5),
},
            children: [
              TableRow(
                children: [
                // ✅ Checkbox
                Center(child: _buildCheckbox(isCompleted)),

                // ✅ Titolo
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.title.length > 28 ? '${t.title.substring(0, 28)}...' : t.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isCompleted ? Colors.grey.shade600 : Colors.black87,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),

                // ✅ Categorie
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(builder: (_) {
                    final cats = t.categories;
                    final visible = cats.take(2).toList();
                    final extra = cats.length - visible.length;

                    return Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center, // 🔥 centratura verticale
                      spacing: 6,
                      runSpacing: 3,
                      children: [
                        for (final cat in visible)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _hexColor(cat.color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center, // 🔥 centratura verticale
                              children: [
                                Icon(cat.icon, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (extra > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('+$extra', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ),
                      ],
                    );
                  }),
                ),

                // ✅ Costo
                Align(
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
                      crossAxisAlignment: CrossAxisAlignment.center, // 🔥 centratura verticale
                      children: [
                        Icon(Icons.euro_rounded, size: 15, color: Colors.green.shade800),
                        const SizedBox(width: 4),
                        Text(
                          t.cost != null ? t.cost!.toStringAsFixed(2) : '—',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Data
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center, // 🔥 centratura verticale
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        Text(
                          createdStr,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Creatore
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 🔥 centratura verticale
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: creator.photoUrl != null && creator.photoUrl!.isNotEmpty
                            ? NetworkImage(creator.photoUrl!)
                            : null,
                        backgroundColor: Colors.grey.shade300,
                        child: (creator.photoUrl == null || creator.photoUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          creator.name.length > 10 ? '${creator.name.substring(0, 10)}...' : creator.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Assegnati
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 🔥 centratura verticale
                    children: [
                      for (int i = 0; i < assigned.length && i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 13,
                            backgroundImage: NetworkImage(assigned[i].photoUrl ?? ''),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      if (assigned.length > 3)
                        Text(
                          '+${assigned.length - 3}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),

                // ✅ Azioni
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center, // 🔥 centratura verticale
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade600, size: 20),
                        tooltip: AppLocalizations.of(context)!.common_edit,
                        onPressed: () => showTodoAddDialog(context, ref, preset: t),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                        tooltip: AppLocalizations.of(context)!.common_delete,
                        onPressed: () => ref.read(todosProvider.notifier).remove(t.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    )))
  );
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
          tooltip: AppLocalizations.of(context)!.common_edit,
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
          tooltip: AppLocalizations.of(context)!.common_delete,
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

Widget buildTodoHeaderRow(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4, // ombra
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // bordi arrotondati
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Center(
            child: SizedBox(
              width: 1300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1300),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(0.6),
                      1: FlexColumnWidth(2.5),
                      2: FlexColumnWidth(2.0),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.6),
                      5: FlexColumnWidth(1.4),
                      6: FlexColumnWidth(1.4),
                      7: FlexColumnWidth(0.5),
                    },
                    children: [
                      TableRow(
                        children: [
                          const _HeaderCell(''),
                          _HeaderCell(AppLocalizations.of(context)!.table_title),
                          _HeaderCell(AppLocalizations.of(context)!.table_categories),
                          _HeaderCell(AppLocalizations.of(context)!.table_cost),
                          _HeaderCell(AppLocalizations.of(context)!.table_date),
                          _HeaderCell(AppLocalizations.of(context)!.table_creator),
                          _HeaderCell(AppLocalizations.of(context)!.table_assignees),
                          const _HeaderCell(''),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}



class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _FixedHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
    height: height, // rispetta l’altezza impostata
    child: child,
  );
  }

  @override
  bool shouldRebuild(covariant _FixedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center( // <-- centra verticalmente e orizzontalmente
      child: Align(
        alignment: Alignment.centerLeft, // resta a sinistra, ma centrato in verticale
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }
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
