import 'package:flutter/material.dart';
import '../constants/themes.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // 4 Controller untuk masing-masing kotak angka OTP
  final _code1Controller = TextEditingController();
  final _code2Controller = TextEditingController();
  final _code3Controller = TextEditingController();
  final _code4Controller = TextEditingController();
  bool _isLoading = false;

  void handleVerify() async {
    String otpCode = _code1Controller.text + _code2Controller.text + _code3Controller.text + _code4Controller.text;

    if (otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP harus 4 digit lengkap, gaes!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Tempat tembak API Verifikasi OTP Laravel kamu
    await Future.delayed(const Duration(seconds: 2)); // Simulasi loading

    setState(() => _isLoading = false);

    // Jika sukses verifikasi, bisa diarahkan ke halaman Reset Password Baru atau balik ke Login
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Sukses'),
        content: const Text('Akun atau email kamu berhasil diverifikasi!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Balik dari verifikasi
              Navigator.pop(context); // Balik ke halaman Login
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

              // Judul Halaman
              const Text('Verification', style: AppTextStyle.heading),
              const SizedBox(height: 8),
              Text(
                'We have sent the verification code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 50),

              // Barisan 4 Kotak Input OTP ala Figma
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOtpBox(_code1Controller, first: true, last: false),
                  _buildOtpBox(_code2Controller, first: false, last: false),
                  _buildOtpBox(_code3Controller, first: false, last: false),
                  _buildOtpBox(_code4Controller, first: false, last: true),
                ],
              ),
              const SizedBox(height: 40),

              // Tombol Verify Kapsul Besar
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
                  onPressed: _isLoading ? null : handleVerify,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.textWhite)
                      : const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk membuat kotak input OTP otomatis pindah fokus saat diketik
  Widget _buildOtpBox(TextEditingController controller, {required bool first, required bool last}) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus(); // Pindah otomatis ke kotak kanan
          }
          if (value.isEmpty && first == false) {
            FocusScope.of(context).previousFocus(); // Mundur kalau dihapus
          }
        },
        showCursor: false,
        readOnly: false,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "", // Sembunyikan counter text panjang di bawah
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}