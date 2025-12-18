import 'package:chiya_sathi/screens/dashboard_screen.dart';
import 'package:chiya_sathi/screens/login_screen.dart';
import 'package:chiya_sathi/screens/onboarding_screen.dart';
import 'package:chiya_sathi/screens/signup_screen.dart';
import 'package:chiya_sathi/screens/splash_screen.dart';
import 'package:chiya_sathi/theme/theme_data.dart';
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
