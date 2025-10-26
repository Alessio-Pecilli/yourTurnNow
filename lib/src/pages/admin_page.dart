import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:your_turn/l10n/app_localizations.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/pages/profile_page.dart';
import 'package:your_turn/src/pages/todo_page.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:your_turn/src/services/csv_export_service.dart';
import 'package:your_turn/src/services/pdf_export_service.dart';

import 'package:your_turn/src/utils/csv_web_download_stub.dart'
  if (dart.library.html) 'package:your_turn/src/utils/csv_web_download.dart';

// Modular admin widgets
import 'package:your_turn/src/widgets/admin/pie_chart.dart';

import 'package:your_turn/src/widgets/admin/cards.dart';
import 'package:your_turn/src/widgets/common_action_button.dart';
import 'package:your_turn/l10n/app_localizations.dart';



// Classe per l'Intent della shortcut download
class _DownloadIntent extends Intent {
  const _DownloadIntent();
}

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  // Per aggiunta/modifica
  final _roommateController = TextEditingController();
  final _categoryNameController = TextEditingController();
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

String? _selectedColorHex = '#2196F3'; // Blu di default
// Ã°Å¸â€Â¹ tiene traccia del colore selezionato (in HEX)

  final _focusNode = FocusNode(); // Per keyboard shortcuts
  String? _selectedIconKey;
  String _selectedColor = '#2196F3';
  static const Map<String, IconData> _iconByKey = {
    'shopping_cart': Icons.shopping_cart,
    'kitchen': Icons.kitchen,
    'cleaning_services': Icons.cleaning_services,
    'receipt_long': Icons.receipt_long,
    'celebration': Icons.celebration,
    'build': Icons.build,
    'notes': Icons.notes,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,
    'restaurant': Icons.restaurant,
    'local_grocery_store': Icons.local_grocery_store,
    'fitness_center': Icons.fitness_center,
    'pets': Icons.pets,
    'medical_services': Icons.medical_services,
    'directions_car': Icons.directions_car,
    'flight': Icons.flight,
    'movie': Icons.movie,
    'music_note': Icons.music_note,
    'sports_soccer': Icons.sports_soccer,
    'beach_access': Icons.beach_access,
    'nature': Icons.nature,
    'computer': Icons.computer,
    'phone': Icons.phone,
  };

  // Colori predefiniti con nomi accessibili
  final List<Map<String, String>> _availableColors = [
    {'hex': '#2196F3', 'name': 'Blu'},
    {'hex': '#FF9800', 'name': 'Arancione'},
    {'hex': '#F44336', 'name': 'Rosso'},
    {'hex': '#9C27B0', 'name': 'Viola'},
    {'hex': '#E91E63', 'name': 'Rosa'},
    {'hex': '#00BCD4', 'name': 'Ciano'},
    {'hex': '#8BC34A', 'name': 'Verde chiaro'},
    {'hex': '#FFC107', 'name': 'Giallo'},
    {'hex': '#795548', 'name': 'Marrone'},
  ];








  @override
  void dispose() {
    _roommateController.dispose();
    _categoryNameController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // hex color conversion is provided by widgets where needed


  // Funzione per scaricare i dati dei grafici in formato CSV

  

  
  String _escapeCSV(String text) {
    if (text.contains(';') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final roommates = ref.watch(roommatesProvider);
    final user = ref.read(userProvider);
        final currentMe = roommates.firstWhere(
              (r) => r.id == user?.id,
              orElse: () => Roommate(id: user?.id ?? 'me', name: user?.name ?? AppLocalizations.of(context)!.profile_you),
            );
    return KeyboardListener(
  focusNode: _keyboardFocusNode,
  autofocus: true,
  onKeyEvent: (KeyEvent event) {
  if (event is KeyDownEvent) {
    // Ã°Å¸â€â€™ Evita di triggerare shortcut quando scrivi in un TextField
    if (FocusManager.instance.primaryFocus != null &&
        FocusManager.instance.primaryFocus!.context?.widget is EditableText) {
      return;
    }

    final key = event.logicalKey;

    // Ã°Å¸â€Â¹ P = vai alla pagina profilo
    if (key == LogicalKeyboardKey.keyP) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      ).then((_) {
        // Ã°Å¸â€˜â€¡ Riprendi focus quando torni indietro
        _keyboardFocusNode.requestFocus();
      });
    }

    // Ã°Å¸â€Â¹ H = vai alla pagina To-Do
    if (key == LogicalKeyboardKey.keyH) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TodoPage()),
      ).then((_) {
        // Ã°Å¸â€˜â€¡ Riprendi focus quando torni indietro
        _keyboardFocusNode.requestFocus();
      });
    }

    // Ã°Å¸â€Â¹ D = download dati grafici
    if (key == LogicalKeyboardKey.keyD) {
      _downloadChartsData();
      // Ã°Å¸â€˜â€¡ Reimposta focus anche dopo un download o un popup
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _keyboardFocusNode.requestFocus();
      });
    }
  }
},

  child: Shortcuts(
    shortcuts: <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyG):
          const _DownloadIntent(),
    },
    child: Actions(
      actions: <Type, Action<Intent>>{
        _DownloadIntent: CallbackAction<_DownloadIntent>(
          onInvoke: (intent) => _downloadChartsData(),
        ),
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
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 800;
                        if (isWide) {
                          return Column(
                            children: [
                              _buildExpensesChartCard(),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildCategoriesCard()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildRoommatesCard(roommates)),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildExpensesChartCard(),
                              const SizedBox(height: 16),
                              _buildCategoriesCard(),
                              const SizedBox(height: 16),
                              _buildRoommatesCard(roommates),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
 


  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading:null,
      actions: [
  Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Pulsante TO-DO
        SizedBox(
          height: 46,
          child: _buildActionButton(
            context,
            letter: 'H',
            label: AppLocalizations.of(context)!.nav_todo,
            color: Colors.blue,
            icon: Icons.check_circle_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TodoPage()),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Pulsante PROFILO
        SizedBox(
          height: 46,
          child: _buildActionButton(
            context,
            letter: 'P',
            label: AppLocalizations.of(context)!.nav_profile,
            color: Colors.blue,
            icon: Icons.person,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Pulsante DOWNLOAD
        SizedBox(
          height: 46,
          child: _buildActionButton(
            context,
            letter: 'D',
            label: AppLocalizations.of(context)!.nav_download,
            color: Colors.blue,
            icon: Icons.download_rounded,
            onTap: () {
              _downloadChartsData();
            },
          ),
        ),
      ],
    ),
  ),
],

    );
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
  Widget _buildExpensesChartCard() {
    final todos = ref.watch(todosProvider);
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.pdf_expenses_by_category_title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Layout responsive: 3 colonne su desktop, stack su mobile
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                if (isWide) {
                  // Desktop: 3 colonne affiancate
                  return Row(
                    children: [
                      Expanded(child: _buildSingleChart(AppLocalizations.of(context)!.admin_chart_todo_done, todos, true, Colors.green)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSingleChart(AppLocalizations.of(context)!.admin_chart_todo_open, todos, false, Colors.blue)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSingleChart(AppLocalizations.of(context)!.admin_chart_total_budget, todos, null, Colors.orange)),
                    ],
                  );
                } else {
                  // Mobile: stack verticale
                  return Column(
                    children: [
                      _buildSingleChart(AppLocalizations.of(context)!.admin_chart_todo_done, todos, true, Colors.green),
                      const SizedBox(height: 24),
                      _buildSingleChart(AppLocalizations.of(context)!.admin_chart_todo_open, todos, false, Colors.blue),
                      const SizedBox(height: 24),
                      _buildSingleChart(AppLocalizations.of(context)!.admin_chart_total_budget, todos, null, Colors.orange),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleChart(String title, List<dynamic> todos, bool? isCompleted, MaterialColor themeColor) {
    // Filtra i todo in base al tipo di grafico usando la logica corretta
    List<dynamic> filteredTodos;
    if (isCompleted == null) {
      // Tutti i todo (budget totale)
      filteredTodos = todos;
    } else if (isCompleted) {
      // Solo todo completati: TodoStatus.done
      filteredTodos = todos.where((t) => t.status == TodoStatus.done).toList();
    } else {
      // Solo todo da fare: TodoStatus.open
      filteredTodos = todos.where((t) => t.status == TodoStatus.open).toList();
    }
    
    // Calcola le spese per categoria
    final Map<String, double> expensesByCategory = {};
    for (final todo in filteredTodos) {
      if (todo.cost != null && todo.cost! > 0) {
        for (final category in todo.categories) {
          final categoryName = category.name;
          double amount = todo.cost!;
          
          // Per il budget totale, usa il modulo
          if (isCompleted == null) {
            amount = amount.abs();
          }
          
          expensesByCategory[categoryName] = (expensesByCategory[categoryName] ?? 0) + amount;
        }
      }
    }
    
    final List<ExpenseSlice> slices = expensesByCategory.entries.map((entry) {
      return ExpenseSlice(
        category: entry.key,
        amount: entry.value,
        color: _getCategoryColor(entry.key, themeColor),
      );
    }).toList();
    
    // Ordina per importo decrescente
    slices.sort((a, b) => b.amount.compareTo(a.amount));
    
    final double totalAmount = slices.fold(0, (sum, slice) => sum + slice.amount);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: themeColor.shade50,
      child: Container(
        height: 420, // Aumentata per contenere tutto senza scroll
        padding: const EdgeInsets.all(20), // Material Design 3 spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo con icona tematica
            Row(
              children: [
                Icon(
                  isCompleted == true ? Icons.check_circle : 
                  isCompleted == false ? Icons.schedule : Icons.pie_chart,
                  color: themeColor.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: themeColor.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Material Design 3 standard spacing
            
            if (slices.isEmpty) ...[
              // Stato vuoto con dimensioni fisse per consistenza
              Container(
                height: 160, // Ridotto da 200 a 160
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart_outline_outlined,
                        size: 48,
                        color: themeColor.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.no_data_available,
                        style: TextStyle(
                          color: themeColor.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Aggiungi altezza extra per mantenere consistenza
              const SizedBox(height: 12), // Ridotto da 20 a 12
              Container(
                height: 100, // Ridotto da 120 a 100
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.no_data_available,
                    style: TextStyle(
                      color: themeColor.shade500,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ] else ...[
              // Grafico a torta grande
              Container(
                height: 180, // Ottimizzato per visibilitÃƒÂ  completa
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180), // Bilanciato per visibilitÃƒÂ 
                      painter: PieChartPainter(slices, totalAmount),
                    ),
                    // Centro del grafico con totale
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.total_label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeColor.shade600,
                            ),
                          ),
                          Text(
                            '${totalAmount.toStringAsFixed(0)} EUR',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeColor.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12), // Spazio adeguato per Material Design 3
              
              // Legenda a griglia per mostrare tutte le categorie
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 colonne per vedere piÃƒÂ¹ categorie
                    childAspectRatio: 3.2, // PiÃƒÂ¹ spazio per leggibilitÃƒÂ  (a11y)
                    crossAxisSpacing: 8, // Material Design 3 spacing
                    mainAxisSpacing: 8,
                  ),
                  itemCount: slices.length,
                  itemBuilder: (context, index) {
                    final slice = slices[index];
                    final percentage = (slice.amount / totalAmount * 100);
                    return Semantics(
                      label: AppLocalizations.of(context)!.pie_label_amount_of_total.replaceFirst('{category}', slice.category).replaceFirst('{amount}', slice.amount.toStringAsFixed(2)).replaceFirst('{percent}', percentage.toStringAsFixed(1)),
                      hint: AppLocalizations.of(context)!.pie_hint_category_for.replaceFirst('{title}', title.toLowerCase()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Material Design 3 touch target
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12), // Material Design 3 corner radius
                          border: Border.all(color: themeColor.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12, // Dimensione minima accessibile
                              height: 12,
                              decoration: BoxDecoration(
                                color: slice.color,
                                borderRadius: BorderRadius.circular(3), // Material Design 3
                                boxShadow: [
                                  BoxShadow(
                                    color: slice.color.withOpacity(0.3),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // Material Design 3 spacing
                            Expanded(
                              child: Text(
                                slice.category,
                                style: TextStyle(
                                  fontSize: 12, // Dimensione accessibile (min 12px)
                                  fontWeight: FontWeight.w500,
                                  color: themeColor.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11, // Dimensione accessibile
                                fontWeight: FontWeight.w500,
                                color: themeColor.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ], // Fine dell'else condizionale
          ], // Fine del children della Column alla riga 485
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName, MaterialColor themeColor) {
    final colorVariations = [
      themeColor.shade700,
      themeColor.shade600,
      themeColor.shade500,
      themeColor.shade800,
      themeColor.shade400,
      themeColor.shade300,
      themeColor.shade900,
      themeColor.shade200,
    ];
    return colorVariations[categoryName.hashCode % colorVariations.length];
  }

  
  Widget _buildCategoriesCard() {
    final categories = ref.watch(categoriesProvider);
    return CategoriesCard(
      categories: categories,
      onAddCategory: () {},
      onAddCategoryPressed: () => _showAddCategoryDialog(context), // Non piÃƒÂ¹ dialog, selezione inline
      onDelete: (c) => _confirmDeleteCategory(c),
    );
  }
  
  void _showAddCategoryDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      String? selectedIconKey = _selectedIconKey;
      String? selectedColorHex = _selectedColorHex;

      return StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFFF3F1F8), // lilla chiaro come nel tuo screen
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo
                Text(
                  AppLocalizations.of(context)!.admin_add_category,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 14),

                // Campo nome
                TextField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.admin_category_name,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade500, width: 1.8),
                    ),
                    prefixIcon: Icon(Icons.label, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: TextStyle(color: Colors.grey.shade800),
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 18),

                //  icona
                Text(
                  AppLocalizations.of(context)!.select_icon,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),

                Center(
  child: IntrinsicWidth(
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: _iconByKey.entries.map((entry) {
        final iconKey = entry.key;
        final iconData = entry.value;
        final isSelected = selectedIconKey == iconKey;

        return GestureDetector(
          onTap: () => setStateDialog(() => selectedIconKey = iconKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              iconData,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              size: 20,
            ),
          ),
        );
      }).toList(),
    ),
  ),
),

                const SizedBox(height: 20),

                // Seleziona colore
                Text(
                  AppLocalizations.of(context)!.select_color,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  children: _availableColors.map((colorMap) {
                    final hex = colorMap['hex']!;
                    final color = Color(int.parse(hex.substring(1, 7), radix: 16) + 0xFF000000);
                    final isSelected = selectedColorHex == hex;

                    return GestureDetector(
                      onTap: () => setStateDialog(() => selectedColorHex = hex),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                // Pulsanti in basso
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      child: Text(AppLocalizations.of(context)!.common_cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final name = _categoryNameController.text.trim();
                        if (name.isEmpty || selectedIconKey == null) {
                          _showErrorDialog(AppLocalizations.of(context)!.error_operation_not_allowed, AppLocalizations.of(context)!.error_name_icon_required);
                          return;
                        }

                        ref.read(categoriesProvider.notifier).addCategory(
                              TodoCategory(
                                id: DateTime.now().toString(),
                                name: name,
                                icon: _iconByKey[selectedIconKey]!,
                                color: selectedColorHex ?? _selectedColor,
                              ),
                            );

                        _categoryNameController.clear();
                        _selectedIconKey = null;
                        _selectedColorHex = selectedColorHex ?? _selectedColorHex;
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:  Colors.blue.shade700, // blu scuro ma piÃƒÂ¹ neutro
                        minimumSize: const Size(100, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(AppLocalizations.of(context)!.common_add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}




Widget _buildAddRoommateForm({
  bool showInlineButton = true,
  ValueChanged<String>? onChanged,
}) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  final accent = Colors.blue.shade700;

  return Card(
    elevation: 3,
    shadowColor: Colors.grey.shade200,
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: accent.withOpacity(0.4), width: 1),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          final name = _roommateController.text.trim();
          final canSubmit = name.isNotEmpty;
          
          final avatarBg = _pastelFor(name.isEmpty ? 'A' : name, cs);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar con tinta blu pastello
                  
                  const SizedBox(width: 12),

                  // Campo di testo elegante
                  Expanded(
                    child: TextField(
                      controller: _roommateController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onChanged: (v) {
                        setInnerState(() {});
                        if (onChanged != null) onChanged(v);
                      },
                      onSubmitted: (_) {
                        if (canSubmit) {
                          _addRoommate();
                          Navigator.of(context).pop();
                        }
                      },
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.admin_roommate_name,
                        hintStyle: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: cs.surface,
                        prefixIcon: Icon(Icons.person_outline,
                            color: accent.withOpacity(0.8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: accent.withOpacity(0.4), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: accent.withOpacity(0.4), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pulsanti azione
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                      textStyle: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.common_cancel),
                  ),
                  const SizedBox(width: 6),
                  FilledButton(
                    onPressed: canSubmit
                        ? () {
                            _addRoommate();
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      disabledBackgroundColor:
                          accent.withOpacity(0.2), // disattivo soft blu
                      minimumSize: const Size(46, 46),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(AppLocalizations.of(context)!.common_add),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}




Color _pastelFor(String seed, ColorScheme cs) {
  // semplice hash Ã¢â€ â€™ tonalitÃƒÂ  primaria "pastellata"
  final h = seed.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0xFFFFFFFF);
  final t = 0.2 + (h % 60) / 300.0; // 0.2..0.4 blending
  // blend verso primary per rimanere nel tema
  return Color.lerp(cs.primary, cs.surface, 1 - t)!;
}

// Helpers (mettile nella stessa State class)
String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'A';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
}





  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8,
      children: _availableColors.map((colorData) {
        final colorHex = colorData['hex']!;
        final colorName = colorData['name']!;
        final isSelected = colorHex == _selectedColor;
        return Semantics(
          label: AppLocalizations.of(context)!.color_label.replaceFirst('{name}', colorName),
          selected: isSelected,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedColor = colorHex);
              HapticFeedback.selectionClick();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hexToColor(colorHex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black87 : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ] : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
  Widget _buildIconGrid() {
    final iconKeys = _iconByKey.keys.toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 12, // 12 colonne
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 24, // Esattamente 24 icone (2 righe x 12)
        itemBuilder: (context, index) {
          if (index >= iconKeys.length) return const SizedBox.shrink();
          
          final iconKey = iconKeys[index];
          final isSelected = _selectedIconKey == iconKey;
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIconKey = iconKey);
              HapticFeedback.selectionClick();
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.green.shade700.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                _iconByKey[iconKey],
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }


  

  void _addRoommate() {
    if (_roommateController.text.trim().isNotEmpty) {
      // Use provider to add new roommate with random avatar
      ref.read(roommatesProvider.notifier).ensure(
        DateTime.now().toString(),
        name: _roommateController.text.trim(),
        photoUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=${_roommateController.text.trim()}&backgroundColor=ffd5dc,b6e3f4,ffdfbf&scale=80',
      );
      _roommateController.clear();
      HapticFeedback.lightImpact();
    }
  }

  void _addCategory() {
    if (_categoryNameController.text.trim().isNotEmpty && _selectedIconKey != null) {
      ref.read(categoriesProvider.notifier).addCategory(TodoCategory(
        id: DateTime.now().toString(),
        name: _categoryNameController.text.trim(),
        icon: _iconByKey[_selectedIconKey!]!,
        color: _selectedColor,
      ));
      _categoryNameController.clear();
      _selectedIconKey = null;
      HapticFeedback.lightImpact();
    }
  }

  Widget _buildRoommatesCard(List<Roommate> roommates) {
    return RoommatesCard(
      roommates: roommates,
      onEdit: (r) => _editRoommate(r),
      onDelete: (r) => _confirmDeleteRoommate(r),
      onAddRoommatePressed: () => _showAddRoommateDialog(context),

    );
  }

  void _showAddRoommateDialog(BuildContext context) {
  _roommateController.clear(); // reset prima dellÃ¢â‚¬â„¢apertura

  showDialog(
    context: context,
    builder: (context) => Theme(
      data: ThemeData.light(useMaterial3: true),
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.admin_add_roommate,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _roommateController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.admin_roommate_name,
                labelStyle: TextStyle(color: Colors.grey.shade700),
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon:
                    Icon(Icons.person, color: Colors.blue.shade600),
              ),
              style: TextStyle(color: Colors.grey.shade800),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _confirmAddRoommate(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              _roommateController.clear();
            },
            child: Text(
              AppLocalizations.of(context)!.common_cancel,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          FilledButton(
            onPressed: () => _confirmAddRoommate(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.common_add),
          ),
        ],
      ),
    ),
  );
}

void _confirmAddRoommate(BuildContext context) {
  final name = _roommateController.text.trim();

  if (name.isEmpty) {
    _showErrorDialog(AppLocalizations.of(context)!.error_operation_not_allowed, AppLocalizations.of(context)!.error_name_icon_required);
    
    return; // evita di proseguire
  }

  // Se non ÃƒÂ¨ vuoto, aggiunge normalmente
  _addRoommate();
  _roommateController.clear();
  context.pop();
  HapticFeedback.lightImpact();
}





  void _editRoommate(Roommate roommate) {
    _roommateController.text = roommate.name;
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.admin_edit_roommate, 
                   style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roommateController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.admin_roommate_name,
                  labelStyle: TextStyle(color: Colors.grey.shade700),
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(Icons.person, color: Colors.blue.shade600),
                ),
                style: TextStyle(color: Colors.grey.shade800),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _saveRoommateEdit(roommate),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
                _roommateController.clear();
              },
              child: Text(AppLocalizations.of(context)!.common_cancel, style: TextStyle(color: Colors.grey.shade600)),
            ),
            FilledButton(
              onPressed: () => _saveRoommateEdit(roommate),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context)!.common_save),
            ),
          ],
        ),
      ),
    );
  }

  void _saveRoommateEdit(Roommate roommate) {
    if (_roommateController.text.isNotEmpty) {
      // Use provider to update roommate
      ref.read(roommatesProvider.notifier).ensure(
        roommate.id,
        name: _roommateController.text,
        photoUrl: roommate.photoUrl,
      );
      _roommateController.clear();
      context.pop();
      HapticFeedback.lightImpact();
    }else{
      _showErrorDialog(AppLocalizations.of(context)!.error_operation_not_allowed, AppLocalizations.of(context)!.error_name_icon_required);
    }
  }



  void _confirmDeleteRoommate(Roommate roommate) {
    final currentUser = ref.read(userProvider);
    final allTodos = ref.read(todosProvider);
    
    // Controlla se ÃƒÂ¨ l'utente attualmente loggato
    if (currentUser?.id == roommate.id) {
      _showErrorDialog(AppLocalizations.of(context)!.error_operation_not_allowed, AppLocalizations.of(context)!.error_cannot_delete_logged_in);
      return;
    }
    
    // Controlla se l'utente ha to-do assegnati
    final hasAssignedTodos = allTodos.any((todo) => todo.assigneeIds.contains(roommate.id));
    if (hasAssignedTodos) {
      _showErrorDialog(AppLocalizations.of(context)!.error_cannot_delete, AppLocalizations.of(context)!.error_roommate_in_use.replaceFirst('{name}', roommate.name));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.confirm_delete_title, style: TextStyle(color: Colors.grey.shade800)),
          ],
        ),
        content: Text(AppLocalizations.of(context)!.confirm_delete_roommate.replaceFirst('{name}', roommate.name), 
                     style: TextStyle(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context)!.common_cancel, style: TextStyle(color: Colors.grey.shade600)),
          ),
          FilledButton(
            onPressed: () {
              // Use provider to remove roommate
              ref.read(roommatesProvider.notifier).remove(roommate.id);
              context.pop();
              HapticFeedback.lightImpact();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.common_delete),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(TodoCategory category) {
    final allTodos = ref.read(todosProvider);
    
    // Controlla se la categoria è in uso in qualche to-do
    final isInUse = allTodos.any((todo) => todo.categories.any((cat) => cat.id == category.id));
    if (isInUse) {
      _showErrorDialog(AppLocalizations.of(context)!.error_cannot_delete, AppLocalizations.of(context)!.error_category_in_use.replaceFirst('{name}', category.name));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            Text('Conferma eliminazione', style: TextStyle(color: Colors.grey.shade800)),
          ],
        ),
        content: Text(AppLocalizations.of(context)!.confirm_delete_category.replaceFirst('{name}', category.name),
                      style: TextStyle(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context)!.common_cancel, style: TextStyle(color: Colors.grey.shade600)),
          ),
          FilledButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).removeCategory(category.id);
              context.pop();
              HapticFeedback.lightImpact();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.common_delete),
          ),
        ],
      ),
    );
  }

    Future<void> _downloadChartsData() async {

      String sanitize(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F6FF}'
      r'\u{1F900}-\u{1F9FF}'
      r'\u{2600}-\u{26FF}'
      r'\u{2700}-\u{27BF}'
      r'\u{1F1E6}-\u{1F1FF}'
      r'\u{1F700}-\u{1F77F}]',
      unicode: true,
    );
    return text.replaceAll(emojiRegex, '');
  }
      
  final todos = ref.read(todosProvider);
  final roommates = ref.read(roommatesProvider);

  // Ã°Å¸â€Â¹ Mostra popup di scelta
  final choice = await showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    String selected = 'csv';

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cs.outlineVariant, width: 1),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.file_download_outlined, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.download_charts_title,
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(AppLocalizations.of(context)!.export_choose_format,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FormatChip(
                    label: AppLocalizations.of(context)!.common_csv,
                    icon: Icons.table_chart_outlined,
                    selected: selected == 'csv',
                    onTap: () => setState(() => selected = 'csv'),
                  ),
                  _FormatChip(
                    label: AppLocalizations.of(context)!.common_pdf,
                    icon: Icons.picture_as_pdf_outlined,
                    selected: selected == 'pdf',
                    onTap: () => setState(() => selected = 'pdf'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      selected == 'csv'
                          ? AppLocalizations.of(context)!.export_csv_desc
                          : AppLocalizations.of(context)!.export_pdf_desc,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.common_cancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, selected),
              icon: const Icon(Icons.download),
              label: Text(AppLocalizations.of(context)!.common_download),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  },
);


  if (choice == null) return;

  // Ã°Å¸â€Â¹ Prepara dati comuni
  final completedTodos = todos.where((t) => t.status == TodoStatus.done).toList();
  final openTodos = todos.where((t) => t.status == TodoStatus.open).toList();

  final Map<String, double> expensesByCategory = {};
  for (final todo in completedTodos) {
    if (todo.cost != null && todo.cost! > 0) {
      final categoryName = todo.categories.isNotEmpty
          ? todo.categories.first.name
          : AppLocalizations.of(context)!.no_category;
      expensesByCategory[categoryName] =
          (expensesByCategory[categoryName] ?? 0) + todo.cost!;
    }
  }

  final Map<String, int> tasksByRoommate = {};
  for (final roommate in roommates) {
    tasksByRoommate[roommate.name] = roommate.tasksCompleted;
  }

  final todoStats = {
    'Completati': completedTodos.length,
    'Aperti': openTodos.length,
  };

  // Ã°Å¸â€Â¹ Se lÃ¢â‚¬â„¢utente sceglie CSV
  if (choice == 'csv') {
    final List<String> csvLines = [];

    csvLines.add(AppLocalizations.of(context)!.csv_section_expenses_by_category);
    csvLines.add('${AppLocalizations.of(context)!.table_category};${AppLocalizations.of(context)!.table_amount_eur}');
    for (final entry in expensesByCategory.entries) {
      csvLines.add('${_escapeCSV(entry.key)};${entry.value.toStringAsFixed(2)}');
    }
    csvLines.add('${AppLocalizations.of(context)!.csv_total};${expensesByCategory.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}');
    csvLines.add('');

    csvLines.add(AppLocalizations.of(context)!.csv_section_tasks_by_roommate);
    csvLines.add('${AppLocalizations.of(context)!.table_roommate};${AppLocalizations.of(context)!.table_tasks_completed}');
    for (final entry in tasksByRoommate.entries) {
      csvLines.add('${_escapeCSV(entry.key)};${entry.value}');
    }
    csvLines.add('${AppLocalizations.of(context)!.csv_total};${tasksByRoommate.values.fold(0, (a, b) => a + b)}');
    csvLines.add('');

    csvLines.add(AppLocalizations.of(context)!.csv_section_status_todos);
    csvLines.add('${AppLocalizations.of(context)!.csv_status};${AppLocalizations.of(context)!.csv_quantity}');
    for (final entry in todoStats.entries) {
      csvLines.add('${_escapeCSV(entry.key)};${entry.value}');
    }
    csvLines.add('${AppLocalizations.of(context)!.csv_total};${todoStats.values.fold(0, (a, b) => a + b)}');
    csvLines.add('');

    final now = DateTime.now();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    csvLines.add(AppLocalizations.of(context)!.csv_generated_on.replaceFirst('{timestamp}', timestamp));

    final content = csvLines.join('\r\n');
    final bytes = Uint8List.fromList([
      ...const [0xEF, 0xBB, 0xBF],
      ...utf8.encode(content),
    ]);

    final filename = 'admin_grafici_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
    triggerDownloadCsv(filename, bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.charts_exported_file.replaceFirst('{filename}', filename)),
        backgroundColor: Colors.green.shade600,
      ),
    );

  // Ã°Å¸â€Â¹ Se lÃ¢â‚¬â„¢utente sceglie PDF
  } else if (choice == 'pdf') {
    final pdf = pw.Document();


    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                sanitize(AppLocalizations.of(context)!.admin_stats_title),
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 18),

              pw.Text(sanitize(AppLocalizations.of(context)!.pdf_expenses_by_category_title),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: [
                  AppLocalizations.of(context)!.table_category,
                  AppLocalizations.of(context)!.table_amount_eur
                ],
                data: expensesByCategory.entries
                    .map((e) => [
                          sanitize(e.key),
                          sanitize(e.value.toStringAsFixed(2))
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 16),

              pw.Text(sanitize(AppLocalizations.of(context)!.pdf_tasks_by_roommate_title),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: [
                  AppLocalizations.of(context)!.table_roommate,
                  AppLocalizations.of(context)!.table_tasks_completed
                ],
                data: tasksByRoommate.entries
                    .map((e) => [
                          sanitize(e.key),
                          sanitize(e.value.toString())
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 16),

              pw.Text(sanitize(AppLocalizations.of(context)!.pdf_todo_status_title),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: [AppLocalizations.of(context)!.csv_status, AppLocalizations.of(context)!.csv_quantity],
                data: todoStats.entries
                    .map((e) => [
                          sanitize(e.key),
                          sanitize(e.value.toString())
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.pdf_generated_success),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}


  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade800)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.grey.shade700)),
        actions: [
          FilledButton(
            onPressed: () => context.pop(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.common_ok),
          ),
        ],
      ),
    );
  }
}

// Pie chart implementation moved to widgets/admin/pie_chart.dart
class _FormatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FormatChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: selected ? cs.primary.withOpacity(0.10) : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.blue.shade700,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.primary : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
