import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/todo_item.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/providers/categories_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'google_avatar_widget.dart';

// Funzione per schiarire i colori scuri (non usata ma la lascio se ti serve)
Color lighten(Color color, [double amount = .4]) {
  final hsl = HSLColor.fromColor(color);
  final light = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(light).toColor();
}

void showTodoAddDialog(BuildContext context, WidgetRef outerRef, {TodoItem? preset}) {
  final formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController(text: preset?.title ?? '');
  final notesCtrl = TextEditingController(text: preset?.notes ?? '');
  final costCtrl = TextEditingController(text: preset?.cost?.toStringAsFixed(2) ?? '');

  DateTime? dueDate = preset?.dueDate;
  final selectedCategories = <TodoCategory>{...preset?.categories ?? const <TodoCategory>[]};
  final selectedRoommates = <String>{...preset?.assigneeIds ?? const <String>[]};

  showDialog(
    context: context,
    builder: (dialogCtx) {
      // NESSUN override di Theme: manteniamo i colori della tua app
      return Consumer(
        builder: (context, ref, _) {
          final roommates = ref.watch(roommatesProvider);
          final categories = ref.watch(categoriesProvider);

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 12,
                contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        preset == null ? Icons.add_task : Icons.edit,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      preset == null ? 'Nuovo Task' : 'Modifica Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Titolo e Costo sulla stessa riga per risparmiare spazio
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: TextFormField(
                                    controller: titleCtrl,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: 'Titolo *',
                                      prefixIcon: Icon(Icons.title, color: Colors.blue.shade700),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      labelStyle: TextStyle(color: Colors.grey.shade700),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    style: TextStyle(color: Colors.grey.shade800),
                                    autofocus: true,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? 'Titolo obbligatorio' : null,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: TextFormField(
                                    controller: costCtrl,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Costo (€) *',
                                      prefixIcon: Icon(Icons.euro, color: Colors.green.shade700),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      hintText: '12.50',
                                      labelStyle: TextStyle(color: Colors.grey.shade700),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    style: TextStyle(color: Colors.grey.shade800),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Costo obbligatorio';
                                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                                      if (parsed == null || parsed <= 0) return 'Numero valido';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Categorie e Scadenza affiancate
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Categorie (lato sinistro)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Categorie',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          ...categories.map((category) {
                                            final isSelected = selectedCategories.any((c) => c.id == category.id);
                                            final categoryColor = Color(
                                              int.parse(category.color.substring(1), radix: 16) + 0xFF000000,
                                            );
                                            return FilterChip(
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(category.icon, size: 16, color: categoryColor),
                                                  const SizedBox(width: 3),
                                                  Text(category.name, style: const TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                setState(() {
                                                  if (selected) {
                                                    selectedCategories.add(category);
                                                  } else {
                                                    selectedCategories.removeWhere((c) => c.id == category.id);
                                                  }
                                                });
                                              },
                                              backgroundColor: Colors.grey.shade50,
                                              selectedColor: Colors.grey.shade200,
                                              checkmarkColor: categoryColor,
                                              side: BorderSide(
                                                color: isSelected ? categoryColor : categoryColor.withOpacity(0.30),
                                                width: isSelected ? 2 : 1,
                                              ),
                                              labelStyle: TextStyle(
                                                color: categoryColor,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Scadenza (lato destro)
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scadenza',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        leading: Icon(Icons.calendar_today, color: Colors.orange.shade600, size: 20),
                                        title: Text(
                                          dueDate == null ? 'Opzionale' : DateFormat('dd/MM').format(dueDate!.toLocal()),
                                          style: TextStyle(
                                            color: dueDate == null ? Colors.grey.shade600 : Colors.grey.shade800,
                                            fontWeight: dueDate == null ? FontWeight.normal : FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: dueDate != null
                                            ? GestureDetector(
                                                onTap: () => setState(() => dueDate = null),
                                                child: Icon(Icons.clear, color: Colors.grey.shade600, size: 16),
                                              )
                                            : Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 12),
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: dueDate ?? DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(const Duration(days: 365)),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context).copyWith(
                                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                                        primary: Colors.blue.shade700,
                                                        onPrimary: Colors.white,
                                                        surface: Colors.white,
                                                        onSurface: Colors.grey.shade800,
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (picked != null) setState(() => dueDate = picked);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Note compatte
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: notesCtrl,
                              textInputAction: TextInputAction.next,
                              maxLines: 2, // Ridotto da 3 a 2 righe
                              decoration: InputDecoration(
                                labelText: 'Note (opzionale)',
                                prefixIcon: Icon(Icons.notes, color: Colors.blue.shade700),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                hintText: 'Dettagli...',
                                labelStyle: TextStyle(color: Colors.grey.shade700),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Assegna a - griglia compatta
                          Text(
                            'Assegna a',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (roommates.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Nessun coinquilino disponibile. Fai login.', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                // Calcola dimensione dinamica in base alla larghezza
                                final boxWidth = constraints.maxWidth / 6; // 6 colonne
                                final minBoxSize = 80.0; // Dimensione minima
                                final dynamicBoxSize = boxWidth < minBoxSize ? minBoxSize : boxWidth;
                                
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: dynamicBoxSize, // Dimensione dinamica
                                    childAspectRatio: 1.8, // Mantieni proporzioni
                                    crossAxisSpacing: 4,
                                    mainAxisSpacing: 4,
                                  ),
                                itemCount: roommates.length,
                                itemBuilder: (context, index) {
                                  final r = roommates[index];
                                  final selected = selectedRoommates.contains(r.id);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selected) {
                                          selectedRoommates.remove(r.id);
                                        } else {
                                          selectedRoommates.add(r.id);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: selected ? Colors.blue.shade100 : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: selected ? Colors.blue.shade500 : Colors.grey.shade400,
                                          width: selected ? 1.5 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 1,
                                            offset: const Offset(0, 0.5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GoogleAvatar(
                                            name: r.name,
                                            photoUrl: r.photoUrl,
                                            radius: 22, // Avatar grande ma adattato all'altezza
                                            tooltip: r.name,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            r.name.split(' ').first,
                                            style: TextStyle(
                                              fontWeight: selected ? FontWeight.bold : FontWeight.w700,
                                              color: selected ? Colors.blue.shade800 : Colors.grey.shade800,
                                              fontSize: 16, // Nome grande ma adattato
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          if (selected)
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.blue.shade600,
                                              size: 14,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                              }),
                            ),

                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Annulla'),
                  ),
                  FilledButton(
                    onPressed: () {
                      

                      final cost = double.parse(costCtrl.text.replaceAll(',', '.'));

                      if (preset == null) {
                        outerRef.read(todosProvider.notifier).add(
                              title: titleCtrl.text.trim(),
                              notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                              cost: cost,
                              creatorId:  ref.watch(userProvider)!.id,
                              dueDate: dueDate,
                              assigneeIds: selectedRoommates.toList(),
                              categories: selectedCategories.toList(),
                            );
                      } else {
                        outerRef.read(todosProvider.notifier).update(
                              id: preset.id,
                              title: titleCtrl.text.trim(),
                              notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                              cost: cost,
                              dueDate: dueDate,
                              assigneeIds: selectedRoommates.toList(),
                              categories: selectedCategories.toList(),
                            );
                      }
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Salva', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
