import 'package:material_ui/material_ui.dart';

import '../data/digi_client.dart';
import '../l10n/app_localizations.dart';
import '../widgets/busy_button.dart';
import '../widgets/feedback.dart';
import '../widgets/readable_width.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.client});

  final DigiClient client;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;

    final s = S.of(context);
    final language = Localizations.localeOf(context).languageCode;
    setState(() => _busy = true);
    try {
      await widget.client.requestPasswordReset(_email.text.trim(), language: language);
      if (!mounted) return;
      showMessage(context, s.resetSent);
      Navigator.pop(context);
    } on DigiException catch (error) {
      if (mounted) showMessage(context, describe(context, error, rejected: s.resetRejected));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.resetTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ReadableWidth(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.resetExplanation, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: s.email, prefixIcon: const Icon(Icons.email_outlined)),
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _send(),
                  validator: (value) => value!.trim().isEmpty ? s.emailMissing : null,
                ),
                const SizedBox(height: 16),
                BusyButton(label: s.resetSend, busy: _busy, onPressed: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
