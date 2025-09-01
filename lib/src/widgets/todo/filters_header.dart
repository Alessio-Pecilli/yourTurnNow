import 'package:flutter/material.dart';

class FiltersHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  FiltersHeader({
    required this.child,
    this.height = 72,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant FiltersHeader oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
