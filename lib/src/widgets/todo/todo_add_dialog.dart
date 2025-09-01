import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:your_turn/src/models/todo_item.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'google_avatar_widget.dart';

// Funzione per schiarire i colori scuri
Color lighten(Color color, [double amount = .4]) {
  final hsl = HSLColor.fromColor(color);
  final light = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(light).toColor();
}

void showTodoAddDialog(BuildContext context, WidgetRef outerRef, {TodoItem? preset}) {
  final titleCtrl = TextEditingController(text: preset?.title ?? '');
  final notesCtrl = TextEditingController(text: preset?.notes ?? '');
  final costCtrl = TextEditingController(text: preset?.cost?.toStringAsFixed(2) ?? '');
  DateTime? dueDate = preset?.dueDate;
  final selectedCategories = <TodoCategory>{...preset?.categories ?? const <TodoCategory>[]};
  final selectedRoommates = <String>{...preset?.assigneeIds ?? const <String>[]};

  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final roommates = ref.watch(roommatesProvider);
          final loc = MaterialLocalizations.of(context);
          final formKey = GlobalKey<FormState>();
          final colorScheme = Theme.of(context).colorScheme;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 12,
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
            content: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo titolo migliorato
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        style: TextStyle(color: Colors.grey.shade800),
                        autofocus: true,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Il titolo è obbligatorio' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sezione categoria con design moderno
                    Text(
                      'Categorie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...stockCategories.map((category) {
                            final isSelected = selectedCategories.any((c) => c.id == category.id);
                            final categoryColor = Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000);
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(category.icon, size: 18, color: categoryColor),
                                  const SizedBox(width: 4),
                                  Text(category.name),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  selectedCategories.add(category);
                                } else {
                                  selectedCategories.removeWhere((c) => c.id == category.id);
                                }
                                (context as Element).markNeedsBuild();
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
                    const SizedBox(height: 16),

                    // Campo note migliorato
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: notesCtrl,
                        textInputAction: TextInputAction.next,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Note (opzionale)',
                          prefixIcon: Icon(Icons.notes, color: Colors.blue.shade700),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: 'Aggiungi dettagli...',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo costo migliorato
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: costCtrl,
                        textInputAction: TextInputAction.done,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                        ],
                        decoration: InputDecoration(
                          labelText: 'Costo (€) *',
                          prefixIcon: Icon(Icons.euro, color: Colors.green.shade700),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: 'es. 12.50',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        style: TextStyle(color: Colors.grey.shade800),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Il costo è obbligatorio';
                          final parsed = double.tryParse(v.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) return 'Inserisci un numero valido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sezione assegnazione
                    Text(
                      'Assegna a',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (roommates.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade600),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('Nessun coinquilino disponibile. Fai login.'),
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
                        child: Column(
                          children: roommates.map((r) {
                            final selected = selectedRoommates.contains(r.id);
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: selected ? Colors.blue.shade50 : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: selected
                                  ? Border.all(color: Colors.blue.shade300)
                                  : null,
                              ),
                              child: CheckboxListTile(
                                value: selected,
                                onChanged: (val) {
                                  if (val == true) {
                                    selectedRoommates.add(r.id);
                                  } else {
                                    selectedRoommates.remove(r.id);
                                  }
                                  (context as Element).markNeedsBuild();
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Colors.blue.shade600,
                                title: Row(
                                  children: [
                                    GoogleAvatar(
                                        name: r.name,
                                        photoUrl: r.photoUrl,
                                        radius: 18,
                                        tooltip: r.name),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        r.name,
                                        style: TextStyle(
                                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                          color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Sezione scadenza
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.orange.shade600),
                        title: Text(
                          dueDate == null
                              ? 'Seleziona scadenza (opzionale)'
                              : 'Scadenza: ${loc.formatShortDate(dueDate!.toLocal())}',
                          style: TextStyle(
                            color: dueDate == null ? Colors.grey.shade600 : Colors.grey.shade800,
                            fontWeight: dueDate == null ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        trailing: dueDate != null
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade600),
                              onPressed: () {
                                dueDate = null;
                                (context as Element).markNeedsBuild();
                              },
                            )
                          : Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.blue.shade700,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.grey.shade800,
                                  ),
                                  dialogBackgroundColor: Colors.white,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            dueDate = picked;
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  if (!(formKey.currentState?.validate() ?? false)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Correggi i campi obbligatori'),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final cost = double.parse(costCtrl.text.replaceAll(',', '.'));

                  if (preset == null) {
                    outerRef.read(todosProvider.notifier).add(
                          title: titleCtrl.text.trim(),
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                          cost: cost,
                          dueDate: dueDate,
                          assigneeIds: selectedRoommates.toList(),
                          categories: selectedCategories.toList(),
                        );
                  } else {
                    outerRef.read(todosProvider.notifier).update(
                          id: preset.id,
                          title: titleCtrl.text.trim(),
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
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
                child: Text(
                  preset == null ? 'Aggiungi Task' : 'Salva Modifiche',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
