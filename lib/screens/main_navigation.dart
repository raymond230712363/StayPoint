import 'package:flutter/material.dart';
import '../constants/themes.dart';
import 'booking_history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String username;
  final String email;
  const MainNavigation({
    super.key,
    required this.username,
    required this.email,

  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  // === PERBAIKAN 1: BUAT VARIABEL STATE LOKAL YANG BISA BERUBAH ===
  late String _currentUsername;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username; // Ambil nilai awal dari login
  }

  @override
  Widget build(BuildContext context) {
    // Jalur screens utama yang dikontrol footer bawah
    final List<Widget> _screens = [
      // === PERBAIKAN 2: HOME SCREEN MEMBACA VARIABEL DINAMIS ===
      HomeScreen(username: _currentUsername, email: widget.email),
      const Scaffold(
        backgroundColor: AppColors.primaryBg,
        body: Center(
          child: Text('Favorite Screen', style: TextStyle(color: Colors.white)),
        ),
      ),
      BookingHistoryScreen(email: widget.email, username: _currentUsername),

      // === PERBAIKAN 3: PROFILE SCREEN IKUT MENERIMA FUNGSI CALLBACK UNTUK UPDATE NAMA ===
      ProfileScreen(
        username: _currentUsername,
        email: widget.email,
        onNameUpdated: (newParamName) {
          setState(() {
            _currentUsername =
                newParamName; // Homepage otomatis ikut ganti secara live!
          });
        },
      ),
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
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 20,
              spreadRadius: 1,
            ),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'My profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
