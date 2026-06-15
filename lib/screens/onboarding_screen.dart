import 'package:flutter/material.dart';
import '../constants/themes.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  // Data tiruan gambar & teks sesuai Figma kamu
  final List<Map<String, String>> onboardingData = [
    {
      "image": "https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=500", // Gambar kolam/resort
      "title": "Booking Hotel Anywhere Is Easier"
    },
    {
      "image": "https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=500", // Gambar kamar kasur
      "title": "Plan Your Vacation With StayPoint"
    },
    {
      "image": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=500", // Gambar infinity pool
      "title": "Thousands Of Hotels To Be Found"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingData.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              // 1. Bagian Atas: Gambar Full Screen Melengkung Bawah
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(onboardingData[index]["image"]!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              // 2. Bagian Bawah: Panel Biru Tua Isi Teks & Tombol
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Judul Text Sesuai Slide
                      Text(
                        onboardingData[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      Column(
                        children: [
                          // Tombol Sign Up Kapsul Putih/Abu Terang ala Figma
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE2E8F0), // Warna abu terang figma
                                foregroundColor: AppColors.primaryBg,
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              onPressed: () {
                                // Arahkan ke halaman register atau login dulu
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const RegisterScreen())
                                );
                              },
                              child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Link text ke Login
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            },
                            child: Text(
                              'Already have an account',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}