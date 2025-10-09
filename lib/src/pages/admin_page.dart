import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:your_turn/src/utils/csv_web_download_stub.dart'
  if (dart.library.html) 'package:your_turn/src/utils/csv_web_download.dart';

// Modular admin widgets
import 'package:your_turn/src/widgets/admin/pie_chart.dart';
import 'package:your_turn/src/widgets/admin/color_picker.dart';
import 'package:your_turn/src/widgets/admin/icon_grid.dart';
import 'package:your_turn/src/widgets/admin/cards.dart';
import 'profile_page.dart';

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
  String? _selectedIconKey;
  String _selectedColor = '#2196F3';

  // Mappa delle icone disponibili (esattamente 24 icone: 2 righe x 12)
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
    {'hex': '#4CAF50', 'name': 'Verde'},
    {'hex': '#FF9800', 'name': 'Arancione'},
    {'hex': '#F44336', 'name': 'Rosso'},
    {'hex': '#9C27B0', 'name': 'Viola'},
    {'hex': '#E91E63', 'name': 'Rosa'},
    {'hex': '#00BCD4', 'name': 'Ciano'},
    {'hex': '#8BC34A', 'name': 'Verde chiaro'},
    {'hex': '#FFC107', 'name': 'Giallo'},
    {'hex': '#795548', 'name': 'Marrone'},
  ];

  // Avatar carini e colorati per nuovi utenti - stile DiceBear adventurer
  static const List<String> _stockAvatars = [
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser1&backgroundColor=ffdfbf,c0aede,d1d4f9&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser2&backgroundColor=ffd5dc,ffdfbf,c0aede&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser3&backgroundColor=d1d4f9,ffd5dc,b6e3f4&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser4&backgroundColor=c0aede,ffdfbf,d1d4f9&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser5&backgroundColor=ffd5dc,b6e3f4,ffdfbf&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser6&backgroundColor=b6e3f4,c0aede,ffd5dc&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser7&backgroundColor=ffdfbf,d1d4f9,c0aede&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser8&backgroundColor=d1d4f9,ffd5dc,b6e3f4&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser9&backgroundColor=c0aede,ffdfbf,ffd5dc&scale=80',
    'https://api.dicebear.com/7.x/adventurer/png?seed=NewUser10&backgroundColor=b6e3f4,d1d4f9,ffdfbf&scale=80',
  ];

  String _getRandomAvatar() {
    return _stockAvatars[math.Random().nextInt(_stockAvatars.length)];
  }

  @override
  void dispose() {
    _roommateController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  // hex color conversion is provided by widgets where needed


  // Funzione per scaricare i dati dei grafici in formato CSV
  Future<void> _downloadChartsData() async {
    final todos = ref.read(todosProvider);
    final roommates = ref.read(roommatesProvider);
    
    // Prepara i dati
    final completedTodos = todos.where((t) => t.status == TodoStatus.done).toList();
    final openTodos = todos.where((t) => t.status == TodoStatus.open).toList();
    
    // Calcola i dati per i 3 grafici
    
    // 1. Spese per categoria
    final Map<String, double> expensesByCategory = {};
    for (final todo in completedTodos) {
      if (todo.cost != null && todo.cost! > 0) {
        final categoryName = todo.categories.isNotEmpty ? todo.categories.first.name : 'Senza categoria';
        expensesByCategory[categoryName] = (expensesByCategory[categoryName] ?? 0) + todo.cost!;
      }
    }
    
    // 2. Statistiche coinquilini (task completati)
    final Map<String, int> tasksByRoommate = {};
    for (final roommate in roommates) {
      tasksByRoommate[roommate.name] = roommate.tasksCompleted;
    }
    
    // 3. Status todos
    final todoStats = {
      'Completati': completedTodos.length,
      'Aperti': openTodos.length,
    };
    
    // Genera CSV
    final List<String> csvLines = [];
    
    // Sezione 1: Spese per categoria
    csvLines.add('=== SPESE PER CATEGORIA ===');
    csvLines.add('Categoria;Importo (€)');
    for (final entry in expensesByCategory.entries) {
      csvLines.add('${_escapeCSV(entry.key)};${entry.value.toStringAsFixed(2)}');
    }
    csvLines.add('TOTALE;${expensesByCategory.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}');
    csvLines.add('');
    
    // Sezione 2: Task completati per coinquilino
    csvLines.add('=== TASK COMPLETATI PER COINQUILINO ===');
    csvLines.add('Coinquilino;Task Completati');
    for (final entry in tasksByRoommate.entries) {
      csvLines.add('${_escapeCSV(entry.key)};${entry.value}');
    }
    csvLines.add('TOTALE;${tasksByRoommate.values.fold(0, (a, b) => a + b)}');
    csvLines.add('');
    
    // Sezione 3: Status todos
    csvLines.add('=== STATUS TODOS ===');
    csvLines.add('Status;Quantità');
    for (final entry in todoStats.entries) {
      csvLines.add('${_escapeCSV(entry.key)};${entry.value}');
    }
    csvLines.add('TOTALE;${todoStats.values.fold(0, (a, b) => a + b)}');
    csvLines.add('');
    
    // Aggiungi timestamp
    final now = DateTime.now();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    csvLines.add('Generato il: $timestamp');
    
    // Crea il file
    final content = csvLines.join('\r\n');
    final bytes = Uint8List.fromList([
      ...const [0xEF, 0xBB, 0xBF], // BOM UTF-8 per Excel
      ...utf8.encode(content),
    ]);
    
    // Download
    final filename = 'admin_grafici_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
    triggerDownloadCsv(filename, bytes);
    
    // Mostra messaggio di conferma
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dati grafici esportati in $filename'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
  
  String _escapeCSV(String text) {
    if (text.contains(';') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final roommates = ref.watch(roommatesProvider);
    
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          // 🔹 P = vai alla pagina profilo
          if (key == LogicalKeyboardKey.keyP) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }

          // 🔹 D = download dati grafici
          if (key == LogicalKeyboardKey.keyD) {
            _downloadChartsData();
          }
        }
      },
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyG): const _DownloadIntent(),
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
                  // Layout a due colonne usando SliverPadding
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 800;
                          if (isWide) {
                            // Layout desktop: istogrammi in alto, poi due colonne affiancate
                            return Column(
                              children: [
                                // Istogrammi in alto come prima cosa
                                _buildExpensesChartCard(),
                                const SizedBox(height: 16),
                                Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Categorie a sinistra
                                Expanded(
                                  flex: 1,
                                  child: _buildCategoriesCard(),
                                ),
                                const SizedBox(width: 16),
                                // Coinquilini a destra  
                                Expanded(
                                  flex: 1,
                                  child: _buildRoommatesCard(roommates),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        // Layout mobile: istogrammi in alto, poi colonne impilate
                        return Column(
                          children: [
                            // Istogrammi in alto come prima cosa
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
        ), // Chiusura di Scaffold
      ), // Chiusura di Actions
    ), // Chiusura di Shortcuts
    ); // Chiusura di RawKeyboardListener
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue, size: 24),
        tooltip: 'Torna alla ToDo',
        onPressed: () => context.pop(),
      ),
      actions: [
        // Bottoni con stesso stile della todo_page
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔵 Tasto P - Profilo
            Container(
              margin: const EdgeInsets.only(right: 8),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              'P',
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
                          'PROFILO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.person, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // 🟢 Tasto D - Download
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _downloadChartsData(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade700, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              'D',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'DOWNLOAD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.download, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
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
                  'Analisi Spese per Categoria',
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
                      Expanded(child: _buildSingleChart('Todo Completati', todos, true, Colors.green)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSingleChart('Todo Da Fare', todos, false, Colors.blue)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSingleChart('Budget Totale', todos, null, Colors.orange)),
                    ],
                  );
                } else {
                  // Mobile: stack verticale
                  return Column(
                    children: [
                      _buildSingleChart('Todo Completati', todos, true, Colors.green),
                      const SizedBox(height: 24),
                      _buildSingleChart('Todo Da Fare', todos, false, Colors.blue),
                      const SizedBox(height: 24),
                      _buildSingleChart('Budget Totale', todos, null, Colors.orange),
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
                        'Nessun dato disponibile',
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
                    'Completa alcuni todo di questa categoria per vedere i dati',
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
                height: 180, // Ottimizzato per visibilità completa
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180), // Bilanciato per visibilità
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
                            'Totale',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeColor.shade600,
                            ),
                          ),
                          Text(
                            '€${totalAmount.toStringAsFixed(0)}',
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
                    crossAxisCount: 3, // 3 colonne per vedere più categorie
                    childAspectRatio: 3.2, // Più spazio per leggibilità (a11y)
                    crossAxisSpacing: 8, // Material Design 3 spacing
                    mainAxisSpacing: 8,
                  ),
                  itemCount: slices.length,
                  itemBuilder: (context, index) {
                    final slice = slices[index];
                    final percentage = (slice.amount / totalAmount * 100);
                    return Semantics(
                      label: '${slice.category}: €${slice.amount.toStringAsFixed(2)}, ${percentage.toStringAsFixed(1)}% del totale',
                      hint: 'Categoria di spesa per ${title.toLowerCase()}',
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
      onAddCategoryPressed: () => _showAddCategoryDialog(),
      onDelete: (c) => _confirmDeleteCategory(c),
    );
  }

  Widget _buildRoommatesCard(List<Roommate> roommates) {
    return RoommatesCard(
      roommates: roommates,
      onEdit: (r) => _editRoommate(r),
      onDelete: (r) => _confirmDeleteRoommate(r),
      onAddRoommatePressed: () => _showAddRoommateDialog(),
    );
  }

  // Dialog to add roommate
  void _showAddRoommateDialog() {
    _roommateController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [Icon(Icons.person_add, color: Colors.blue.shade700), const SizedBox(width: 8), Text('Aggiungi Coinquilino', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800))]),
        content: TextField(
          controller: _roommateController,
          decoration: InputDecoration(hintText: 'Nome coinquilino', prefixIcon: Icon(Icons.person, color: Colors.blue.shade600)),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _addRoommate(),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text('Annulla', style: TextStyle(color: Colors.grey.shade600))),
          FilledButton(onPressed: () { _addRoommate(); context.pop(); }, style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade700), child: const Text('Aggiungi')),
        ],
      ),
    );
  }

  // Dialog to add category
  void _showAddCategoryDialog() {
    _categoryNameController.clear();
    _selectedIconKey = null;
    _selectedColor = _availableColors.first['hex']!;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(children: [Icon(Icons.label, color: Colors.green.shade700), const SizedBox(width: 8), Text('Aggiungi Categoria', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800))]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: _categoryNameController, decoration: InputDecoration(hintText: 'Nome categoria', prefixIcon: Icon(Icons.label, color: Colors.green.shade600)), textCapitalization: TextCapitalization.words),
              const SizedBox(height: 12),
              AdminIconGrid(icons: _iconByKey, selectedKey: _selectedIconKey, onSelected: (k) => setDialogState(() => _selectedIconKey = k)),
              const SizedBox(height: 12),
              AdminColorPicker(colors: _availableColors, selectedHex: _selectedColor, onSelected: (hex) => setDialogState(() => _selectedColor = hex)),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text('Annulla', style: TextStyle(color: Colors.grey.shade600))),
            FilledButton(onPressed: () { _addCategory(); context.pop(); }, style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700), child: const Text('Aggiungi')),
          ],
        ),
      ),
    );
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
              Text('Modifica Coinquilino', 
                   style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roommateController,
                decoration: InputDecoration(
                  labelText: 'Nome coinquilino',
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
              child: Text('Annulla', style: TextStyle(color: Colors.grey.shade600)),
            ),
            FilledButton(
              onPressed: () => _saveRoommateEdit(roommate),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Salva'),
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
    }
  }

  void _addRoommate() {
    if (_roommateController.text.trim().isNotEmpty) {
      // Use provider to add new roommate with random avatar
      ref.read(roommatesProvider.notifier).ensure(
        DateTime.now().toString(),
        name: _roommateController.text.trim(),
        photoUrl: _getRandomAvatar(),
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

  void _confirmDeleteRoommate(Roommate roommate) {
    final currentUser = ref.read(userProvider);
    final allTodos = ref.read(todosProvider);
    
    // Controlla se è l'utente attualmente loggato
    if (currentUser?.id == roommate.id) {
      _showErrorDialog(
        'Operazione non consentita',
        'Non puoi eliminare il tuo account mentre sei connesso.'
      );
      return;
    }
    
    // Controlla se l'utente ha to-do assegnati
    final hasAssignedTodos = allTodos.any((todo) => todo.assigneeIds.contains(roommate.id));
    if (hasAssignedTodos) {
      _showErrorDialog(
        'Impossibile eliminare',
        '${roommate.name} ha ancora dei to-do assegnati. Rimuovi prima tutti i to-do assegnati a questo utente.'
      );
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
        content: Text('Sei sicuro di voler eliminare "${roommate.name}"?', 
                     style: TextStyle(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Annulla', style: TextStyle(color: Colors.grey.shade600)),
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
            child: const Text('Elimina'),
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
      _showErrorDialog(
        'Impossibile eliminare',
        'La categoria "${category.name}" è ancora in uso in alcuni to-do. Rimuovi prima questa categoria da tutti i to-do.'
      );
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
        content: Text('Sei sicuro di voler eliminare la categoria "${category.name}"?',
                     style: TextStyle(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Annulla', style: TextStyle(color: Colors.grey.shade600)),
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
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Pie chart implementation moved to widgets/admin/pie_chart.dart
