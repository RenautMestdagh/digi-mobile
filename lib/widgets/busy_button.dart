import 'package:material_ui/material_ui.dart';

/// A full-width button that shows a spinner instead of its label while its work runs.
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? Semantics(
              label: label,
              child: const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : Text(label),
    );
  }
}
