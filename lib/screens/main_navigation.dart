import 'package:flutter/material.dart';
import '../constants/themes.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String username;
  const MainNavigation({super.key, required this.username});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Jalur screens utama yang dikontrol footer bawah
    final List<Widget> _screens = [
      HomeScreen(username: widget.username), // <-- Sinkron dengan parameter HomeScreen-mu!
      const Scaffold(backgroundColor: AppColors.primaryBg, body: Center(child: Text('Favorite Screen', style: TextStyle(color: Colors.white)))),
      const Scaffold(backgroundColor: AppColors.primaryBg, body: Center(child: Text('Offers Screen', style: TextStyle(color: Colors.white)))),
      ProfileScreen(username: widget.username), 
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220), 
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primaryBg,
            unselectedItemColor: Colors.black38,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favorite'),
              BottomNavigationBarItem(icon: Icon(Icons.percent_rounded), label: 'Offers'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'My profile'),
            ],
          ),
        ),
      ),
    );
  }
}