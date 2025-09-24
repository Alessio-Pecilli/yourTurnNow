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

enum _TxView { grid, list }

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _visibleTxCount = 10;
  final NumberFormat _money = NumberFormat.currency(locale: 'it_IT', symbol: '€');

  TodoCategory? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  bool _showHelp = true;
  _TxView _view = _TxView.grid; // ✅ default griglia (com’era)

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

  List<MoneyTx> _applyFilters(List<MoneyTx> all) {
    var out = all;
    if (_selectedCategory != null) {
      out = out.where((t) => t.category == _selectedCategory).toList();
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
                    // Vista Lista/Griglia
                    Semantics(
                      label: 'Selettore vista transazioni',
                      child: SegmentedButton<_TxView>(
                        segments: const [
                          ButtonSegment(value: _TxView.grid, icon: Icon(Icons.grid_view, size: 18)),
                          ButtonSegment(value: _TxView.list, icon: Icon(Icons.view_agenda, size: 18)),
                        ],
                        selected: {_view},
                        onSelectionChanged: (s) => setState(() => _view = s.first),
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          minimumSize: WidgetStateProperty.all(const Size(0, 36)),
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 6)),
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.blue.shade700;
                            }
                            return Colors.white;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return Colors.blue.shade700;
                          }),
                          side: WidgetStateProperty.all(BorderSide(color: Colors.blue.shade700, width: 1.5)),
                          textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
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
                          ...categories.take(4).map((category) {
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
                        OutlinedButton.icon(
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
                        const SizedBox(height: 4),
                        TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 24),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () => setState(() {
                            _selectedCategory = null;
                            _selectedDateRange = null;
                          }),
                          child: const Text('Reset'),
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

    if (_view == _TxView.grid) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _TxTileCard(
              tx: visibleTxs[i],
              money: _money,
              onDelete: () => _onDeleteTransaction(context, visibleTxs[i]),
              onEdit: () => _onEditTransaction(context, visibleTxs[i]),
              dense: false,
            ),
            childCount: visibleTxs.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.8,
          ),
        ),
      );
    } else {
      return SliverList.builder(
        itemCount: visibleTxs.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: _TxTileCard(
            tx: visibleTxs[i],
            money: _money,
            onDelete: () => _onDeleteTransaction(context, visibleTxs[i]),
            onEdit: () => _onEditTransaction(context, visibleTxs[i]),
            dense: true, // ✅ layout da lista
          ),
        ),
      );
    }
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_visibleTxCount > 10)
              OutlinedButton(
                onPressed: () => setState(() => _visibleTxCount = 10),
                child: const Text('Vai all\'inizio'),
              ),
            const SizedBox(width: 8),
            if (_visibleTxCount < txs.length)
              OutlinedButton(
                onPressed: () => setState(() {
                  final next = _visibleTxCount + 10;
                  _visibleTxCount = next > txs.length ? txs.length : next;
                }),
                child: const Text('Carica altri'),
              ),
            const SizedBox(width: 8),
            if (_visibleTxCount < txs.length)
              OutlinedButton(
                onPressed: () => setState(() => _visibleTxCount = txs.length),
                child: const Text('Vai alla fine'),
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

    final card = Card(
      elevation: 3,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: EdgeInsets.all(dense ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icona categoria
              Container(
                width: dense ? 36 : 44,
                height: dense ? 36 : 44,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  catIcon,
                  size: dense ? 20 : 24,
                  color: catColor,
                ),
              ),
              const SizedBox(width: 12),
              // Testi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ 1) Importo (prima)
                    Text(
                      (isIn ? '+ ' : '- ') + amountStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: dense ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ✅ 2) Motivo/nota (poi)
                    Text(
                      (tx.note.isEmpty ? '—' : tx.note),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: dense ? 13 : 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Meta
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Azioni
              Semantics(
                label: 'Azioni transazione',
                button: true,
                child: PopupMenuButton<String>(
                  tooltip: 'Azioni',
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Modifica'))),
                    PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Elimina'))),
                  ],
                  icon: const Icon(Icons.more_horiz),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      label: semanticsLabel.toString(),
      child: card,
    );
  }
}
