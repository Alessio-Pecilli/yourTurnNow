import 'package:flutter/material.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/l10n/app_localizations.dart';

typedef OnEditRoommate = void Function(Roommate r);
typedef OnDeleteRoommate = void Function(Roommate r);
typedef OnDeleteCategory = void Function(TodoCategory c);
const height = 330.0;
class CategoriesCard extends StatelessWidget {
  final List<TodoCategory> categories;
  final VoidCallback onAddCategory;
  final VoidCallback onAddCategoryPressed;
  final void Function(TodoCategory) onDelete;

  const CategoriesCard({Key? key, required this.categories, required this.onAddCategory, required this.onAddCategoryPressed, required this.onDelete}) : super(key: key);

  Color _hexToColor(String hex) => Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);

  @override
  Widget build(BuildContext context) {
    return Card(
  elevation: 6,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  color: Colors.white,
  child: ConstrainedBox(
    constraints: const BoxConstraints(minHeight: height), // altezza identica
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.category, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.admin_manage_categories,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800))
          ]),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            Center(
              child: Column(children: [
                Icon(Icons.category_outlined,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.admin_no_categories,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500))
              ]),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.1, // proporzione uniforme
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final c = categories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _hexToColor(c.color),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(c.icon, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(c.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey.shade800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_rounded,
                              color: Colors.red.shade600, size: 16),
                          tooltip: AppLocalizations.of(context)!.common_delete,
                          onPressed: () => onDelete(c),
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    onPressed: onAddCategoryPressed,
    icon: const Icon(Icons.add, color: Colors.white),
    label: Text(
      AppLocalizations.of(context)!.admin_add_category_btn,
      style: const TextStyle(color: Colors.white),
    ),
  ),
)

        ],
      ),
    ),
  ),
);
  }
}

class RoommatesCard extends StatelessWidget {
  final List<Roommate> roommates;
  final void Function(Roommate) onEdit;
  final void Function(Roommate) onDelete;
  final VoidCallback onAddRoommatePressed;

  const RoommatesCard({Key? key, required this.roommates, required this.onEdit, required this.onDelete, required this.onAddRoommatePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
  elevation: 6,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  color: Colors.white,
  child: ConstrainedBox(
    constraints: const BoxConstraints(minHeight: height), // stessa altezza
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.people, color: Colors.blue.shade700, size: 24),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.admin_manage_roommates,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800))
          ]),
          const SizedBox(height: 20),
          if (roommates.isEmpty)
            Center(
              child: Column(children: [
                Icon(Icons.group_off,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.admin_no_roommates,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500))
              ]),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.1, // stessa proporzione delle categorie
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: roommates.length,
              itemBuilder: (context, index) {
                final r = roommates[index];
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(children: [
                      CircleAvatar(
                          radius: 16,
                          backgroundImage: r.photoUrl != null &&
                                  r.photoUrl!.isNotEmpty
                              ? NetworkImage(r.photoUrl!)
                              : null,
                          backgroundColor: Colors.blue.shade700,
                          child: r.photoUrl == null || r.photoUrl!.isEmpty
                              ? Text(
                                  r.name.isNotEmpty
                                      ? r.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14))
                              : null),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(r.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey.shade800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            icon: Icon(Icons.edit_rounded,
                                color: Colors.orange.shade600, size: 16),
                            tooltip: AppLocalizations.of(context)!.common_edit,
                            onPressed: () => onEdit(r),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28)),
                        IconButton(
                            icon: Icon(Icons.delete_rounded,
                                color: Colors.red.shade600, size: 16),
                            tooltip: AppLocalizations.of(context)!.common_delete,
                            onPressed: () => onDelete(r),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28)),
                      ])
                    ]),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    onPressed: onAddRoommatePressed,
    icon: const Icon(Icons.group_add, color: Colors.white),
    label: Text(
      AppLocalizations.of(context)!.admin_add_roommate_btn,
      style: const TextStyle(color: Colors.white),
    ),
  ),
)

        ],
      ),
    ),
  ),
);

  }
}
