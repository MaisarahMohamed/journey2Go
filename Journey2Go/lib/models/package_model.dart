class PackageModel {
  String? destination;
  String? description;
  String? image;

  PackageModel({
    required this.destination,
    required this.description,
    required this.image,
  });


  factory PackageModel.fromMap(Map<String, dynamic> map){
    return PackageModel(
        destination: map['dest']??'',
        description: map['desc']??'',
        image: map['img']??'',
    );
  }
}

