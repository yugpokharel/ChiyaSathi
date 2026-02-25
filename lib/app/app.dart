import 'package:chiya_sathi/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:chiya_sathi/features/auth/presentation/pages/login_screen.dart';
import 'package:chiya_sathi/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:chiya_sathi/features/auth/presentation/pages/signup_screen.dart';
import 'package:chiya_sathi/features/splash/presentation/pages/splash_screen.dart';
import 'package:chiya_sathi/features/qr_scanner/presentation/pages/qr_scanner_screen.dart';
import 'package:chiya_sathi/features/role_selection/presentation/pages/role_selection_screen.dart';
import 'package:chiya_sathi/features/owner/presentation/pages/owner_dashboard_screen.dart';
import 'package:chiya_sathi/app/theme/app_theme.dart';
import 'package:chiya_sathi/features/menu/presentation/pages/menu_category_screen.dart';
import 'package:chiya_sathi/features/menu/presentation/pages/order_status_screen.dart';
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
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/owner_dashboard': (context) => const OwnerDashboardScreen(),
        '/qr_scanner': (context) => const QRScannerScreen(),
        '/order_status': (context) => const OrderStatusScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic /menu/<category> routes
        if (settings.name != null && settings.name!.startsWith('/menu/')) {
          final category = settings.name!.substring('/menu/'.length);
          return MaterialPageRoute(
            builder: (_) => MenuCategoryScreen(category: category),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
