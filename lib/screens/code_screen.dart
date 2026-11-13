import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/digi_client.dart';
import '../l10n/app_localizations.dart';
import '../widgets/busy_button.dart';
import '../widgets/feedback.dart';
import '../widgets/readable_width.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key, required this.client, required this.challenge, required this.onSignedIn});

  final DigiClient client;
  final LoginChallenge challenge;
  final VoidCallback onSignedIn;

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_form.currentState!.validate()) return;

    final s = S.of(context);
    setState(() => _busy = true);
    try {
      await widget.client.confirm(widget.challenge, _code.text);
      widget.onSignedIn();
    } on DigiException catch (error) {
      if (mounted) showMessage(context, describe(context, error, rejected: s.codeRejected));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.codeTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ReadableWidth(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.codeExplanation, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _code,
                  decoration: InputDecoration(labelText: s.code),
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _confirm(),
                  validator: (value) => value!.length == 6 ? null : s.codeInvalid,
                ),
                const SizedBox(height: 16),
                BusyButton(label: s.confirm, busy: _busy, onPressed: _confirm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
