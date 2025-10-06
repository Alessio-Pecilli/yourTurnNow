// lib/pages/profile_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:your_turn/src/utils/csv_web_download_stub.dart'
  if (dart.library.html) 'package:your_turn/src/utils/csv_web_download.dart';

import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/expense_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';

import 'package:your_turn/src/widgets/help_banner.dart';

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

  // Funzione di mapping da TodoCategory a ExpenseCategory
  ExpenseCategory _mapTodoCategoryToExpense(TodoCategory? todoCategory) {
    if (todoCategory == null) return ExpenseCategory.altro;
    
    switch (todoCategory.id) {
      case 'spesa':
        return ExpenseCategory.spesa;
      case 'bollette':
        return ExpenseCategory.bolletta; // bollette (plurale) → bolletta (singolare)
      case 'pulizie':
        return ExpenseCategory.pulizia; // pulizie (plurale) → pulizia (singolare)
      case 'cucina':
      case 'divertimento':
      case 'manutenzione':
      case 'varie':
        return ExpenseCategory.altro;
      default:
        return ExpenseCategory.altro;
    }
  }

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

  SliverToBoxAdapter _buildProfileHeader(Roommate me) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade700, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: ClipOval(
                child: me.photoUrl != null && me.photoUrl!.isNotEmpty
                    ? Image.network(
                        me.photoUrl!,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackAvatar(me.name),
                      )
                    : _fallbackAvatar(me.name),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    me.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.grey.shade900),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _downloadTransactionsCsv(me),
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text('Download'),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _onAddTransaction(context, me),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Aggiungi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFilters(BuildContext context, List<TodoCategory> categories) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Vista + Categorie + Data/Reset
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Solo vista griglia
                    
                    // Categorie
                    Expanded(
                      flex: 3,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.label_outline, size: 16, color: _selectedCategory == null ? Colors.white : Colors.blue.shade700),
                                const SizedBox(width: 4),
                                const Text('Tutte', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            selected: _selectedCategory == null,
                            onSelected: (_) => setState(() => _selectedCategory = null),
                            backgroundColor: _selectedCategory == null ? Colors.blue.shade700 : Colors.white,
                            selectedColor: Colors.blue.shade700,
                            side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                            labelStyle: TextStyle(
                              color: _selectedCategory == null ? Colors.white : Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          // Mostra le stesse categorie dei todo
                          ...categories.map((category) {
                            final categoryColor = Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000);
                            final isSelected = _selectedCategory?.id == category.id;
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(category.icon, size: 16, color: isSelected ? Colors.white : categoryColor),
                                  const SizedBox(width: 4),
                                  Text(category.name.length > 8 ? category.name.substring(0, 8) : category.name, 
                                       style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategory = category),
                              backgroundColor: isSelected ? categoryColor : Colors.white,
                              selectedColor: categoryColor,
                              side: BorderSide(color: categoryColor, width: 1.5),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : categoryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            );
                          }),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Data e Reset
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Data e Reset sulla stessa riga
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                icon: const Icon(Icons.date_range, size: 16),
                                label: Text(
                                  _selectedDateRange == null
                                      ? 'Date'
                                      : '${DateFormat('dd/MM').format(_selectedDateRange!.start)}-${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    initialDateRange: _selectedDateRange,
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.light(useMaterial3: true),
                                        child: Dialog(backgroundColor: Colors.white, child: child!),
                                      );
                                    },
                                  );
                                  if (!mounted) return;
                                  setState(() => _selectedDateRange = picked);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 36), // Stessa altezza del bottone data
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () => setState(() {
                                _selectedCategory = null;
                                _selectedDateRange = null;
                                _currentPage = 0; // Reset pagina quando si resettano i filtri
                              }),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                (context, i) => _TxTileCard(
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: AlertDialog(
          title: const Text('Elimina transazione'),
          content: const Text('Sei sicuro di voler eliminare questa transazione?'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Elimina'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      ref.read(transactionsProvider.notifier).removeTx(tx.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transazione eliminata.')));
    }
  }

  void _onEditTransaction(BuildContext context, MoneyTx tx) async {
    final amountCtrl = TextEditingController(text: tx.amount.toString());
    final noteCtrl = TextEditingController(text: tx.note);
    final formKey = GlobalKey<FormState>();
    ExpenseCategory? selectedCategory = tx.category;
    DateTime? selectedDate = tx.createdAt;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Modifica transazione'),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\-]'))],
                      decoration: const InputDecoration(
                        labelText: 'Importo (€)',
                        hintText: 'positivo = accredito, negativo = addebito',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obbligatorio';
                        final p = double.tryParse(v.replaceAll(',', '.'));
                        if (p == null || p == 0.0) return 'Inserisci un numero diverso da 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...ExpenseCategory.values.map((category) {
                          final sel = selectedCategory == category;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(category.icon, size: 18, color: sel ? Colors.white : category.color),
                                const SizedBox(width: 6),
                                Text(category.label),
                              ],
                            ),
                            selected: sel,
                            onSelected: (_) => setState(() => selectedCategory = category),
                            backgroundColor: sel ? category.color : Colors.white,
                            selectedColor: category.color,
                            side: BorderSide(color: category.color, width: 1.5),
                            labelStyle: TextStyle(
                              color: sel ? Colors.white : category.color,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nota (opzionale)',
                        hintText: 'es. descrizione della spesa',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate == null
                                ? 'Oggi'
                                : DateFormat('dd/MM/yyyy').format(selectedDate!),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) => Theme(
                                data: ThemeData.light(useMaterial3: true),
                                child: Dialog(backgroundColor: Colors.white, child: child!),
                              ),
                            );
                            if (picked != null) setState(() => selectedDate = picked);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                child: const Text('Salva'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
      final note = noteCtrl.text.trim();
      final when = selectedDate ?? DateTime.now();
      final updated = tx.copyWith(
        amount: amount,
        note: note,
        createdAt: when,
        category: selectedCategory,
      );
      ref.read(transactionsProvider.notifier).updateTx(updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transazione modificata.')));
    }
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
    if (txs.isEmpty) {
      _announce(context, 'Nessuna transazione da esportare');
      return;
    }

    final ordered = [...txs]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final df = DateFormat('yyyy-MM-dd HH:mm');
    const sep = ';';
    String esc(String s) => '"${s.replaceAll('"', '""')}"';

    final lines = <String>['Data;Nota;Entrata (€);Uscita (€)'];
    double totIn = 0, totOut = 0;

    for (final t in ordered) {
      final date = df.format(t.createdAt.toLocal());
      final isIn = t.amount >= 0;
      final inVal = isIn ? t.amount.abs() : 0.0;
      final outVal = isIn ? 0.0 : t.amount.abs();
      if (inVal > 0) totIn += inVal;
      if (outVal > 0) totOut += outVal;

      lines.add([
        esc(date),
        esc(t.note),
        inVal > 0 ? inVal.toStringAsFixed(2) : '',
        outVal > 0 ? outVal.toStringAsFixed(2) : '',
      ].join(sep));
    }

    lines.add(['Totali', '', totIn.toStringAsFixed(2), totOut.toStringAsFixed(2)].join(sep));

    final content = lines.join('\r\n');
    final bytes = Uint8List.fromList([
      ...const [0xEF, 0xBB, 0xBF], // BOM UTF-8 (Excel)
      ...utf8.encode(content),
    ]);

    final safeName = me.name.replaceAll(' ', '_');
    triggerDownloadCsv('transazioni_$safeName.csv', bytes);
    _announce(context, 'CSV generato');
  }

  void _announce(BuildContext context, String message) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  Future<void> _onAddTransaction(BuildContext context, Roommate me) async {
    final categories = ref.read(categoriesProvider);
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    TodoCategory? selectedCategory = categories.isNotEmpty ? categories.first : null;
    DateTime? selectedDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Nuova transazione'),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\-]'))],
                      decoration: const InputDecoration(
                        labelText: 'Importo (€)',
                        hintText: 'positivo = accredito, negativo = addebito',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obbligatorio';
                        final p = double.tryParse(v.replaceAll(',', '.'));
                        if (p == null || p == 0.0) return 'Inserisci un numero diverso da 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...categories.map((category) {
                          final sel = selectedCategory?.id == category.id;
                          final categoryColor = Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000);
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(category.icon, size: 18, color: sel ? Colors.white : categoryColor),
                                const SizedBox(width: 6),
                                Text(category.name),
                              ],
                            ),
                            selected: sel,
                            onSelected: (_) => setState(() => selectedCategory = category),
                            backgroundColor: sel ? categoryColor : Colors.white,
                            selectedColor: categoryColor,
                            side: BorderSide(color: categoryColor, width: 1.5),
                            labelStyle: TextStyle(
                              color: sel ? Colors.white : categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nota (opzionale)',
                        hintText: 'es. descrizione della spesa',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate == null
                                ? 'Oggi'
                                : DateFormat('dd/MM/yyyy').format(selectedDate!),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) => Theme(
                                data: ThemeData.light(useMaterial3: true),
                                child: Dialog(backgroundColor: Colors.white, child: child!),
                              ),
                            );
                            if (picked != null) setState(() => selectedDate = picked);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                child: const Text('Aggiungi'),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;

    final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
    final note = noteCtrl.text.trim();
    final when = selectedDate ?? DateTime.now();

    ref.read(roommatesProvider.notifier).adjustBudgetFor(me.id, amount);
    ref.read(transactionsProvider.notifier).addTx(
      roommateId: me.id,
      amount: amount,
      note: note,
      category: _mapTodoCategoryToExpense(selectedCategory),
      when: when,
    );
    final txs = ref.read(userTransactionsProvider(me.id));
    if (!txs.any((t) => t.note == note && t.amount == amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: transazione non aggiunta!')),
      );
    }
    // A11y opzionale:
    // SemanticsService.announce('Transazione di ${_money.format(amount)} aggiunta', Directionality.of(context));
  }
}

// ================== TILE COMPATTO (importo → motivo) ==================
class _TxTileCard extends StatelessWidget {
  const _TxTileCard({
    required this.tx,
    required this.money,
    required this.onDelete,
    required this.onEdit,
    this.dense = false,
  });

  final MoneyTx tx;
  final NumberFormat money;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isIn = tx.amount >= 0;
    final amountStr = money.format(tx.amount.abs());
    final dateStr = DateFormat('dd/MM/yy • HH:mm').format(tx.createdAt);
    final catIcon = tx.category.icon;
    final catColor = tx.category.color;
    final catLabel = tx.category.label;

    final amountColor = isIn ? Colors.green.shade700 : Colors.red.shade700;

    final semanticsLabel = StringBuffer()
      ..write(isIn ? 'Entrata ' : 'Uscita ')
      ..write(amountStr)
      ..write(tx.note.trim().isEmpty ? '' : ' per ${tx.note}')
      ..write('. ')
      ..write('Categoria $catLabel. ')
      ..write('In data $dateStr.');

    return Semantics(
      label: semanticsLabel.toString(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2), // Solo margine verticale come todo
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: isIn
              ? [Colors.green.shade50.withOpacity(0.3), Colors.green.shade50.withOpacity(0.7)]
              : [Colors.white, Colors.grey.shade100],
          begin: isIn ? Alignment.bottomRight : Alignment.topLeft,
          end: isIn ? Alignment.topLeft : Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isIn ? Colors.green : catColor).withOpacity(0.07),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: isIn ? Colors.green.shade200 : catColor.withOpacity(0.3),
          width: 0.7,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(6), // Padding compatto come i todo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Prima riga: icona + importo + pulsanti
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icona compatta accanto al testo
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        catIcon,
                        size: 14,
                        color: catColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Importo (principale)
                    Expanded(
                      child: Text(
                        (isIn ? '+ ' : '- ') + amountStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                        ),
                      ),
                    ),
                    // Pulsanti compatti
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            tooltip: 'Modifica',
                            icon: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 16),
                            onPressed: onEdit,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            tooltip: 'Elimina',
                            icon: Icon(Icons.delete_rounded, color: Colors.red.shade700, size: 16),
                            onPressed: onDelete,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Seconda riga: nota (solo se presente)
                if (tx.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 32), // Allineato all'importo
                    child: Text(
                      tx.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
                // Terza riga: data
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 32), // Allineato all'importo
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 10, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
