class startPlan {
  String? address;
  double? latitude;
  double? longitude;

  startPlan({
    this.address,
    this.latitude,
    this.longitude,
  });


  factory startPlan.fromMap(Map<String, dynamic> map){
    return startPlan(
      address: map['add']??'',
      latitude: map['lat']??'',
      longitude: map['lon']??'',
    );
  }
}