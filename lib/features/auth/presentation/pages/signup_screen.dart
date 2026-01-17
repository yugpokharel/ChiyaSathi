import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/my_snack_bar.dart';
import '../state/auth_state.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (fullName.isEmpty || username.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showMySnackBar(context: context, message: "All fields are required", color: Colors.red);
      return;
    }

    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      showMySnackBar(context: context, message: "Enter a valid email", color: Colors.red);
      return;
    }

    if (password != confirm) {
      showMySnackBar(context: context, message: "Passwords do not match", color: Colors.red);
      return;
    }

    ref.read(authViewModelProvider.notifier).register(
          fullName: fullName,
          username: username,
          phoneNumber: phone,
          email: email,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        showMySnackBar(context: context, message: next.errorMessage!, color: Colors.red);
      }
      if (next.status == AuthStatus.registered) {
        showMySnackBar(context: context, message: "Signup Successful", color: Colors.green);
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: fullNameController, decoration: const InputDecoration(hintText: "Full Name")),
            TextField(controller: usernameController, decoration: const InputDecoration(hintText: "Username")),
            TextField(controller: phoneController, decoration: const InputDecoration(hintText: "Phone Number")),
            TextField(controller: emailController, decoration: const InputDecoration(hintText: "Email")),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(hintText: "Password")),
            TextField(controller: confirmPasswordController, obscureText: true, decoration: const InputDecoration(hintText: "Confirm Password")),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                child: authState.status == AuthStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIGN UP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
