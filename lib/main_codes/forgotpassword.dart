import 'package:aurion_hotel/_components/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isFilled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkField);
  }

  void _checkField() {
    setState(() {
      _isFilled = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent! Check your Spam 📩"),
          duration: Duration(seconds: 6), // stays longer
        ),
      );

      Navigator.pop(context); // ✅ back to login after success
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // light theme bg
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                height: 160,
                child: Image.asset(
                  "assets/icon.jpg", //
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),

              // Title
              const Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 5),

              // Subtext
              const Text(
                "Enter your email to reset your password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),

              const SizedBox(height: 25),

              // Email Field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: Colors.black),
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: auxColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.black; // inactive
                        }
                        return auxColor; // active
                      },
                    ),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: _isFilled ? auxColor : Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  onPressed: (_isFilled && !_isLoading) ? _resetPassword : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color:
                                auxColor, // white spinner inside green button
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Change Password",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // Back to Login link
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Back to Login",
                  style: TextStyle(
                    color: auxColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
