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
  final _phoneController = TextEditingController(); 
  bool _isLoading = false;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose(); 
    super.dispose();
  }

  void handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    // === VALIDASI FRONT-END (AGAR TIDAK TEMBUS ASAL KETIK) ===
    if (email.isEmpty || password.isEmpty || phone.isEmpty) {
      _showWarningDialog('Login Gagal', 'Semua field wajib diisi!');
      return;
    }

    // Standar nomor telepon Indonesia umumnya minimal 10-13 digit
    if (phone.length < 10) {
      _showWarningDialog('Input Tidak Valid', 'Nomor telepon minimal harus 10 digit.');
      return;
    }

    setState(() => _isLoading = true);
    final hasil = await ApiService.login(email, password, phone);
    setState(() => _isLoading = false);

    if (hasil['success'] == true) {
      String namaUser = hasil['user']['name']; 
      String emailUser = hasil['user']['email'] ?? 'user@gmail.com'; 
      String phoneUser = hasil['user']['phone'] ?? '6767676767'; 
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang, $namaUser!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: {
          'username': namaUser,
          'email': emailUser,
          'phone' : phoneUser,
        }, 
      );
    } else {
      _showWarningDialog('Login Gagal', hasil['message'] ?? 'Email, password, atau nomor telepon salah.');
    }
  }

  // Helper widget untuk menampilkan dialog error agar kode lebih bersih
  void _showWarningDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

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
            'phone': hasil['user']['phone'] ?? '',
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
                'Enter your details to login',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 48),
              
              // === INPUT FIELDS ===
              CustomInputField(controller: _emailController, hintText: 'Email'),
              const SizedBox(height: 12), 
              
              CustomInputField(
                controller: _phoneController, 
                hintText: 'Phone Number',
                // Catatan: Jika CustomInputField milikmu membungkus TextField asli,
                // pastikan komponen tersebut dipasangi tipe keyboard nomor/telepon.
              ),
              const SizedBox(height: 12),
              
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
              
              _buildSocialButton(Icons.g_mobiledata_rounded, 'Sign up with Google', onTap: _handleGoogleSignIn),
              const SizedBox(height: 12),
              _buildSocialButton(Icons.facebook_rounded, 'Sign up with Facebook', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

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