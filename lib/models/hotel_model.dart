class HotelModel {
  final int id;
  final String name;
  final String location;
  final String? thumbnail;

  HotelModel({
    required this.id,
    required this.name,
    required this.location,
    this.thumbnail,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'thumbnail': thumbnail,
    };
  }
}
