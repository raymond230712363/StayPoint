class RoomModel {
  final int id;
  final int hotelId;
  final String roomName;
  final String description;
  final int capacity;
  final double pricePerNight;
  final int stock;
  final List<RoomImageModel>? images;
  final List<FacilityModel>? facilities;

  RoomModel({
    required this.id,
    required this.hotelId,
    required this.roomName,
    required this.description,
    required this.capacity,
    required this.pricePerNight,
    required this.stock,
    this.images,
    this.facilities,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      hotelId: json['hotel_id'] as int,
      roomName: json['room_name'] as String,
      description: json['description'] as String,
      capacity: json['capacity'] as int,
      pricePerNight: double.parse(json['price_per_night'].toString()),
      stock: json['stock'] as int,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => RoomImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'room_name': roomName,
      'description': description,
      'capacity': capacity,
      'price_per_night': pricePerNight,
      'stock': stock,
      'images': images?.map((e) => e.toJson()).toList(),
      'facilities': facilities?.map((e) => e.toJson()).toList(),
    };
  }
}

class RoomImageModel {
  final int id;
  final int roomId;
  final String imageUrl;

  RoomImageModel({
    required this.id,
    required this.roomId,
    required this.imageUrl,
  });

  factory RoomImageModel.fromJson(Map<String, dynamic> json) {
    return RoomImageModel(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'image_url': imageUrl,
    };
  }
}

class FacilityModel {
  final int id;
  final String name;

  FacilityModel({
    required this.id,
    required this.name,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
