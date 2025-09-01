import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/widgets/todo/todo_add_dialog.dart';
import 'package:your_turn/src/widgets/todo/empty_state.dart';
import 'package:your_turn/src/widgets/todo/assignees_avatars.dart';
import 'profile_page.dart';

final todosCategoryFilterProvider = StateProvider<TodoCategory?>((ref) => null);

// Provider for "just you" filter
final todosJustYouFilterProvider = StateProvider<bool>((ref) => false);

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  Color _hexColor(String hex) {
    final value = int.parse(hex.substring(1), radix: 16) + 0xFF000000;
    return Color(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final tasks = ref.watch(filteredTodosProvider);
    final roommates = ref.watch(roommatesProvider);

    return Scaffold(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (user != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.shade700,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user.photoUrl?.isNotEmpty == true
                                  ? Image.network(
                                      user.photoUrl!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _fallbackAvatar(user.name),
                                    )
                                  : _fallbackAvatar(user.name),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.home_rounded, size: 64, color: Colors.blue.shade700),
                        const SizedBox(height: 12),
                        Text(
                          'To-Do Coinquilini',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Organizza la vita di casa insieme',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
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
                              children: const [
                                _ToggleBtn(icon: Icons.list, text: 'Tutti'),
                                _ToggleBtn(icon: Icons.check_circle, text: 'Fatti'),
                                _ToggleBtn(icon: Icons.radio_button_unchecked, text: 'Da fare'),
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
                              children: const [
                                _ToggleBtn(icon: Icons.calendar_today, text: 'Data'),
                                _ToggleBtn(icon: Icons.euro, text: 'Costo'),
                                _ToggleBtn(icon: Icons.add_circle, text: 'Nuovo'),
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
                                    const Text('Tutte'),
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
                              ...stockCategories.map((category) {
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
                    ),
                  ),
                ),
              ),
            ),

            // Lista task con separatore manuale (compatibile con Flutter stabile)
            if (tasks.isEmpty)
              const EmptyStateSliver()
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final t = tasks[index];
                    final assigned = roommates.where((r) => t.assigneeIds.contains(r.id)).toList();
                    final dueStr = t.dueDate == null
                        ? null
                        : MaterialLocalizations.of(context).formatShortDate(t.dueDate!.toLocal());
                    final completedStr = (t.status == TodoStatus.done && t.completedAt != null)
                        ? MaterialLocalizations.of(context).formatShortDate(t.completedAt!.toLocal())
                        : null;
                    final isCompleted = t.status == TodoStatus.done;

                    final item = Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: isCompleted
                              ? [Colors.green.shade50, Colors.green.shade100]
                              : [Colors.white, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted
                                ? Colors.green
                                : Colors.blue)
                                .withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isCompleted ? Colors.green.shade200 : Colors.blue.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => ref.read(todosProvider.notifier).toggleDone(t.id),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCheckbox(isCompleted),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTitleArea(t, isCompleted)),
                                    _buildActions(context, ref, t),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (assigned.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.people_rounded, size: 18, color: Colors.grey.shade600),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Assegnato a:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: AssigneesAvatars(assignees: assigned)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final cat in t.categories)
                                      _buildCategoryChip(
                                        _hexColor(cat.color),
                                        cat.icon,
                                        cat.name,
                                      ),
                                    if (t.cost != null)
                                      _infoChip(
                                        bg: Colors.green.shade100,
                                        border: Colors.green.shade300,
                                        icon: Icons.euro_rounded,
                                        iconColor: Colors.green.shade700,
                                        text: '€${t.cost!.toStringAsFixed(2)}',
                                        textColor: Colors.green.shade700,
                                      ),
                                    if (dueStr != null)
                                      _infoChip(
                                        bg: Colors.orange.shade100,
                                        border: Colors.orange.shade300,
                                        icon: Icons.schedule_rounded,
                                        iconColor: Colors.orange.shade700,
                                        text: 'Scade: $dueStr',
                                        textColor: Colors.orange.shade700,
                                      ),
                                    if (completedStr != null)
                                      _infoChip(
                                        bg: Colors.green.shade100,
                                        border: Colors.green.shade300,
                                        icon: Icons.check_circle_rounded,
                                        iconColor: Colors.green.shade700,
                                        text: 'Fatto: $completedStr',
                                        textColor: Colors.green.shade700,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    // Aggiunge lo spacing tra gli item (tranne dopo l’ultimo)
                    return Column(
                      children: [
                        const SizedBox(height: 6),
                        item,
                        if (index != tasks.length - 1) const SizedBox(height: 12),
                      ],
                    );
                  },
                  childCount: tasks.length,
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTodoAddDialog(context, ref),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'Nuovo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
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

  Widget _buildTitleArea(dynamic t, bool isCompleted) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        t.title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isCompleted ? Colors.green.shade700 : Colors.grey.shade800,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: Colors.green.shade400,
          decorationThickness: 2,
        ),
      ),
      if (t.notes?.isNotEmpty ?? false) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Text(
            t.notes!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
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
          tooltip: 'Modifica',
          icon: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 20),
          onPressed: () => showTodoAddDialog(context, ref, preset: t),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          tooltip: 'Elimina',
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