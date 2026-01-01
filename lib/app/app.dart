import 'package:chiya_sathi/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:chiya_sathi/features/auth/presentation/pages/login_screen.dart';
import 'package:chiya_sathi/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:chiya_sathi/features/auth/presentation/pages/signup_screen.dart';
import 'package:chiya_sathi/features/splash/presentation/pages/splash_screen.dart';
import 'package:chiya_sathi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chiya Sathi',
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
