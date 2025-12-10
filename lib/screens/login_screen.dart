import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../common/my_snack_bar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sign In',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to ChiyaSathi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'EMAIL ADDRESS',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                suffixIcon: const Icon(Icons.check, color: Colors.orange),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'PASSWORD',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  showMySnackBar(
                    context: context,
                    message: "Feature coming soon",
                    color: Colors.orange,
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (email.isEmpty) {
                    showMySnackBar(
                      context: context,
                      message: "Email can't be empty",
                      color: Colors.red,
                    );
                    return;
                  }

                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
                    showMySnackBar(
                      context: context,
                      message: "Enter a valid email",
                      color: Colors.red,
                    );
                    return;
                  }

                  if (password.isEmpty) {
                    showMySnackBar(
                      context: context,
                      message: "Password can't be empty",
                      color: Colors.red,
                    );
                    return;
                  }

                  if (password.length < 8) {
                    showMySnackBar(
                      context: context,
                      message: "Password must be at least 8 characters",
                      color: Colors.red,
                    );
                    return;
                  }

                  showMySnackBar(
                    context: context,
                    message: "Login successful",
                    color: Colors.green,
                  );

                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushNamed(context, '/dashboard');
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Don't have account?     ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    TextSpan(
                      text: "Create new account",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/signup');
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}