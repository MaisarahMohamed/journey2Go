class PlaceModel {
  String? destination;
  String? description;
  String? image;
  double? latitude;
  double? longitude;

  PlaceModel({
    required this.destination,
    required this.description,
    required this.image,
    required this.latitude,
    required this.longitude
  });


  factory PlaceModel.fromMap(Map<String, dynamic> map){
    return PlaceModel(
      destination: map['dest']??'',
      description: map['desc']??'',
      image: map['img']??'',
      latitude: map['lat']??'',
      longitude: map['lon']??'',
    );
  }
}

