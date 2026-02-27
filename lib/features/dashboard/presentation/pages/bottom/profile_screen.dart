import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/order_provider.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/cart_provider.dart';
import 'package:chiya_sathi/core/services/biometric_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;
  final ImagePicker _imagePicker = ImagePicker();
  final BiometricService _biometricService = BiometricService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricLabel = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
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

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Need to prompt for credentials since we're enabling from profile
      final email = ref.read(authViewModelProvider).user?.email;
      if (email == null) return;
      // Ask user to confirm password to store credentials
      final password = await _showPasswordConfirmDialog();
      if (password == null || !mounted) return;
      await _biometricService.saveCredentials(email: email, password: password);
    } else {
      await _biometricService.disableBiometric();
    }
    if (mounted) {
      setState(() => _biometricEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? '$_biometricLabel login enabled'
              : '$_biometricLabel login disabled'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<String?> _showPasswordConfirmDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Confirm Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your password to enable $_biometricLabel login.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(ctx, controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);

      final success = await ref
          .read(authViewModelProvider.notifier)
          .updateProfilePicture(File(pickedFile.path));

      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Profile picture updated!'
                : 'Failed to update profile picture'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authEntity = authState.user;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: authEntity != null
          ? SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header with gradient
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        child: Column(
                          children: [
                            const Text(
                              'My Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildProfilePicture(
                              authEntity.profilePicture,
                              showEditButton: true,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              authEntity.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${authEntity.username}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 14,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoTile(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: authEntity.email,
                        ),
                        _buildInfoTile(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: authEntity.phoneNumber,
                        ),
                        _buildInfoTile(
                          icon: Icons.person_outline,
                          label: 'Username',
                          value: authEntity.username,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings / Actions section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          icon: Icons.table_bar_outlined,
                          label: 'Reset Table',
                          subtitle: 'Clear your current table assignment',
                          onTap: () {
                            final authBox =
                                Hive.box(HiveTableConstants.authBox);
                            authBox.delete('tableId');
                            authBox.delete('tableScannedAt');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Table reset successfully'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        if (_biometricAvailable)
                          _buildBiometricTile(),
                        _buildActionTile(
                          icon: Icons.info_outline,
                          label: 'About ChiyaSathi',
                          subtitle: 'Version 1.0.0',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'ChiyaSathi',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2026 ChiyaSathi',
                              children: [
                                const SizedBox(height: 16),
                                const Text(
                                  'Your favourite tea shop companion. '
                                  'Scan a table QR, browse the menu, '
                                  'and place your order — all from your phone.',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context, ref),
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade500,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No user logged in',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              // Clear table, order, cart
              final authBox = Hive.box(HiveTableConstants.authBox);
              authBox.delete('tableId');
              authBox.delete('tableScannedAt');
              ref.read(orderProvider.notifier).clearOrder();
              ref.read(cartProvider.notifier).clearCart();

              Navigator.pop(ctx); // close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(String? profilePicturePath, {bool showEditButton = false}) {
    return GestureDetector(
      onTap: showEditButton ? _pickAndUploadPhoto : null,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _isUploadingPhoto
                  ? Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : profilePicturePath != null && profilePicturePath.isNotEmpty
                      ? _buildImageWidget(profilePicturePath)
                      : Container(
                          color: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.orange.shade300,
                          ),
                        ),
            ),
          ),
          if (showEditButton && !_isUploadingPhoto)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('/uploads')) {
      final url = imagePath.startsWith('http')
          ? imagePath
          : 'http://192.168.1.5:5000$imagePath';

      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.white,
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey.shade400,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else if (File(imagePath).existsSync()) {
      return Image.file(File(imagePath), fit: BoxFit.cover);
    } else {
      return Container(
        color: Colors.white,
        child: Icon(
          Icons.broken_image,
          size: 50,
          color: Colors.grey.shade400,
        ),
      );
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.orange.shade600),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
