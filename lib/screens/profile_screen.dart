import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/themes.dart';
import '../api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final Function(String)? onNameUpdated; 

  const ProfileScreen({super.key, required this.username, required this.email, this.onNameUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController(text: "************");
  final _phoneController = TextEditingController(text: "086767676767");
  
  bool _isProfileLoading = false;
  File? _imageFile;
  String? _serverPhotoUrl; 
  final ImagePicker _picker = ImagePicker();
  final String _defaultAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _fetchProfileFreshData(); 
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fetchProfileFreshData() async {
    setState(() => _isProfileLoading = true);

    final hasil = await ApiService.getBookings(widget.email);

    if (hasil['success'] == true &&
        hasil['bookings'] != null &&
        hasil['bookings'].isNotEmpty) {

      final firstBooking = hasil['bookings'][0];

      if (firstBooking['user'] != null) {
        final userUpdate = firstBooking['user'];

        setState(() {
          _phoneController.text =
              userUpdate['phone']?.toString() ?? '';

          if (userUpdate['profile_photo'] != null &&
              userUpdate['profile_photo'].toString().isNotEmpty) {

            _serverPhotoUrl =
                'http://10.0.2.2:8000/storage/${userUpdate['profile_photo']}';

            print("FOTO URL = $_serverPhotoUrl");
          }
        });
      }
    }

    setState(() => _isProfileLoading = false);
  }

  void _showUpdateConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Profile!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Are you sure you want to save your new profile changes and picture?', style: TextStyle(fontSize: 13, color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('NO', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _executeProfileUpdate();
            },
            child: const Text('YES', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

void _executeProfileUpdate() async {
    setState(() => _isProfileLoading = true);
    
    String namaBaruDiInput = _usernameController.text;
    String nomorBaruDiInput = _phoneController.text;
    String emailUser = _emailController.text;

    final hasil = await ApiService.updateProfile(
      name: namaBaruDiInput, 
      phone: nomorBaruDiInput,
      email: emailUser, 
      photoPath: _imageFile?.path, 
    );
    
    setState(() => _isProfileLoading = false);

    if (hasil['success'] == true || hasil['status'] == 'success') {
  setState(() {
    _usernameController.text = namaBaruDiInput;
    _phoneController.text = nomorBaruDiInput;

    if (hasil['user'] != null &&
        hasil['user']['profile_photo'] != null) {

      _serverPhotoUrl =
          'http://10.0.2.2:8000/storage/${hasil['user']['profile_photo']}';

      _imageFile = null;
    }
  });

      if (widget.onNameUpdated != null) {
        widget.onNameUpdated!(namaBaruDiInput);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully in Database!'), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Laravel Update Error'),
          content: Text(hasil['message'] ?? 'Gagal menyimpan ke database.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _processChangePassword(String oldPass, String newPass) async {
    if (oldPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak boleh kosong!'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    final hasil = await ApiService.changePassword(oldPass, newPass, _emailController.text);
    Navigator.pop(context); 
    if (hasil['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru berhasil disimpan di DB!'), backgroundColor: Colors.green),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Gagal Ganti Password'),
          content: Text(hasil['message'] ?? 'Password lama salah atau tidak sesuai kriteria.'),
        ),
      );
    }
  }

  void _showChangePasswordBottomSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24, left: 24, right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFD6DBDC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('Create new password', style: TextStyle(color: AppColors.primaryBg, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Current Password', style: TextStyle(color: AppColors.primaryBg, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildBottomSheetField(
                    controller: currentPasswordController,
                    hint: 'Enter current password',
                    obscureText: obscureCurrent,
                    onToggleObscure: () => setModalState(() => obscureCurrent = !obscureCurrent),
                  ),
                  const SizedBox(height: 16),
                  const Text('Password', style: TextStyle(color: AppColors.primaryBg, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildBottomSheetField(
                    controller: newPasswordController,
                    hint: 'Enter new password',
                    obscureText: obscureNew,
                    onToggleObscure: () => setModalState(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E8294),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context); 
                        _showConfirmationDialog(currentPasswordController.text, newPasswordController.text);
                      },
                      child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(String oldPass, String newPass) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Are you sure you want to change ur password?', style: TextStyle(fontSize: 13, color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              _processChangePassword(oldPass, newPass); 
            },
            child: const Text('YES', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  void _showEditPictureDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Picture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDialogOption(icon: Icons.image_outlined, text: 'Choose from library', onTap: () { Navigator.pop(context); _pickImageFromGallery(); }),
              const SizedBox(height: 8),
              _buildDialogOption(icon: Icons.camera_alt_outlined, text: 'Take Photo', onTap: () { Navigator.pop(context); _pickImageFromCamera(); }),
              const SizedBox(height: 8),
              _buildDialogOption(
                icon: Icons.delete_outline_rounded, text: 'Remove Current picture', iconColor: Colors.redAccent, textColor: Colors.redAccent,
                onTap: () { setState(() { _imageFile = null; _serverPhotoUrl = null; }); Navigator.pop(context); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogOption({required IconData icon, required String text, required VoidCallback onTap, Color iconColor = Colors.black54, Color textColor = Colors.black87}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFE2E8F0).withAlpha(150), borderRadius: BorderRadius.circular(12)),
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
        child: _isProfileLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Text('Edit profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 120, height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 2),
                              ),
                              child: ClipOval(
                                child: _imageFile != null
                                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                                    : (_serverPhotoUrl != null
                                        ? Image.network(
                                            _serverPhotoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.network(_defaultAvatar, fit: BoxFit.cover);
                                            },
                                          )
                                        : Image.network(_defaultAvatar, fit: BoxFit.cover)),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, 10),
                              child: CircleAvatar(
                                radius: 18, backgroundColor: Colors.black45,
                                child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18), onPressed: _showEditPictureDialog),
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
                              _buildProfileInputField(label: 'Email', controller: _emailController, icon: Icons.email_outlined, isEmail: true),
                              
                              GestureDetector(
                                onTap: _showChangePasswordBottomSheet,
                                child: AbsorbPointer(
                                  child: _buildProfileInputField(label: 'Password', controller: _passwordController, icon: Icons.lock_outline_rounded),
                                ),
                              ),
                              
                              _buildProfileInputField(label: 'Mobile number', controller: _phoneController, icon: Icons.phone_android_rounded, isPhone: true),
                              const SizedBox(height: 32),
                              
                              SizedBox(
                                width: double.infinity, height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A).withAlpha(180), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                  onPressed: _isProfileLoading ? null : _showUpdateConfirmationDialog, 
                                  child: const Text('Update', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 160, height: 44,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.redAccent, shape: const StadiumBorder(), elevation: 0),
                                  icon: const Icon(Icons.logout_rounded, size: 18),
                                  label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
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

  Widget _buildProfileInputField({required String label, required TextEditingController controller, required IconData icon, bool isPhone = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: isEmail, 
            style: TextStyle(color: isEmail ? Colors.white60 : Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
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

  Widget _buildBottomSheetField({required TextEditingController controller, required String hint, required bool obscureText, required VoidCallback onToggleObscure}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFBAC2C6), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller, obscureText: obscureText,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Colors.black38, fontSize: 14), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black54, size: 20), onPressed: onToggleObscure),
        ),
      ),
    );
  }
}