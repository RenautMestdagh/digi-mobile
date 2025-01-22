import 'package:digi_mobile/src/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/auth_service.dart';
import '../services/toast_service.dart';
import 'mail_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  int? _selectedVerificationMethod;
  bool _isLoading = false;
  bool _isPasswordVisible = false; // To toggle password visibility

  String? _emailErrorText;
  String? _passwordErrorText;
  bool _verificationError = false;

  late FToast fToast;

  static const Map<int, String> verificationMethods = {
    1: 'Enter Code Manually',
    2: 'Forward Email to App',
  };

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _performLogin() async {
    FocusScope.of(context).requestFocus(FocusNode());

    // Validate inputs
    bool hasError = false;
    setState(() {
      _emailErrorText = _emailController.text.isEmpty ? 'Please enter your email.' : null;
      _passwordErrorText = _passwordController.text.isEmpty ? 'Please enter your password.' : null;
      _verificationError = _selectedVerificationMethod == null;
      hasError = _emailErrorText != null || _passwordErrorText != null || _verificationError;
    });

    if (hasError) {
      ToastService.showToast(context, 'Please complete all fields.');
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Perform authentication steps
      await AuthService.fetchCsrfToken();
      bool loginSuccess = await AuthService.login(_emailController.text, _passwordController.text);

      if (!loginSuccess) {
        ToastService.showToast(context, "Login failed", isSuccess: false);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Send verification code
      await AuthService.sendCode();

      // Navigate to MailAuthScreen (push on top of login screen)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MailAuthScreen(selectedVerificationMethod: _selectedVerificationMethod!),
        ),
      );
    } catch (error) {
      // Handle errors gracefully
      ToastService.showToast(context, "An error occurred. Please try again.", isSuccess: false);
    } finally {
      // Reset loading state
      Future.delayed(Duration(milliseconds: 100), () {  // delayed because of Navigation push animation
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _selectVerificationMethod() {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _verificationError = false;
    });

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Verification Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // First ListTile with rounded corners
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  leading: Icon(Icons.code, color: Color(0xFF007aff)),
                  title: Text('Enter Code Manually'),
                  subtitle: Text('Input the verification code sent to your email.'),
                  trailing: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Information'),
                            content: Text('Enter the confirmation code you\'ll receive in your inbox manually.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(padding: EdgeInsets.all(5), child: Icon(Icons.info_outline, color: Colors.grey)),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedVerificationMethod = 1;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              // Second ListTile with rounded corners (disabled)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.grey.shade300,
                ),
                child: ListTile(
                  leading: Icon(Icons.forward_to_inbox, color: Color(0xFF007aff)),
                  title: Text('Forward Email to App'),
                  subtitle: Text('Coming soon.'),
                  // trailing: GestureDetector(
                  //   onTap: () {
                  //     showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           title: Text('Information'),
                  //           content: Text('Automatically forward the authentication email from DIGI to test.test@gmail.com. The app will read the inbox and retrieve your verification code for you.'),
                  //           actions: <Widget>[
                  //             TextButton(
                  //               child: Text('Close'),
                  //               onPressed: () {
                  //                 Navigator.of(context).pop();
                  //               },
                  //             ),
                  //           ],
                  //         );
                  //       },
                  //     );
                  //   },
                  //   child: Padding(padding: EdgeInsets.all(5), child: Icon(Icons.info_outline, color: Colors.grey)),
                  // ),
                  onTap: null,  // Disable the tap action
                  enabled: false,  // Disable the interaction
                ),
              ),
            ],
          ),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide the keyboard when tapping outside the input fields
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _isPasswordVisible = false;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    autofillHints: [AutofillHints.username],
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      labelText: 'Email',
                      errorText: _emailErrorText,
                      // Dynamically set errorText
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.transparent)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red)),
                      // error color
                      prefixIcon: Icon(
                        Icons.email,
                        color: _emailErrorText != null ? Colors.red : Color(0xFF007aff), // Icon color follows the error state
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _emailErrorText = null; // Reset error when tapping
                      });
                    },
                  ),

                  SizedBox(height: 16),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    autofillHints: [AutofillHints.password],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      labelText: 'Password',
                      errorText: _passwordErrorText,
                      // Dynamically set errorText
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      // error color
                      prefixIcon: Icon(
                        Icons.lock,
                        color: _passwordErrorText != null ? Colors.red : Color(0xFF007aff), // Icon color follows the error state
                      ),
                      suffixIcon: _passwordFocusNode.hasFocus // Show eye icon only when field is focused
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                                });
                              },
                              child: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility, // Toggle eye icon
                                color: _passwordErrorText != null ? Colors.red : Color(0xff7a7a7a),
                              ),
                            )
                          : null, // No suffix icon if the TextField is not focused
                    ),
                    onChanged: (val) {
                      setState(() {
                        _passwordErrorText = null; // Reset error when tapping
                      });
                    },
                  ),

                  SizedBox(height: 24),

                  // Verification Selector
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _selectVerificationMethod,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _verificationError ? Colors.red : Colors.grey[300]!,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        _selectedVerificationMethod == null
                                            ? Icons.mail_lock
                                            : _selectedVerificationMethod == 1
                                                ? Icons.code
                                                : Icons.forward_to_inbox,
                                        color: _verificationError ? Colors.red : Color(0xFF007aff),
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          verificationMethods.containsKey(_selectedVerificationMethod)
                                              ? verificationMethods[_selectedVerificationMethod]!
                                              : 'Verification method',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: _verificationError
                                                ? Colors.red
                                                : _selectedVerificationMethod == null
                                                    ? Color.fromRGBO(107, 117, 117, 1.0)
                                                    : Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Color(0xFF007aff), size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        _selectedVerificationMethod == null ? 'Select' : 'Change',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF007aff),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _performLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading ? Colors.grey : Color(0xFF007aff),
                        // Button color
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
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Forgot Password
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF007aff),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
