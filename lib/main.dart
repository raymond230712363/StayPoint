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
          final Map<String, dynamic> userData = settings.arguments as Map<String, dynamic>? ?? {
            'username': 'User',
            'email': 'user@gmail.com',
          };
          
          return MaterialPageRoute(
            builder: (context) => MainNavigation(
              username: userData['username'] ?? 'User',
              email: userData['email'] ?? 'user@gmail.com',
            ),
          );
        }
        return null;
      },
      
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}