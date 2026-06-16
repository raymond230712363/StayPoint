import 'package:flutter/material.dart';
import '../constants/themes.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text('My Profile', style: AppTextStyle.heading),
              const SizedBox(height: 32),

              // Avatar Bulat
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(38),
                  border: Border.all(color: Colors.white.withAlpha(76), width: 2),
                ),
                child: const Icon(Icons.person_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Nama User Dinamis
              Text(
                username,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Rentetan Menu Opsi Kapsul Ala Figma
              _buildProfileMenu(Icons.bookmark_outline_rounded, 'My Bookings'),
              _buildProfileMenu(Icons.favorite_border_rounded, 'Favorites'),
              _buildProfileMenu(Icons.settings_outlined, 'Settings'),
              
              const SizedBox(height: 24),
              // Tombol Logout Merah Kapsul
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withAlpha(50),
                    foregroundColor: Colors.redAccent,
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: Colors.redAccent),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Balik ke halaman login total
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        ],
      ),
    );
  }
}