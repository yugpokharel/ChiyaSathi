import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/core/services/biometric_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authBox = Hive.box(HiveTableConstants.authBox);
    final token = authBox.get('auth_token');
    final biometricService = BiometricService();
    final biometricEnabled = await biometricService.isBiometricLoginEnabled();

    if (token != null && biometricEnabled) {
      // User was logged in before and has biometric enabled — go to login
      // so they can use biometric button
      Navigator.pushReplacementNamed(context, '/login');
    } else if (token != null) {
      // Has token but no biometric — go to appropriate dashboard
      final role = authBox.get('userRole', defaultValue: 'customer');
      Navigator.pushReplacementNamed(
        context,
        role == 'owner' ? '/owner_dashboard' : '/dashboard',
      );
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/chiyasathi_logo.png', width: 180),
            const SizedBox(height: 20),
            const Text(
              'ChiyaSathi',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Smart chiya, smarter service',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
