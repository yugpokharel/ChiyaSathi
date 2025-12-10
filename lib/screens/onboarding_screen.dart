import 'package:flutter/material.dart';
import '../widgets/my_button_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/chiyasathi_logo.png',
                width: 200,
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome to ChiyaSathi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Order smart. Serve faster. Manage better.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: MyButtonWidgets(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  text: 'GET STARTED',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
