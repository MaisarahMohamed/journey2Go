class TripModel {
  String? destination;
  String? description;
  String? image;
  String? startDest;
  double? latitude;
  double? longitude;
  double? distance;


  TripModel({
    required this.destination,
    required this.description,
    required this.image,
    required this.startDest,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });


  factory TripModel.fromMap(Map<String, dynamic> map){
    return TripModel(
      destination: map['dest']??'',
      description: map['desc']??'',
      image: map['img']??'',
      startDest: map['address']??'',
      latitude: map['lat']??'',
      longitude: map['lon']??'',
      distance: map['dist']??'',
    );
  }
}