class BookingHistoryModel {
  final String bookingCode;
  final String hotel;
  final String room;
  final String checkIn;
  final String checkOut;
  final double totalPrice;
  final String status;

  BookingHistoryModel({
    required this.bookingCode,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingHistoryModel(
      bookingCode: json['booking_code'] as String,
      hotel: json['hotel'] as String,
      room: json['room'] as String,
      checkIn: json['check_in'] as String,
      checkOut: json['check_out'] as String,
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] as String,
    );
  }
}
