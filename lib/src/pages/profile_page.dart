// lib/pages/profile_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/pages/admin_page.dart';
import 'package:your_turn/src/pages/todo_page.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/utils/csv_web_download.dart';
import '../providers/roommates_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';

import 'package:your_turn/src/widgets/help_banner.dart';
import 'package:your_turn/src/widgets/profile_header.dart';
import 'package:your_turn/src/widgets/transaction_filters.dart';
import 'package:your_turn/src/widgets/transaction_tile_card.dart';
import 'package:your_turn/src/widgets/transaction_dialogs.dart';
import 'package:your_turn/src/services/csv_export_service.dart';
import 'package:your_turn/src/services/pdf_export_service.dart';
import 'package:your_turn/src/widgets/transactions_chart.dart';
import 'package:your_turn/src/widgets/common_action_button.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.userId});
  final String? userId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

// Solo vista griglia - lista rimossa
class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _visibleTxCount = 10;
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

  final NumberFormat _money = NumberFormat.currency(locale: 'it_IT', symbol: '€');

  TodoCategory? _selectedCategory; 
  DateTimeRange? _selectedDateRange;
  bool _showHelp = false;

  // Paginazione griglia 4x4
  int _currentPage = 0;
  static const int _rowsPerPage = 4; // 4 righe per pagina, colonne dinamiche

  static const String _shortcutInfo =
      'Scorciatoie: H = Home • D = Scarica CSV • A = Aggiungi Transazione';

  Card _sectionCard({required Widget child, EdgeInsetsGeometry? margin}) => Card(
        margin: margin ?? const EdgeInsets.fromLTRB(16, 12, 16, 8),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      );

  // 🔹 Filtro per transazioni
  List<MoneyTx> _applyFilters(List<MoneyTx> all) {
  var out = all;

  if (_selectedCategory != null) {
    out = out.where((t) {
      // Normalizza il nome della categoria selezionata
      String selectedName;
      if (_selectedCategory is TodoCategory) {
        selectedName = (_selectedCategory as TodoCategory).name.toLowerCase();
      } else {
        return false;
      }

      // Cerca match nelle categorie della transazione
      final matchExpense = t.category.any(
        (c) => c.name.toLowerCase() == selectedName,
      );

      // Cerca match anche su customCategoryName se presente
      final matchCustom = (t.customCategoryName != null &&
          t.customCategoryName!.toLowerCase() == selectedName);

      return matchExpense || matchCustom;
    }).toList();
  }

  if (_selectedDateRange != null) {
    final r = _selectedDateRange!;
    out = out
        .where((t) =>
            !t.createdAt.isBefore(r.start) &&
            !t.createdAt.isAfter(r.end))
        .toList();
  }

  out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return out;
}




  @override
  Widget build(BuildContext context) {
    final roommates = ref.watch(roommatesProvider);
    final user = ref.watch(userProvider);

    final Roommate? me = widget.userId != null
        ? roommates.firstWhere(
            (r) => r.id == widget.userId!,
            orElse: () => Roommate(id: widget.userId!, name: 'Sconosciuto'),
          )
        : (user == null
            ? null
            : roommates.firstWhere(
                (r) => r.id == user.id,
                orElse: () => Roommate(
                    id: user.id, name: user.name, photoUrl: user.photoUrl),
              ));

    if (me == null) {
      return const Scaffold(
          body: Center(child: Text('Effettua il login per vedere il profilo.')));
    }

    final allTxs = ref.watch(userTransactionsProvider(me.id));
    final txs = _applyFilters(allTxs);
    final visibleTxs = txs.take(_visibleTxCount).toList();
    final todoCategories = ref.watch(categoriesProvider);
    final allCategories = [
  ...todoCategories,  
];

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
  final key = event.logicalKey;

  // 🔹 S = download CSV/PDF
  if (key == LogicalKeyboardKey.keyS) {
    final roommates = ref.read(roommatesProvider);
    final user = ref.read(userProvider);
    final currentMe = roommates.firstWhere(
      (r) => r.id == user?.id,
      orElse: () => Roommate(id: user?.id ?? 'me', name: user?.name ?? 'Tu'),
    );
    _downloadTransactions(currentMe);
  }

  // 🔹 H = TodoPage
  if (key == LogicalKeyboardKey.keyH) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TodoPage()),
    ).then((_) {
      // 👇 riprendi focus quando torni indietro
      _keyboardFocusNode.requestFocus();
    });
  }

  // 🔹 A = AdminPage
  if (key == LogicalKeyboardKey.keyA) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminPage()),
    ).then((_) {
      // 👇 riprendi focus quando torni indietro
      _keyboardFocusNode.requestFocus();
    });
  }

  // 🔹 T = nuova transazione
  if (key == LogicalKeyboardKey.keyT) {
    final roommates = ref.read(roommatesProvider);
    final user = ref.read(userProvider);
    final currentMe = roommates.firstWhere(
      (r) => r.id == user?.id,
      orElse: () => Roommate(id: user?.id ?? 'me', name: user?.name ?? 'Tu'),
    );

    _onAddTransaction(context, currentMe).then((_) {
      // 👇 dopo aver chiuso il dialogo, ridai focus alla pagina
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
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Foto profilo
                        ProfileHeader(roommate: me),
                        const SizedBox(width: 20),


                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TransactionFilters(
                              categories: allCategories,
                              selectedCategory: _selectedCategory,
                              selectedDateRange: _selectedDateRange,
                              onCategoryChanged: (category) => setState(
                                  () => _selectedCategory = category),
                              onDateRangeChanged: (dateRange) =>
                                  setState(() => _selectedDateRange = dateRange),
                              onReset: () => setState(() {
                                _selectedCategory = null;
                                _selectedDateRange = null;
                                _currentPage = 0;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TransactionsChart(transactions: txs),
                ),
                _buildTransactionsSliver(visibleTxs),
                _buildPagination(txs),
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
  child: _buildActionButton(
    context,
    letter: 'T',
    label: 'NUOVO',
    color: Colors.blue,
    icon: Icons.add, // o qualunque icona vuoi, anche Icons.add_circle_outline
    onTap: () => _onAddTransaction(context, me),
  ),
),
      ),
    );
  }


 SliverAppBar _buildAppBar(BuildContext context) {
  return SliverAppBar(
    pinned: true,
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: null,
    actions: [
  Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsante H - TO-DO
        SizedBox(
          height: 46,
          child: _buildActionButton(
            context,
            letter: 'H',
            label: 'TO-DO',
            color: Colors.blue,
            icon: Icons.check_circle_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TodoPage()),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Pulsante A - ADMIN
        SizedBox(
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
        const SizedBox(width: 12),

        // Pulsante S - DOWNLOAD
        SizedBox(
          height: 46,
          child: _buildActionButton(
            context,
            letter: 'S',
            label: 'DOWNLOAD',
            color: Colors.blue,
            icon: Icons.download_rounded,
            onTap: () {
              final roommates = ref.read(roommatesProvider);
              final user = ref.read(userProvider);
              final me = roommates.firstWhere(
                (r) => r.id == user?.id,
                orElse: () =>
                    Roommate(id: user?.id ?? 'me', name: user?.name ?? 'Tu'),
              );
              _downloadTransactions(me);
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




  SliverToBoxAdapter _buildProfileHeader(Roommate me) {
    return SliverToBoxAdapter(
      child: ProfileHeader(
        roommate: me,
      ),
    );
  }

  SliverToBoxAdapter _buildFilters(BuildContext context, List<TodoCategory> categories) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TransactionFilters(
          categories: categories,
          selectedCategory: _selectedCategory,
          selectedDateRange: _selectedDateRange,
          onCategoryChanged: (category) => setState(() => _selectedCategory = category),
          onDateRangeChanged: (dateRange) => setState(() => _selectedDateRange = dateRange),
          onReset: () => setState(() {
            _selectedCategory = null;
            _selectedDateRange = null;
            _currentPage = 0;
          }),
        ),
      ),
    );
  }

  // ====== Vista dinamica: griglia o lista ======
  Widget _buildTransactionsSliver(List<MoneyTx> visibleTxs) {
    if (visibleTxs.isEmpty) {
      return SliverToBoxAdapter(
        child: _sectionCard(
          child: Center(
            child: Text(
              'Nessuna transazione. Aggiungi la prima.',
              style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    // Sempre vista griglia
    
    return SliverPadding(
      
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            // Calcola dimensioni dinamiche per le transazioni (stesso sistema dei todo)
            final screenWidth = constraints.crossAxisExtent;
            final minCardWidth = 240.0; // Larghezza minima per leggibilità transazioni
            final maxCardWidth = 320.0; // Larghezza massima
            
            // Calcola numero ottimale di colonne
            int crossAxisCount = (screenWidth / minCardWidth).floor();
            if (crossAxisCount < 1) crossAxisCount = 1;
            if (crossAxisCount > 6) crossAxisCount = 6; // Max 6 colonne come todo
            
            // Calcola elementi per pagina in base alle colonne dinamiche
            final itemsPerPage = crossAxisCount * _rowsPerPage; // colonne * 4 righe
            
            // Calcola l'indice di inizio e fine per la pagina corrente
            final startIndex = _currentPage * itemsPerPage;
            final endIndex = (startIndex + itemsPerPage).clamp(0, visibleTxs.length);
            final pageItems = visibleTxs.sublist(startIndex, endIndex);
            
            // Calcola larghezza effettiva delle card
            final cardWidth = screenWidth / crossAxisCount;
            final clampedCardWidth = cardWidth.clamp(minCardWidth, maxCardWidth);
            
            // Aspect ratio dinamico per altezza ottimale (più compatto dei todo)
            final aspectRatio = clampedCardWidth / 120.0; // Altezza fissa 120px per transazioni compatte
            
            return SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => TransactionTileCard(
                  tx: pageItems[i],
                  money: _money,
                  onDelete: () => _onDeleteTransaction(context, pageItems[i]),
                  onEdit: () => _onEditTransaction(context, pageItems[i]),
                  dense: false,
                ),
                childCount: pageItems.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Dinamico come i todo!
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: aspectRatio, // Dinamico!
              ),
            );
          },
        ),
      );
  }

  void _onDeleteTransaction(BuildContext context, MoneyTx tx) async {
    await TransactionDialogs.showDeleteDialog(context, ref, tx);
  }

  void _onEditTransaction(BuildContext context, MoneyTx tx) async {
    await TransactionDialogs.showEditDialog(context, ref, tx);
  }

  SliverToBoxAdapter _buildPagination(List<MoneyTx> txs) {
    // Solo griglia - paginazione dinamica 
    final estimatedItemsPerPage = 5 * _rowsPerPage; // 5 colonne * 4 righe = 20 elementi
    final totalPages = (txs.length / estimatedItemsPerPage).ceil();
      if (totalPages <= 1) return const SliverToBoxAdapter(child: SizedBox.shrink());
      
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsante Precedente
              IconButton.outlined(
                onPressed: _currentPage > 0 
                  ? () => setState(() => _currentPage--) 
                  : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Pagina precedente',
              ),
              const SizedBox(width: 16),
              // Indicatore pagina
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  '${_currentPage + 1} di $totalPages',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Pulsante Successivo
              IconButton.outlined(
                onPressed: _currentPage < totalPages - 1 
                  ? () => setState(() => _currentPage++) 
                  : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Pagina successiva',
              ),
            ],
          ),
        ),
      );
  }

  

  String _escapeCSV(String text) {
    if (text.contains(';') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  Future<void> _onAddTransaction(BuildContext context, Roommate me) async {
    await TransactionDialogs.showAddDialog(context, ref, me);
  }
  Future<void> _downloadTransactions(Roommate me) async {
  final txs = ref.read(userTransactionsProvider(me.id));

  // 🔹 Mostra popup di scelta
  final choice = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Scarica transazioni'),
        content: const Text('In quale formato vuoi scaricare i dati?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'csv'),
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'pdf'),
            child: const Text('PDF'),
          ),
        ],
      );
    },
  );

  if (choice == 'csv') {
    await CsvExportService.exportTransactionsCsv(txs, me, context);
  } else if (choice == 'pdf') {
    await PdfExportService.exportTransactionsPdf(txs, me, context);
  }
}
}



