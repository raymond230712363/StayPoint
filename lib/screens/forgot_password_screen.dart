import 'package:flutter/material.dart';
import '../constants/themes.dart';
import '../widgets/custom_input.dart';
import '../api_service.dart';
import 'verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void handleForgotPassword() async {
    // Validasi lokal apakah kolom email kosong
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email wajib diisi, gaes!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // embak fungsi API di ApiService
    final hasil = await ApiService.forgotPassword(_emailController.text);
    
    setState(() => _isLoading = false);

    // Cek respon dari backend Laravel
    if (hasil['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP berhasil dikirim!'), backgroundColor: Colors.green),
      );

      // Jika email terdaftar & sukses kirim OTP, baru lempar ke halaman Verifikasi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(email: _emailController.text,
          username: hasil['user']?['name'] ?? 'user', 
          isResetPasswordFlow: true,
          ),
        ),
      );
    } else {
      // EROR HANDLING
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email Tidak Ditemukan'),
          content: Text(hasil['message'] ?? 'Email yang kamu masukkan belum terdaftar di StayPoint, gaes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Forgot Password', style: AppTextStyle.heading),
              const SizedBox(height: 8),
              Text(
                'Enter your email account to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 50),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _emailController, hintText: 'Enter your email'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: AppColors.textWhite,
                    shape: const StadiumBorder(),
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : handleForgotPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.textWhite)
                      : const Text('Send', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
