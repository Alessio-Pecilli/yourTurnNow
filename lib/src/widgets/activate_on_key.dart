import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivateOnKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onActivate;

  const ActivateOnKey({super.key, required this.child, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: true,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<Intent>(onInvoke: (_) {
              onActivate();
              return null;
            }),
          },
          child: child,
        ),
      ),
    );
  }
}
