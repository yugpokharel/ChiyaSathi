import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const Color _brandOrange = Color(0xFFF5A623);
  static const Color _brandDark = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8ED), // warm cream
              Color(0xFFFFF1D6), // soft peach
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo with soft glow ──
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _brandOrange.withValues(alpha: 0.18),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/chiyasathi_logo.png',
                    width: size.width * 0.42,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Title ──
                const Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8A8A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ChiyaSathi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _brandDark,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Subtitle ──
                Text(
                  'Order smart. Serve faster.\nManage better.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 44),

                // ── Feature highlights ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FeatureChip(
                      icon: Icons.receipt_long_rounded,
                      label: 'Easy Orders',
                    ),
                    _FeatureChip(
                      icon: Icons.speed_rounded,
                      label: 'Fast Service',
                    ),
                    _FeatureChip(
                      icon: Icons.insights_rounded,
                      label: 'Smart Stats',
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // ── Get Started button ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/role_selection');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandOrange,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _brandOrange.withValues(alpha: 0.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('GET STARTED'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small feature chip widget ──
class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3DC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF5A623),
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A5A5A),
          ),
        ),
      ],
    );
  }
}
