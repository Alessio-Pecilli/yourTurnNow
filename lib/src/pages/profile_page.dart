// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/expense_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';

import 'package:your_turn/src/widgets/help_banner.dart';
import 'package:your_turn/src/widgets/profile_header.dart';
import 'package:your_turn/src/widgets/transaction_filters.dart';
import 'package:your_turn/src/widgets/transaction_tile_card.dart';
import 'package:your_turn/src/widgets/transaction_dialogs.dart';
import 'package:your_turn/src/services/csv_export_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.userId});
  final String? userId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

// Solo vista griglia - lista rimossa

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _visibleTxCount = 10;
  final NumberFormat _money = NumberFormat.currency(locale: 'it_IT', symbol: '€');

  TodoCategory? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  bool _showHelp = true;
    // Solo vista griglia - rimossa selezione vista
  
  // Paginazione griglia 4x4
  int _currentPage = 0;
  static const int _rowsPerPage = 4; // 4 righe per pagina, colonne dinamiche

  static const String _shortcutInfo =
      'Scorciatoie: Alt+A = Aggiungi/Modifica saldo • Alt+D = Scarica CSV';



  Card _sectionCard({required Widget child, EdgeInsetsGeometry? margin}) => Card(
    margin: margin ?? const EdgeInsets.fromLTRB(16, 12, 16, 8),
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    color: Colors.white,
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );

  // Mappatura da TodoCategory a ExpenseCategory
  ExpenseCategory? _mapTodoToExpenseCategory(TodoCategory? todoCategory) {
    if (todoCategory == null) return null;
    
    switch (todoCategory.id) {
      case 'spesa':
        return ExpenseCategory.spesa;
      case 'bollette':
        return ExpenseCategory.bolletta;
      case 'pulizie':
        return ExpenseCategory.pulizia;
      case 'manutenzione':
      case 'cucina':
      case 'divertimento':
      case 'varie':
      default:
        return ExpenseCategory.altro;
    }
  }

  List<MoneyTx> _applyFilters(List<MoneyTx> all) {
    var out = all;
    if (_selectedCategory != null) {
      final expenseCategory = _mapTodoToExpenseCategory(_selectedCategory);
      if (expenseCategory != null) {
        out = out.where((t) => t.category == expenseCategory).toList();
      }
    }
    if (_selectedDateRange != null) {
      final r = _selectedDateRange!;
      out = out.where((t) => !t.createdAt.isBefore(r.start) && !t.createdAt.isAfter(r.end)).toList();
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final roommates = ref.watch(roommatesProvider);
    final user = ref.watch(userProvider);
    final categories = ref.watch(categoriesProvider);

    final Roommate? me = widget.userId != null
        ? roommates.firstWhere(
            (r) => r.id == widget.userId!,
            orElse: () => Roommate(id: widget.userId!, name: 'Sconosciuto'),
          )
        : (user == null
            ? null
            : roommates.firstWhere(
                (r) => r.id == user.id,
                orElse: () => Roommate(id: user.id, name: user.name, photoUrl: user.photoUrl),
              ));

    if (me == null) {
      return const Scaffold(body: Center(child: Text('Effettua il login per vedere il profilo.')));
    }

    final allTxs = ref.watch(userTransactionsProvider(me.id));
    final txs = _applyFilters(allTxs);
    final visibleTxs = txs.take(_visibleTxCount).toList();

    return Scaffold(
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
              _buildProfileHeader(me),
              if (_showHelp)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: HelpBanner(
                      onClose: () => setState(() => _showHelp = false),
                      shortcutInfo: _shortcutInfo,
                    ),
                  ),
                ),
              _buildFilters(context, categories),
              _buildTransactionsSliver(visibleTxs), // ✅ lista/griglia dinamica
              _buildPagination(txs),
            ],
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue, size: 24),
        tooltip: 'Indietro',
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.go('/todo');
          }
        },
      ),
      title: const Text('', style: TextStyle(color: Colors.transparent)),
      actions: [
        IconButton(
          tooltip: 'Scarica CSV',
          onPressed: () {
            // Opzionale: quick action globale, serve me
            final roommates = ref.read(roommatesProvider);
            final user = ref.read(userProvider);
            final me = roommates.firstWhere(
              (r) => r.id == user?.id,
              orElse: () => Roommate(id: user?.id ?? 'me', name: user?.name ?? 'Tu'),
            );
            _downloadTransactionsCsv(me);
          },
          icon: const Icon(Icons.download),
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
      ],
    );
  }



  SliverToBoxAdapter _buildProfileHeader(Roommate me) {
    return SliverToBoxAdapter(
      child: ProfileHeader(
        roommate: me,
        onDownload: () => _downloadTransactionsCsv(me),
        onAddTransaction: () => _onAddTransaction(context, me),
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

  Future<void> _downloadTransactionsCsv(Roommate me) async {
    final txs = ref.read(userTransactionsProvider(me.id));
    await CsvExportService.exportTransactionsCsv(txs, me, context);
  }

  Future<void> _onAddTransaction(BuildContext context, Roommate me) async {
    await TransactionDialogs.showAddDialog(context, ref, me);
  }
}


