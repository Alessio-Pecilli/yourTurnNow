import 'package:flutter/material.dart';

import 'google_avatar_widget.dart';


class AssigneesAvatars extends StatelessWidget {
  const AssigneesAvatars({super.key, required this.assignees, this.maxVisible = 5});

  final List<dynamic> assignees; // puoi tipizzarlo con Roommate se vuoi
  final int maxVisible;

  static const double _r = 18.0;
  static const double _d = _r * 2;
  static const double _overlap = 14;
  static const double _step = _d - _overlap;

  @override
  Widget build(BuildContext context) {
    final visible = assignees.take(maxVisible).toList();
    final extra = assignees.length - visible.length;

    final visCount = visible.length;
    final baseWidth = visCount == 0 ? 0 : _d + (visCount - 1) * _step;
    final totalWidth = baseWidth + (extra > 0 ? _d : 0);

    return SizedBox(
      height: _d,
      width: totalWidth.toDouble(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * _step,
              child: GoogleAvatar(
                name: visible[i].name,
                photoUrl: visible[i].photoUrl,
                radius: _r,
                tooltip: visible[i].name,
              ),
            ),
          if (extra > 0)
            Positioned(left: visible.length * _step, child: _ExtraCountPill(count: extra)),
        ],
      ),
    );
  }
}

class _ExtraCountPill extends StatelessWidget {
  const _ExtraCountPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
      ),
      child: Text('+$count'),
    );
  }
}
