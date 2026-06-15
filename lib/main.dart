import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Import splash screen baru

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StayPoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashScreen(), // <-- Set ke sini gaes!
    );
  }
}