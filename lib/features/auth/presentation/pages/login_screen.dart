import 'package:chiya_sathi/common/my_snack_bar.dart';
import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:chiya_sathi/core/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricLabel = 'Biometric';
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricLoginEnabled();
    final label = await _biometricService.getBiometricLabel();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _biometricLabel = label;
      });
    }
  }

  Future<void> _loginWithBiometric() async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Verify your identity to log in',
    );
    if (!authenticated || !mounted) return;

    final credentials = await _biometricService.getStoredCredentials();
    if (credentials == null) {
      showMySnackBar(
        context: context,
        message: 'Stored credentials not found. Please log in manually.',
        color: Colors.orange,
      );
      return;
    }

    ref.read(authViewModelProvider.notifier).login(
          email: credentials['email']!,
          password: credentials['password']!,
        );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  Future<void> _showBiometricOptIn(String destination) async {
    final label = _biometricLabel;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.orange.shade600, size: 28),
            const SizedBox(width: 10),
            Text('Enable $label?'),
          ],
        ),
        content: Text(
          'Would you like to use $label to log in next time? '
          'Your credentials will be stored securely on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Not Now', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Enable $label'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _biometricService.saveCredentials(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        destination,
        (route) => false,
      );
    }
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
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

    ref.listen<AuthState>(authViewModelProvider, (previous, next) async {
      if (next.error != null) {
        showMySnackBar(
          context: context,
          message: next.error!,
          color: Colors.red,
        );
      }

      if (next.user != null && !next.isLoading) {
        // Reset table data on fresh login
        final authBox = Hive.box(HiveTableConstants.authBox);
        authBox.delete('tableId');
        authBox.delete('tableScannedAt');

        final role = authBox.get('userRole', defaultValue: 'customer');
        final destination = role == 'owner' ? '/owner_dashboard' : '/dashboard';

        showMySnackBar(
          context: context,
          message: "Login Successful",
          color: Colors.green,
        );

        // Show biometric opt-in if available and not already enabled
        if (_biometricAvailable && !_biometricEnabled) {
          await _showBiometricOptIn(destination);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            destination,
            (route) => false,
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sign In',
            style: TextStyle(color: Colors.black, fontSize: 18)),
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
                'Welcome to ChiyaSathi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              const Text('EMAIL ADDRESS', style: _labelStyle),
              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                validator: (v) {
                  if (v!.isEmpty) return "Email can't be empty";
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                    return "Enter valid email";
                  }
                  return null;
                },
                decoration:
                    _decoration("Enter your email", suffix: const Icon(Icons.check, color: Colors.orange)),
              ),

              const SizedBox(height: 30),

              const Text('PASSWORD', style: _labelStyle),
              const SizedBox(height: 8),

              TextFormField(
                controller: passwordController,
                obscureText: hidePassword,
                validator: (v) {
                  if (v!.isEmpty) return "Password can't be empty";
                  if (v.length < 8) return "Min 8 characters";
                  return null;
                },
                decoration: _decoration(
                  "Enter password",
                  suffix: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      authState.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SIGN IN',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              // Biometric login button
              if (_biometricAvailable && _biometricEnabled)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading ? null : _loginWithBiometric,
                        icon: Icon(Icons.fingerprint,
                            size: 24, color: Colors.orange.shade600),
                        label: Text(
                          'Sign in with $_biometricLabel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              if (!(_biometricAvailable && _biometricEnabled))
                const SizedBox(height: 24),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account?  ",
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    children: [
                      TextSpan(
                        text: "Create new account",
                        style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                              Navigator.pushNamed(
                                context,
                                '/signup',
                                arguments: args,
                              );
                            },
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
}

const _labelStyle = TextStyle(
  fontSize: 12,
  color: Colors.grey,
  letterSpacing: 1.2,
);
