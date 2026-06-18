import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Respon server tidak valid: ${response.body}',
      };
    }
  }

  // FUNGSI LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );
      return _decode(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e',
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
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );
      return _decode(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e',
      };
    }
  }

  // FUNGSI REQUEST OTP / FORGOT PASSWORD
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email}),
      );
      return _decode(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e',
      };
    }
  }

  // Fungsi untuk Update Profile (Username & Phone)
  static Future<Map<String, dynamic>> updateProfile(
    String username,
    String phone,
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/update'),
        headers: _jsonHeaders,
        body: jsonEncode({'name': username, 'phone': phone, 'email': email}),
      );

      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // Fungsi untuk Change Password dari Bottom Sheet
  static Future<Map<String, dynamic>> changePassword(
    String oldPass,
    String newPass,
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/change-password'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'current_password': oldPass,
          'new_password': newPass,
          'email': email,
        }),
      );

      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Eror terhubung ke server: $e'};
    }
  }

  // ==================== FUNGSI LOGIN GOOGLE ====================
  static Future<Map<String, dynamic>> loginWithGoogle({
    required String name,
    required String email,
    required String googleId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login-google'),
        headers: _jsonHeaders,
        body: jsonEncode({'name': name, 'email': email, 'google_id': googleId}),
      );
      return _decode(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke backend saat login Google: $e',
      };
    }
  }

  // Fungsi Eksekusi Simpan Password Baru Setelah Lolos verif
  static Future<Map<String, dynamic>> resetPasswordForm({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password-save'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Eror koneksi backend: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHotels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hotels'),
        headers: {'Accept': 'application/json'},
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil data hotel: $e'};
    }
  }

  static Future<Map<String, dynamic>> getRoom(int roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rooms/$roomId'),
        headers: {'Accept': 'application/json'},
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil detail kamar: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAddons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addons'),
        headers: {'Accept': 'application/json'},
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil addon: $e'};
    }
  }

  static Future<Map<String, dynamic>> createBooking({
    required String email,
    required int roomId,
    required String checkIn,
    required String checkOut,
    required List<Map<String, dynamic>> addons,
    String paymentStatus = 'pending',
    String status = 'pending',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'email': email,
          'room_id': roomId,
          'check_in': checkIn,
          'check_out': checkOut,
          'payment_status': paymentStatus,
          'status': status,
          'addons': addons,
        }),
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal membuat booking: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBookings(
    String email, {
    String? status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings').replace(
        queryParameters: {'email': email, if (status != null) 'status': status},
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      return _decode(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil history booking: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateBooking({
    required String email,
    required int bookingId,
    String? checkIn,
    String? checkOut,
    String? paymentStatus,
    String? status,
    List<Map<String, dynamic>>? addons,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'email': email,
          if (checkIn != null) 'check_in': checkIn,
          if (checkOut != null) 'check_out': checkOut,
          if (paymentStatus != null) 'payment_status': paymentStatus,
          if (status != null) 'status': status,
          if (addons != null) 'addons': addons,
        }),
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update booking: $e'};
    }
  }

  static Future<Map<String, dynamic>> cancelBooking({
    required String email,
    required int bookingId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email}),
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal membatalkan booking: $e'};
    }
  }

  static Future<Map<String, dynamic>> createReview({
    required String email,
    required int bookingId,
    required int rating,
    required String comment,
    String? photoPath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reviews'),
      );
      request.fields.addAll({
        'email': email,
        'booking_id': bookingId.toString(),
        'rating': rating.toString(),
        'comment': comment,
      });
      if (photoPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photoPath),
        );
      }

      final response = await http.Response.fromStream(await request.send());
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengirim review: $e'};
    }
  }

  static Future<Map<String, dynamic>> getReviews({
    int? roomId,
    String? email,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/reviews').replace(
        queryParameters: {
          if (roomId != null) 'room_id': roomId.toString(),
          if (email != null) 'email': email,
        },
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil review: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateReview({
    required String email,
    required int reviewId,
    required int rating,
    required String comment,
    String? photoPath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reviews/$reviewId'),
      );
      request.fields.addAll({
        'email': email,
        'rating': rating.toString(),
        'comment': comment,
      });
      if (photoPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photoPath),
        );
      }

      final response = await http.Response.fromStream(await request.send());
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memperbarui review: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteReview({
    required String email,
    required int reviewId,
  }) async {
    try {
      final request = http.Request(
        'DELETE',
        Uri.parse('$baseUrl/reviews/$reviewId'),
      );
      request.headers.addAll(_jsonHeaders);
      request.body = jsonEncode({'email': email});
      final response = await http.Response.fromStream(await request.send());
      return _decode(response);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus review: $e'};
    }
  }
}
