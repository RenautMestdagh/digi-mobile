import 'package:material_ui/material_ui.dart';

import '../data/digi_client.dart';
import '../l10n/app_localizations.dart';

/// What to tell the user about [error]; [rejected] says what Digi refused.
String describe(BuildContext context, DigiException error, {String? rejected}) {
  final s = S.of(context);

  return switch (error) {
    SessionExpired() => s.sessionExpired,
    NetworkFailure() => s.noConnection,
    Rejected() => rejected ?? s.unexpectedResponse,
    UnexpectedResponse() => s.unexpectedResponse,
  };
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// A message filling the screen, with a button to try again when [onRetry] is given.
class Problem extends StatelessWidget {
  const Problem({super.key, required this.icon, required this.message, this.onRetry});

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          if (retry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: retry, icon: const Icon(Icons.refresh), label: Text(S.of(context).tryAgain)),
          ],
        ],
      ),
    );
  }
}
