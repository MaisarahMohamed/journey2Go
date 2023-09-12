import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:journey2go/services/http_service.dart';
import 'package:journey2go/services/scraper_service.dart';
import 'AddTrip.dart';
import 'PlaceInfo.dart';
import 'main.dart';
import 'models/LocationsModel.dart';
import 'models/StartAddressModel.dart';
import 'models/TripModel.dart';
import 'models/package_model.dart';

class NearMe extends StatefulWidget {
  const NearMe({Key? key}) : super(key: key);

  @override
  State<NearMe> createState() => _NearMeState();
}

class _NearMeState extends State<NearMe> with AutomaticKeepAliveClientMixin<NearMe>{
  startPlan startLocation = startPlan(address: 'Not Specified', latitude: null, longitude: null);
  TextEditingController _address = TextEditingController();
  bool loading = false;
  bool loadingPic = false;
  bool loadingPlace = false;
  List checkedList = [];
  List <bool> isChecked = [];
  List <PackageModel> destination = [];
  List <PlaceModel> places3000 = [];
  List <PlaceModel> places = [];
  List <Location> coordinates = [];
  List <double> dist = [];
  late double lat;
  late double long;
  User? user;



  @override
  void initState(){
    // TODO: implement initState
    scrapeLocation();
    super.initState();
  }

  Future<Position> _getGeoLocationPosition() async {
    setState((){loading = true;});
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong()async {

    Position position = await _getGeoLocationPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      _address.text = '${place.street} ${place.thoroughfare}, ${place.subLocality}, ${place.postalCode} ${place.locality} , ${place.country}';
      startLocation = startPlan(address: _address.text, latitude: position.latitude,longitude: position.longitude );
      setState(() {
        places3000 = getPlacesWithinDistance(3000, places, startLocation);
      });
      loading = false;
      loadingPlace = false;
    });
  }

  Future<void> scrapeLocation()async{
    destination.clear();
    places.clear();
    setState(() {});
    final html = await HttpService.get();
    if(html != null) destination =  ScraperService.run(html);
    getCoordinates();
  }

  Future<void> getCoordinates()async{
    for(int i=0 ; i < destination.length ; i++){
      coordinates = await locationFromAddress('${destination.elementAt(i).destination}');
      Location coord = coordinates[0];
      PlaceModel temp = PlaceModel(
          destination: destination.elementAt(i).destination,
          description: destination.elementAt(i).description,
          image: destination.elementAt(i).image,
          latitude: coord.latitude,
          longitude: coord.longitude
      );
      setState(() {
        places.add(temp);
      });

    }
    setState((){
      places3000 = getPlacesWithinDistance(3000, places, startLocation);
    });
  }

  List<PlaceModel> getPlacesWithinDistance(double d, List<PlaceModel> p, startPlan l){
    setState(() {
      loadingPlace = true;
    });
    List<PlaceModel> tempList = [];
    for(int i=0; i<p.length; i++){
      double distance = Geolocator.distanceBetween(l.latitude!, l.longitude!,
          p.elementAt(i).latitude!, p.elementAt(i).longitude!);

      if(distance <= d){
        tempList.add(p.elementAt(i));
      }
    }
    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [SingleChildScrollView(
        child: Column(
            children:<Widget>[
              //Greetings
              Container(
                padding: EdgeInsets.only(top: 30),
                child:Center(
                  child: Text(
                    'Places Near Me',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              //Current Location
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color:Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: loading?
                        Center(
                          child: SizedBox(
                            height: 20,
                              width: 20,
                              child: CircularProgressIndicator()),
                        ):
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            enabled: false,
                            controller: _address,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Your Current Location"
                            ),
                          ),
                        ),

                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.only(right: 20),
                      onPressed: ()async{
                        GetAddressFromLatLong();
                      },
                      icon: Icon(Icons.gps_fixed,color: Colors.blue,)
                  )
                ],
              ),

              //List of destinations
              startLocation.address == 'Not Specified'?
              Container(
                padding: EdgeInsets.only(top: 30),
                child:Center(
                  child: Text(
                    'Click on the icon',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              )
              :Padding(
                padding: const EdgeInsets.all(10.0),
                child: loadingPlace ?
                CircularProgressIndicator():
                places3000.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 210,
                    ),
                    itemCount:places3000.length,
                    itemBuilder:(ctx,index){
                      isChecked.add(false);
                      return GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => PlaceInfo(place: places3000[index]))
                            );
                          },
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.amber[200],
                              ),
                              child: Column(
                                children: <Widget>[

                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: Stack(
                                        children: [
                                          Image.network("${places3000.elementAt(index).image}",
                                            height: 170,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            frameBuilder: (_, image, loadingBuilder, __) {
                                              if (loadingBuilder == null) {
                                                return const SizedBox(
                                                  height: 170,
                                                  child: Center(child: CircularProgressIndicator()),
                                                );
                                              }
                                              return image;
                                            },
                                            loadingBuilder: (BuildContext context, Widget image, ImageChunkEvent? loadingProgress) {
                                              if (loadingProgress == null) return image;
                                              return SizedBox(
                                                height: 170,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10.0)),
                                                  color: Colors.black54,
                                                ),
                                                child: Checkbox(
                                                  checkColor: Colors.black,
                                                  value: isChecked.elementAt(index),
                                                  fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.white.withOpacity(.32);
                                                    }
                                                    return Colors.white;
                                                  }),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      isChecked[index] = value!;
                                                      if (value!){
                                                        checkedList.add(places3000.elementAt(index));
                                                      }else{
                                                        checkedList.remove(places3000.elementAt(index));
                                                      }
                                                    });
                                                  },
                                                ),

                                              )
                                          ),
                                        ]
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 6),
                                        child: Column(
                                          children: [
                                            Text("${places3000.elementAt(index).destination}",
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          )
                      );
                    },
                  ),
                ):
                Container(
                  padding: EdgeInsets.only(top: 30),
                  child:Center(
                    child: Text(
                      'No Interesting Places Nearby',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: (){
                  checkedList.isNotEmpty?
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddTrip(startLocation: startLocation, checkedList: checkedList,))
                  ):_showMyDialog();
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 5.0,
                        ),
                      ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add, color: Colors.white,),
                  ),
                ),
              )
          ),
        )
      ]
    );
  }
  @override
  bool get wantKeepAlive => true;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,// user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert!'),
          content: Text('Please tick at least one of the places from the list'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Text('OK',style: TextStyle(color: Colors.white),),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
              ),
            )
          ],
            actionsAlignment: MainAxisAlignment.center
        );
      },
    );
  }
}
