import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:staypoint/constants/app_constants.dart';
import 'package:staypoint/models/hotel_model.dart';
import 'package:staypoint/models/hotel_detail_model.dart';
import 'package:staypoint/models/booking_model.dart';
import 'package:staypoint/models/booking_history_model.dart';

class ApiService {
  static const String _baseUrl = baseUrl;
  final String? token;

  ApiService({this.token});

  Future<List<HotelModel>> fetchHotels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${AppEndpoints.hotels}'),
        headers: _buildHeaders(),
      ).timeout(
        const Duration(seconds: connectionTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((hotel) => HotelModel.fromJson(hotel)).toList();
      } else {
        throw Exception('Failed to load hotels: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Error fetching hotels: $e');
    }
  }

  Future<HotelDetailModel> fetchHotelDetail(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${AppEndpoints.hotelDetail}/$hotelId'),
        headers: _buildHeaders(),
      ).timeout(
        const Duration(seconds: connectionTimeout),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return HotelDetailModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Hotel not found');
      } else {
        throw Exception('Failed to load hotel detail: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Error fetching hotel detail: $e');
    }
  }

  Future<BookingResponseModel> createBooking(
    BookingRequestModel bookingRequest,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${AppEndpoints.bookings}'),
        headers: _buildHeaders(isJson: true),
        body: jsonEncode(bookingRequest.toJson()),
      ).timeout(
        const Duration(seconds: connectionTimeout),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return BookingResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 422) {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Validation failed');
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  Future<List<BookingHistoryModel>> fetchBookingHistory() async {
    try {
      if (token == null) {
        throw Exception('Token not available');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl${AppEndpoints.bookingHistory}'),
        headers: _buildHeaders(includeToken: true),
      ).timeout(
        const Duration(seconds: connectionTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((booking) => BookingHistoryModel.fromJson(booking))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load booking history: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Error fetching booking history: $e');
    }
  }

  Map<String, String> _buildHeaders({
    bool isJson = false,
    bool includeToken = false,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    if (includeToken && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
