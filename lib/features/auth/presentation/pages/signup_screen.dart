import 'package:chiya_sathi/common/my_snack_bar.dart';
import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  // Owner-specific controllers
  final cafeNameController = TextEditingController();
  final cafeAddressController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  String get _role {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['role'] ?? 'customer';
  }

  bool get _isOwner => _role == 'owner';

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    cafeNameController.dispose();
    cafeAddressController.dispose();
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

      // Save owner café details to Hive
      if (_isOwner) {
        if (cafeNameController.text.trim().isEmpty ||
            cafeAddressController.text.trim().isEmpty) {
          showMySnackBar(
            context: context,
            message: "Please fill in all café details",
            color: Colors.red,
          );
          return;
        }
        final box = Hive.box(HiveTableConstants.authBox);
        box.put('cafeName', cafeNameController.text.trim());
        box.put('cafeAddress', cafeAddressController.text.trim());
      }

      ref.read(authViewModelProvider.notifier).register(
            fullName: fullNameController.text.trim(),
            username: usernameController.text.trim(),
            phoneNumber: phoneController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            profilePicture: _selectedImage,
            role: _role,
          );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      showMySnackBar(
        context: context,
        message: "Error picking image: $e",
        color: Colors.red,
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

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.error != null) {
        showMySnackBar(
          context: context,
          message: next.error!,
          color: Colors.red,
        );
      }

      if (next.user == null && !next.isLoading && next.error == null && previous?.isLoading == true) {
        showMySnackBar(
          context: context,
          message: "Signup Successful",
          color: Colors.green,
        );

        Navigator.pushReplacementNamed(context, '/login');
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
        title: Text(
          _isOwner ? 'Owner Sign Up' : 'Sign Up',
          style: const TextStyle(color: Colors.black, fontSize: 18),
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
              Text(
                _isOwner ? 'Create your owner account' : 'Create your account',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildProfilePicturePicker(),
              const SizedBox(height: 30),
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

              // Owner-specific fields
              if (_isOwner) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Café Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildField("CAFÉ NAME", cafeNameController, "Enter your café name"),
                      _buildField("CAFÉ ADDRESS", cafeAddressController, "Enter café address"),
                    ],
                  ),
                ),
              ],

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
                  onPressed: authState.isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authState.isLoading
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

  Widget _buildProfilePicturePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PROFILE PICTURE', style: _labelStyle),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedImage != null ? Colors.orange : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to select a picture (optional)',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

const _labelStyle = TextStyle(
  fontSize: 12,
  color: Colors.grey,
  letterSpacing: 1.2,
);
