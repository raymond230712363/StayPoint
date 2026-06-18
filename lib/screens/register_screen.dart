import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import '../constants/themes.dart';
import '../widgets/custom_input.dart';
import '../api_service.dart';
import 'login_screen.dart';
import 'verification_screen.dart'; 

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  void handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi, gaes!'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (_phoneController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon minimal harus 8 angka ya, gaes!'), 
          backgroundColor: Colors.redAccent,
        ),
      );
      return; 
    }

    setState(() => _isLoading = true);
    
    final hasil = await ApiService.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text, 
    );

    setState(() => _isLoading = false);

    if (hasil['success'] == true) {
      String namaUser = hasil['user']?['name'] ?? _nameController.text;
      String emailUser = hasil['user']?['email'] ?? _emailController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan verifikasi akun Anda.'), backgroundColor: Colors.green),
      );
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            username: namaUser, 
            email: emailUser,   
          ),
        ),
      );
      
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

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final hasil = await ApiService.loginWithGoogle(
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email,
        googleId: googleUser.id,
      );

      if (mounted) Navigator.pop(context); 

      if (hasil['success'] == true) {
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
              const SizedBox(height: 60),
              const Text('Create Account', style: AppTextStyle.heading),
              const SizedBox(height: 8),
              Text(
                'Start booking with creating account',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 40),
          
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Username', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _nameController, hintText: 'Create your user name'),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _emailController, hintText: 'Enter your email'),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Phone Number', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _phoneController, hintText: 'Enter your phone number'),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Password', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              CustomInputField(controller: _passwordController, hintText: 'Create your password', obscureText: true),
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
                  onPressed: _isLoading ? null : handleRegister,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.textWhite)
                    : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),

              _buildSocialButton(Icons.g_mobiledata_rounded, 'Sign up with Google', onTap: _handleGoogleSignIn),
              const SizedBox(height: 12),
              _buildSocialButton(Icons.facebook_rounded, 'Sign up with Facebook', onTap: () {
              }),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  GestureDetector(
                    onTap: () {
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
            Text(text, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}