import 'package:chiya_sathi/common/my_snack_bar.dart';
import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AuthState>(authViewModelProvider, (previous, next) {
        if (next.status == AuthStatus.error && next.errorMessage != null) {
          showMySnackBar(
            context: context,
            message: next.errorMessage!,
            color: Colors.red,
          );
        }

        if (next.status == AuthStatus.registered) {
          showMySnackBar(
            context: context,
            message: "Signup Successful",
            color: Colors.green,
          );

          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    });
  }

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
    if (_formKey.currentState!.validate()) {
      if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
        showMySnackBar(
          context: context,
          message: "Passwords do not match",
          color: Colors.red,
        );
        return;
      }
      
      ref.read(authViewModelProvider.notifier).register(
            fullName: fullNameController.text.trim(),
            username: usernameController.text.trim(),
            phoneNumber: phoneController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      suffixIcon: suffix,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

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
          'Sign Up',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create your account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _buildField("FULL NAME", fullNameController, "Enter full name"),
              _buildField("USERNAME", usernameController, "Enter username"),
              _buildField("PHONE NUMBER", phoneController, "Enter phone number"),
              _buildField(
                "EMAIL ADDRESS",
                emailController,
                "Enter your email",
                validator: (v) {
                  if (v == null || v.isEmpty) return "Email can't be empty";
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return "Enter valid email";
                  return null;
                },
              ),
              _buildPasswordField(
                "PASSWORD",
                passwordController,
                hidePassword,
                () => setState(() => hidePassword = !hidePassword),
              ),
              _buildPasswordField(
                "CONFIRM PASSWORD",
                confirmPasswordController,
                hideConfirm,
                () => setState(() => hideConfirm = !hideConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Confirm password required";
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SIGN UP',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account?  ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    children: [
                      TextSpan(
                        text: "Log in",
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamed(context, '/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator ?? (v) => v!.isEmpty ? "$label required" : null,
          decoration: _inputDecoration(hint),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool hide,
      VoidCallback toggle,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: hide,
          validator: validator ?? (v) => v!.isEmpty ? "$label required" : null,
          decoration: _inputDecoration(
            "Enter password",
            suffix: IconButton(
              icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
              onPressed: toggle,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

const _labelStyle = TextStyle(
  fontSize: 12,
  color: Colors.grey,
  letterSpacing: 1.2,
);
