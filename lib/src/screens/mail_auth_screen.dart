import 'package:digi_mobile/src/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class MailAuthScreen extends StatefulWidget {
  final int selectedVerificationMethod;

  const MailAuthScreen({
    super.key,
    required this.selectedVerificationMethod,
  });

  @override
  State<MailAuthScreen> createState() => _MailAuthScreenState();
}

class _MailAuthScreenState extends State<MailAuthScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  String _retrievedCode = ""; // Retrieved code placeholder

  @override
  void initState() {
    super.initState();
    if (widget.selectedVerificationMethod == 2) {
      _startAutomaticCodeRetrieval();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<String> retrieveCode() async {
    await Future.delayed(const Duration(seconds: 2));
    return "123456"; // Simulated retrieved code
  }

  Future<void> _startAutomaticCodeRetrieval() async {
    setState(() {
      _isLoading = true;
    });

    String code = await retrieveCode();

    setState(() {
      _retrievedCode = code;
      _isLoading = false;
      _codeController.text = _retrievedCode;
    });

    _submitCode();
  }

  Future<void> _submitCode() async {
    setState(() {
      _errorText = _codeController.text.isEmpty ? 'Please enter the verification code.' : null;
    });

    if (_errorText != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool authSuccess = await AuthService.finalizeLogin(_codeController.text);

      if (!authSuccess) throw Exception();

      // ToastService.showToast("oke.", isSuccess: true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Invalid verification code.';
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
                      Icons.email_outlined,
                      size: 80,
                      color: const Color(0xFF007aff),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.selectedVerificationMethod == 1 ? 'Enter Verification Code' : 'Retrieving Verification Code',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.selectedVerificationMethod == 1) ...[
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitCode,
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
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Please wait while the app retrieves your verification code.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF007aff),
                          ),
                        ),
                      )
                    else if (_retrievedCode.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Code Retrieved:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _retrievedCode,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
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
