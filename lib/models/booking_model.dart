class BookingRequestModel {
  final int roomId;
  final String checkIn;
  final String checkOut;
  final List<AddonRequestModel>? addons;

  BookingRequestModel({
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    this.addons,
  });

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'check_in': checkIn,
      'check_out': checkOut,
      if (addons != null) 'addons': addons!.map((e) => e.toJson()).toList(),
    };
  }
}

class AddonRequestModel {
  final int addonId;
  final int quantity;

  AddonRequestModel({
    required this.addonId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'addon_id': addonId,
      'quantity': quantity,
    };
  }
}

class BookingResponseModel {
  final String message;
  final String bookingCode;

  BookingResponseModel({
    required this.message,
    required this.bookingCode,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      message: json['message'] as String,
      bookingCode: json['booking_code'] as String,
    );
  }
}
