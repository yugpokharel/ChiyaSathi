import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const Color _brandOrange = Color(0xFFF5A623);
  static const Color _brandDark = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final horizontalPadding = isWide ? 64.0 : 28.0;
          final logoSize = isWide ? constraints.maxWidth * 0.22 : size.width * 0.42;
          final titleFontSize = isWide ? 48.0 : 34.0;
          final subtitleFontSize = isWide ? 22.0 : 16.0;
          final chipSize = isWide ? 72.0 : 56.0;
          final chipFontSize = isWide ? 16.0 : 12.0;
          final buttonHeight = isWide ? 70.0 : 56.0;
          final buttonFontSize = isWide ? 22.0 : 17.0;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1E1E1E),
                        const Color(0xFF121212),
                      ]
                    : [
                        const Color(0xFFFFF8ED),
                        const Color(0xFFFFF1D6),
                        Colors.white,
                      ],
                stops: isDark ? [0.0, 1.0] : [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _brandOrange.withAlpha(46),
                            blurRadius: isWide ? 60 : 40,
                            spreadRadius: isWide ? 18 : 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/chiyasathi_logo.png',
                        width: logoSize,
                      ),
                    ),
                    SizedBox(height: isWide ? 48 : 36),
                    // Title
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
                    SizedBox(height: isWide ? 12 : 6),
                    Text(
                      'ChiyaSathi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _brandDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: isWide ? 24 : 14),
                    // Subtitle
                    Text(
                      'Order smart. Serve faster.\nManage better.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        height: 1.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: isWide ? 60 : 44),
                    // Feature highlights
                    isWide
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _FeatureChip(
                                icon: Icons.receipt_long_rounded,
                                label: 'Easy Orders',
                                size: chipSize,
                                fontSize: chipFontSize,
                              ),
                              _FeatureChip(
                                icon: Icons.speed_rounded,
                                label: 'Fast Service',
                                size: chipSize,
                                fontSize: chipFontSize,
                              ),
                              _FeatureChip(
                                icon: Icons.insights_rounded,
                                label: 'Smart Stats',
                                size: chipSize,
                                fontSize: chipFontSize,
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _FeatureChip(
                                icon: Icons.receipt_long_rounded,
                                label: 'Easy Orders',
                                size: chipSize,
                                fontSize: chipFontSize,
                              ),
                              _FeatureChip(
                                icon: Icons.speed_rounded,
                                label: 'Fast Service',
                                size: chipSize,
                                fontSize: chipFontSize,
                              ),
                              _FeatureChip(
                                icon: Icons.insights_rounded,
                                label: 'Smart Stats',
                                size: chipSize,
                                fontSize: chipFontSize,
                              ),
                            ],
                          ),
                    const Spacer(flex: 3),
                    // Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/role_selection');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandOrange,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: _brandOrange.withAlpha(115),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: TextStyle(
                            fontSize: buttonFontSize,
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
                    SizedBox(height: isWide ? 48 : 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Small feature chip widget ──
class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label, this.size = 56.0, this.fontSize = 12.0});

  final IconData icon;
  final String label;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isDark ? Colors.orange.shade900.withAlpha(80) : const Color(0xFFFFF3DC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF5A623),
            size: size * 0.46,
          ),
        ),
        SizedBox(height: size * 0.14),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF5A5A5A),
          ),
        ),
      ],
    );
  }
}
