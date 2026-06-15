import 'package:flutter/material.dart';

class AppColors {
  // Warna biru tua pekat sesuai latar belakang Figma kamu
  static const Color primaryBg = Color(0xFF0F2B5C); 
  // Warna biru tombol utama (sedikit lebih cerah/kontras)
  static const Color buttonBlue = Color(0xFF1D4ED8); 
  // Warna field input (biru yang sangat gelap transparan atau disesuaikan)
  static const Color fieldBg = Color(0xFF1E3A8A); 
  static const Color textWhite = Colors.white;
  static const Color textHint = Color(0xFF94A3B8); 
}

class AppTextStyle {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textWhite,
  );
}