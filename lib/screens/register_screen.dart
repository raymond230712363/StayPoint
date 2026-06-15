import 'package:flutter/material.dart';
import '../constants/themes.dart';
import '../widgets/custom_input.dart';
import '../api_service.dart';
import 'login_screen.dart';
import 'verification_screen.dart'; // <-- 1. SUDAH DI-IMPORT BIAR BISA PINDAH KE VERIFIKASI

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void handleRegister() async {
    // Validasi standar sebelum tembak API
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi, gaes!'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    // Validasi panjang nomor telepon minimal 8 angka
    else if (_phoneController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon minimal harus 8 angka ya, gaes!'), 
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Stop proses di sini
    }

    setState(() => _isLoading = true);
    
    // Tembak API Register Laravel (Urutan Named Parameter Aman & Anti-Ketukar)
    final hasil = await ApiService.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text, 
    );

    setState(() => _isLoading = false);

    if (hasil['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan verifikasi akun Anda.'), backgroundColor: Colors.green),
      );
      
      // Mengarahkan user ke halaman OTP terlebih dahulu dengan melempar data email-nya
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => VerificationScreen(email: _emailController.text),
        ),
      );
      // =================================================================================
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Register Gagal'),
          content: Text(hasil['message'] ?? 'Periksa kembali data yang kamu masukkan.'),
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
              const SizedBox(height: 60),
              const Text('Create Account', style: AppTextStyle.heading),
              const SizedBox(height: 8),
              Text(
                'Start booking with creating account',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 40),
          
              //Label & Input Username
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Username', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _nameController, hintText: 'Create your user name'),
              const SizedBox(height: 16),

              // Label & Input Email
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _emailController, hintText: 'Enter your email'),
              const SizedBox(height: 16),

              // Label & Input Phone Number
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Phone Number', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _phoneController, hintText: 'Enter your phone number'),
              const SizedBox(height: 16),

              // Label & Input Password
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Password', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _passwordController, hintText: 'Create your password', obscureText: true),
              
              
              const SizedBox(height: 24),

              // Tombol Sign Up Kapsul Besar
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
                  onPressed: _isLoading ? null : handleRegister,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.textWhite)
                    : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Oauth Sosial Media Bawah
              _buildSocialButton(Icons.g_mobiledata_rounded, 'Sign up with Google'),
              const SizedBox(height: 12),
              _buildSocialButton(Icons.facebook_rounded, 'Sign up with Facebook'),
              const SizedBox(height: 40),

              // Navigasi ke Login jika sudah punya akun
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  GestureDetector(
                    onTap: () {
                      // Buka halaman Login
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textWhite, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    );
  }
}