import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/toast_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _mailController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _mailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _errorText = _mailController.text.isEmpty ? 'Please enter your email address.' : null;
    });

    if (_errorText != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.forgotPassword(_mailController.text);
      ToastService.showToast(context, "Reset mail sent", isSuccess: true);
      setState(() {
        FocusScope.of(context).requestFocus(FocusNode());
        _mailController.text = '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: const Color(0xFF007aff),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Password recovery',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'After submitting the request, you will receive an email with instructions.',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AutofillGroup(
                    child: TextField(
                      controller: _mailController,
                      autofillHints: [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading ? Colors.grey : Color(0xFF007aff),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        shadowColor: Colors.black26,
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        'Send request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 25,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF007aff), size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
