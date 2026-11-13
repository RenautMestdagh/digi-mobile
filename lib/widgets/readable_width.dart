import 'package:flutter/widgets.dart';

/// Keeps forms and cards at phone width on a tablet instead of stretching them across the screen.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: child),
    );
  }
}
