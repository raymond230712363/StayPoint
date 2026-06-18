import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/themes.dart';
import '../widgets/custom_input.dart';
import '../api_service.dart';
import 'package:staypoint/screens/forgot_password_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
);

  void handleLogin() async {
    setState(() => _isLoading = true);
    final hasil = await ApiService.login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (hasil['success'] == true) {
      String namaUser = hasil['user']['name']; 
      String emailUser = hasil['user']['email'] ?? 'user@gmail.com'; 
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang, $namaUser!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: {
          'username': namaUser,
          'email': emailUser,
        }, 
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(hasil['message'] ?? 'Email atau password salah.'),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User klik luar / batal milih akun
        return;
      }

      // Tampilkan loading muter-muter pas nge-proses biar user gak asal klik layar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Tembak data akun Google ke backend Laravel via ApiService
      final hasil = await ApiService.loginWithGoogle(
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email,
        googleId: googleUser.id,
      );

      if (mounted) Navigator.pop(context); // Tutup dialog loading muter-muter tadi

      if (hasil['success'] == true) {
        // Navigasi langsung bypass masuk ke homepage utama secara gagah berani!
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main', arguments: {
            'username': hasil['user']['name'],
            'email': hasil['user']['email'],
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back, ${hasil['user']['name']}!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(hasil['message'] ?? 'Login Google Gagal'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (error) {
      print("Eror Google Sign In: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan sistem: $error'), backgroundColor: Colors.red),
        );
      }
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
              const SizedBox(height: 70),
              const Text('Login Account', style: AppTextStyle.heading),
              const SizedBox(height: 8),
              Text(
                'Enter your email & password number',
                style: TextStyle(color: AppColors.textWhite.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 48),
              CustomInputField(controller: _emailController, hintText: 'Email or Phone Number'),
              CustomInputField(controller: _passwordController, hintText: 'Password', obscureText: true),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Create Account',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                  onPressed: _isLoading ? null : handleLogin,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.textWhite)
                    : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
              
              // === 4. TOMBOL GOOGLE SUDAH TERBUNGKUS ONTAP ===
              _buildSocialButton(Icons.g_mobiledata_rounded, 'Sign up with Google', onTap: _handleGoogleSignIn),
              const SizedBox(height: 12),
              _buildSocialButton(Icons.facebook_rounded, 'Sign up with Facebook', onTap: () {
                // Skenario facebook jika nanti mau dikerjakan mangkal disini gaes
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Mengubah method agar mendukung aksi klik (onTap)
  Widget _buildSocialButton(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textWhite, size: 24),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: AppColors.textWhite.withOpacity(0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}