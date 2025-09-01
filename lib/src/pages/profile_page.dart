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
import 'package:your_turn/src/models/expense_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';

import 'package:your_turn/src/widgets/tx_tile.dart';
import 'package:your_turn/src/widgets/help_banner.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.userId});
  final String? userId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _visibleTxCount = 5;
  final NumberFormat _money = NumberFormat.currency(locale: 'it_IT', symbol: '€');

  ExpenseCategory? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  bool _showHelp = true;

  static const String _shortcutInfo =
      'Scorciatoie: Alt+A = Aggiungi/Modifica saldo • Alt+D = Scarica CSV';

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
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // più recenti in alto
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
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue, size: 28),
                        tooltip: 'Indietro',
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.go('/todo');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.grey.shade300,
                        child: me.photoUrl != null && me.photoUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  me.photoUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.person, size: 40, color: Colors.grey.shade700),
                                ),
                              )
                            : Icon(Icons.person, size: 40, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                me.name,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              Row(
                                children: [
                                  Tooltip(
                                    message: 'Scarica CSV (Alt+D)',
                                    child: FilledButton.icon(
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
                                  ),
                                  const SizedBox(width: 10),
                                  Tooltip(
                                    message: 'Aggiungi/Modifica saldo (Alt+A)',
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.orange.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: null, // TODO: _onEditBalance(context, me)
                                      icon: const Icon(Icons.edit, size: 20),
                                      label: const Text('Saldo'),
                                    ),
                                  ),
                                  const Spacer(),
                                  Tooltip(
                                    message: 'Aggiungi transazione',
                                    child: FilledButton.icon(
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              SliverToBoxAdapter(
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
                          Text(
                            'Filtra per categoria',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.label_outline,
                                      size: 18,
                                      color: _selectedCategory == null ? Colors.blue.shade700 : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('Tutte'),
                                  ],
                                ),
                                selected: _selectedCategory == null,
                                onSelected: (_) => setState(() => _selectedCategory = null),
                                backgroundColor: Colors.grey.shade50,
                                selectedColor: Colors.blue.shade100,
                                labelStyle: TextStyle(
                                  color: _selectedCategory == null ? Colors.blue.shade700 : Colors.grey.shade600,
                                  fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              ...ExpenseCategory.values.map((cat) {
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(cat.icon, size: 18, color: cat.color),
                                      const SizedBox(width: 4),
                                      Text(cat.label),
                                    ],
                                  ),
                                  selected: _selectedCategory == cat,
                                  onSelected: (_) => setState(() => _selectedCategory = cat),
                                  backgroundColor: Colors.grey.shade50,
                                  selectedColor: Colors.grey.shade200,
                                  labelStyle: TextStyle(
                                    color: cat.color,
                                    fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.w600,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Intervallo date',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _selectedDateRange == null
                                  ? 'Seleziona intervallo'
                                  : '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} – ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                            ),
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                initialDateRange: _selectedDateRange,
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light(),
                                    child: Dialog(
                                      backgroundColor: Colors.white,
                                      child: child!,
                                    ),
                                  );
                                },
                              );
                              if (!mounted) return;
                              setState(() => _selectedDateRange = picked);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCategory = null;
                              _selectedDateRange = null;
                            }),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Storico transazioni',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              txs.isEmpty
                  ? SliverToBoxAdapter(
                      child: _sectionCard(
                        child: Center(
                          child: Text(
                            'Nessuna transazione. Aggiungi la prima.',
                            style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => TxTile(tx: visibleTxs[i], money: _money),
                        childCount: visibleTxs.length,
                      ),
                    ),
              // Paginazione e pulsanti
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_visibleTxCount > 5)
                        OutlinedButton(
                          onPressed: () => setState(() => _visibleTxCount = 5),
                          child: const Text('Vai all\'inizio'),
                        ),
                      const SizedBox(width: 8),
                      if (_visibleTxCount < txs.length)
                        OutlinedButton(
                          onPressed: () => setState(() {
                            final next = _visibleTxCount + 5;
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
              ),
            ],
          ),
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

    // ✅ FIX: niente `+` tra liste. Usa gli spread.
    final bytes = Uint8List.fromList([
      ...const [0xEF, 0xBB, 0xBF], // BOM UTF-8 per Excel
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
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    ExpenseCategory selectedCategory = ExpenseCategory.values.first;
    DateTime? selectedDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Nuova spesa', style: TextStyle(color: Colors.black)),
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
                      decoration: InputDecoration(
                        labelText: 'Importo (€)',
                        hintText: 'positivo = accredito, negativo = addebito',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        labelStyle: const TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obbligatorio';
                        final p = double.tryParse(v.replaceAll(',', '.'));
                        if (p == null || p == 0.0) return 'Inserisci un numero diverso da 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.label_outline, size: 18, color: Colors.blue.shade700),
                              const SizedBox(width: 4),
                              const Text('Tutte'),
                            ],
                          ),
                          selected: false,
                          onSelected: null,
                          backgroundColor: Colors.grey.shade50,
                          selectedColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        ...ExpenseCategory.values.map((cat) {
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 18, color: cat.color),
                                const SizedBox(width: 4),
                                Text(cat.label),
                              ],
                            ),
                            selected: selectedCategory == cat,
                            onSelected: (_) => setState(() => selectedCategory = cat),
                            backgroundColor: Colors.grey.shade50,
                            selectedColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: cat.color,
                              fontWeight: selectedCategory == cat ? FontWeight.bold : FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nota (opzionale)',
                        hintText: 'es. descrizione della spesa',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        labelStyle: const TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Data:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate == null
                                ? 'Oggi'
                                : DateFormat('dd/MM/yyyy').format(selectedDate ?? DateTime.now()),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light(useMaterial3: true),
                                  child: Dialog(
                                    backgroundColor: Colors.white,
                                    child: child!,
                                  ),
                                );
                              },
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
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Aggiungi'),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;

    final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
    final note = noteCtrl.text.trim().isEmpty ? selectedCategory.label : noteCtrl.text.trim();
    final when = selectedDate ?? DateTime.now();

    ref.read(roommatesProvider.notifier).adjustBudgetFor(me.id, amount);
    ref.read(transactionsProvider.notifier).addTx(
      roommateId: me.id,
      amount: amount,
      note: note,
      category: selectedCategory,
      when: when,
    );
    final txs = ref.read(userTransactionsProvider(me.id));
    // ignore: avoid_print
    print('Transazioni utente dopo aggiunta: ${txs.map((t) => t.note).toList()}');
    if (!txs.any((t) => t.note == note && t.amount == amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: transazione non aggiunta!')),
      );
    }
    SemanticsService.announce('${selectedCategory.label} aggiunta', Directionality.of(context));
  }
}
