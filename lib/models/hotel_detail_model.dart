import 'package:staypoint/models/room_model.dart';

class HotelDetailModel {
  final HotelDataModel hotel;
  final List<RoomModel> rooms;
  final List<FacilityModel> facilities;

  HotelDetailModel({
    required this.hotel,
    required this.rooms,
    required this.facilities,
  });

  factory HotelDetailModel.fromJson(Map<String, dynamic> json) {
    return HotelDetailModel(
      hotel: HotelDataModel.fromJson(json['hotel'] as Map<String, dynamic>),
      rooms: (json['rooms'] as List<dynamic>)
          .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as List<dynamic>)
          .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotelDataModel {
  final int id;
  final String name;
  final String location;
  final String description;
  final String? thumbnail;

  HotelDataModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    this.thumbnail,
  });

  factory HotelDataModel.fromJson(Map<String, dynamic> json) {
    return HotelDataModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String?,
    );
  }
}
