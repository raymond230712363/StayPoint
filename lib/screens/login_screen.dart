import 'package:flutter/material.dart';
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

  void handleLogin() async {
    setState(() => _isLoading = true);
    final hasil = await ApiService.login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (hasil['success'] == true) {
      String namaUser = hasil['user']['name']; // Ambil data dinamis asli dari database
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang, $namaUser!'), backgroundColor: Colors.green),
      );

      // ==================== KUNCINYA DI SINI GAES! ====================
      // Kita panggil rute '/main' (MainNavigation) sambil bawa data namaUser asli
      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: namaUser, // <-- DIKIRIM SECARA DINAMIS KE MAIN.DART!
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
              _buildSocialButton(Icons.g_mobiledata_rounded, 'Sign up with Google'),
              const SizedBox(height: 12),
              _buildSocialButton(Icons.facebook_rounded, 'Sign up with Facebook'),
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
        Text(text, style: TextStyle(color: AppColors.textWhite.withOpacity(0.8), fontSize: 13)),
      ],
    );
  }
}