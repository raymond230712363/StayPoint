import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

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
      home: const SplashScreen(), 
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final String usernameData = settings.arguments as String? ?? 'User';
          return MaterialPageRoute(
            builder: (context) => MainNavigation(username: usernameData),
          );
        }
        return null;
      },
      
      // Rute static biasa yang gak butuh data dinamis
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}