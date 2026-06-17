import 'dart:io'; // Wajib buat membaca file gambar dari HP
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import library barumu gaes!
import '../constants/themes.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController(text: "*************");
  final _phoneController = TextEditingController(text: "6767676767");

  // State untuk menampung file gambar asli dari HP kamu
  File? _imageFile; 
  final ImagePicker _picker = ImagePicker();

  // URL fallback kalau belum ada foto yang dipilih dari galeri
  final String _defaultAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: "${widget.username.toLowerCase().replaceAll(' ', '')}@gmail.com");
  }

  // ==================== FUNGSI SAKRAL: BUKA GALERI ASLI HP ====================
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // Membuka galeri bawaan Android/iOS
      imageQuality: 80, // Biar gak kegedean sizenya pas di-upload ke Laravel nanti
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set file gambar asli HP ke state
      });
    }
  }

  // ==================== FUNGSI SAKRAL: BUKA KAMERA ASLI HP ====================
  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera, // Membuka kamera bawaan HP
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // ==================== POPUP EDIT PICTURE DIALOG (TAMPILAN FIGMA KIRI) ====================
  void _showEditPictureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Picture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),
                
                // Opsi 1: Choose from library -> SEKARANG BUKA GALERI HP BENERAN!
                _buildDialogOption(
                  icon: Icons.image_outlined,
                  text: 'Choose from library',
                  onTap: () {
                    Navigator.pop(context); // Tutup dialog
                    _pickImageFromGallery(); // Panggil fungsi galeri HP asli!
                  },
                ),
                const SizedBox(height: 8),

                // Opsi 2: Take Photo -> SEKARANG BUKA KAMERA HP BENERAN!
                _buildDialogOption(
                  icon: Icons.camera_alt_outlined,
                  text: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera(); // Panggil fungsi kamera HP asli!
                  },
                ),
                const SizedBox(height: 8),

                // Opsi 3: Remove Current picture (Text Merah)
                _buildDialogOption(
                  icon: Icons.delete_outline_rounded,
                  text: 'Remove Current picture',
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  onTap: () {
                    setState(() {
                      _imageFile = null; // Hapus gambar lokal
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogOption({required IconData icon, required String text, required VoidCallback onTap, Color iconColor = Colors.black54, Color textColor = Colors.black87}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withAlpha(150),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () {},
                    ),
                    const Text('Edit profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    // AVATAR UTAMA
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 2),
                            // LOGIKANYA DI SINI: Kalau ada file dari HP tampilkan FileImage, kalau kosong pakai NetworkImage default
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(_defaultAvatar),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, 10),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black45,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                              onPressed: _showEditPictureDialog,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildProfileInputField(label: 'User Name', controller: _usernameController, icon: Icons.person_outline_rounded),
                          _buildProfileInputField(label: 'Email', controller: _emailController, icon: Icons.email_outlined),
                          _buildProfileInputField(label: 'Password', controller: _passwordController, icon: Icons.lock_outline_rounded, isPassword: true),
                          _buildProfileInputField(label: 'Mobile number', controller: _phoneController, icon: Icons.phone_android_rounded, isPhone: true),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A).withAlpha(180),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                                );
                              },
                              child: const Text('Update', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 160,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.redAccent,
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInputField({required String label, required TextEditingController controller, required IconData icon, bool isPhone = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: isPassword,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: isPhone 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 12),
                      Icon(Icons.phone_android_rounded, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text('+62  |  ', style: TextStyle(color: Colors.white70, fontSize: 15)),
                    ],
                  )
                : Icon(icon, color: Colors.white70, size: 20),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}