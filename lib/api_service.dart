import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // FUNGSI LOGIN 
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e'
      };
    }
  }

  // FUNGSI REGISTER 
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e'
      };
    }
  }


  // FUNGSI REQUEST OTP / FORGOT PASSWORD
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e'
      };
    }
  }
  // Fungsi untuk Update Profile (Username & Phone)
  static Future<Map<String, dynamic>> updateProfile(String username, String phone, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': username,
          'phone': phone,
          'email': email,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // Fungsi untuk Change Password dari Bottom Sheet
  static Future<Map<String, dynamic>> changePassword(String oldPass, String newPass, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'current_password': oldPass, 
          'new_password': newPass,      
          'email': email, 
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Eror terhubung ke server: $e'};
    }
  }

}