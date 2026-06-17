import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1200),
                opacity: _animate ? 1.0 : 0.0,
                child: Column(
                  children: [
                    // LOGO 
                    Image.asset(
                      'assets/logo.png',
                      width: 340,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Very Easy To Book a Hotel',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Tombol GET STARTED
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _animate ? 1.0 : 0.0,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCBD5E1),
                      foregroundColor: const Color(0xFF0F2B5C),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          // DI SINI CUMA DITAMBAHIN INI BIAR FLUTTER PAHAM RUTE, TAMPILAN TETEP SAMA!
                          settings: const RouteSettings(name: '/splash'), 
                          pageBuilder: (context, anim, secAnim) => const OnboardingScreen(),
                          transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    child: const Text('GET STARTED', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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