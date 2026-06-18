import 'package:flutter/material.dart';
import '../constants/themes.dart';
import '../widgets/custom_input.dart';
import '../api_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _handleResetPassword() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Field tidak boleh kosong, gaes!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    final hasil = await ApiService.resetPasswordForm(
      email: widget.email,
      newPassword: _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (hasil['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui! Silakan login kembali.'), backgroundColor: Colors.green),
      );
      
      // Tendang balik ke halaman Login awal biar dia login normal
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hasil['message'] ?? 'Gagal reset password'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Create New Password', style: AppTextStyle.heading),
              const SizedBox(height: 8),
              Text('Enter your new password to secure your account', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 32),
              CustomInputField(controller: _newPasswordController, hintText: 'New Password', obscureText: true),
              CustomInputField(controller: _confirmPasswordController, hintText: 'Confirm New Password', obscureText: true),
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
                  ),
                  onPressed: _isLoading ? null : _handleResetPassword,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.textWhite)
                    : const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}