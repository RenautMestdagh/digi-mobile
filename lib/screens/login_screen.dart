import 'package:material_ui/material_ui.dart';

import '../data/digi_client.dart';
import '../l10n/app_localizations.dart';
import '../widgets/busy_button.dart';
import '../widgets/feedback.dart';
import '../widgets/readable_width.dart';
import 'code_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.client, required this.onSignedIn});

  final DigiClient client;
  final VoidCallback onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _passwordVisible = false;
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (!_form.currentState!.validate()) return;

    final s = S.of(context);
    final language = Localizations.localeOf(context).languageCode;
    setState(() => _busy = true);
    final LoginChallenge challenge;
    try {
      challenge = await widget.client.logIn(_email.text.trim(), _password.text, language: language);
    } on DigiException catch (error) {
      if (mounted) showMessage(context, describe(context, error, rejected: s.loginRejected));
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CodeScreen(client: widget.client, challenge: challenge, onSignedIn: widget.onSignedIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ReadableWidth(
              child: Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      Semantics(
                        label: 'DIGI',
                        image: true,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('assets/icon/icon.png', width: 96, height: 96),
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(labelText: s.email, prefixIcon: const Icon(Icons.email_outlined)),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email, AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        validator: (value) => value!.trim().isEmpty ? s.emailMissing : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        decoration: InputDecoration(
                          labelText: s.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _passwordVisible ? s.hidePassword : s.showPassword,
                            icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                          ),
                        ),
                        obscureText: !_passwordVisible,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _logIn(),
                        validator: (value) => value!.isEmpty ? s.passwordMissing : null,
                      ),
                      const SizedBox(height: 24),
                      BusyButton(label: s.logIn, busy: _busy, onPressed: _logIn),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (_) => ForgotPasswordScreen(client: widget.client)),
                        ),
                        child: Text(s.forgotPassword),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
