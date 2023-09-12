import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:journey2go/NavBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey2go/main.dart';

import 'models/LocationsModel.dart';

class PlaceInfo extends StatefulWidget {
  final PlaceModel place;
  PlaceInfo({Key? key, required this.place,}):super(key:key);

  @override
  State<PlaceInfo> createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {

  //late double _latitude = 2.8025;
  //late double _longitude = 101.7989;

  late double? _latitude = widget.place.latitude;
  late double? _longitude = widget.place.longitude;

  GoogleMapController? mapController;

  User? user;

  //initialize
  Future getUserData() async {
    User userData =  await FirebaseAuth.instance.currentUser!;
    setState(() {
      user = userData;
    });
  }

  @override
  void initState(){
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset('assets/logo.png', scale: 3.2),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
      ),
      drawer: NavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Image.network(
                "${widget.place.image}",
                fit: BoxFit.cover,
              ),
              height: 200,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  //Title
                  Container(
                    child: Text("${widget.place.destination}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  //Description
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("${widget.place.description}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  //Location
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    height: MediaQuery.of(context).size.height / 2.5,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      onMapCreated: (controller) { //method called when map is created
                        setState(() {
                          mapController = controller;
                        });
                      },
                      scrollGesturesEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_latitude!, _longitude!),
                        zoom: 15
                      ),

                      markers: {
                        Marker(
                          markerId: MarkerId("${widget.place.destination}"),
                          position: LatLng(_latitude!, _longitude!),
                          infoWindow: InfoWindow(title: "${widget.place.destination}")
                        ),
                      },
                    ),
                  ),
                  //Add to favourites button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: GestureDetector(
                      onTap: (){
                          Map<String, dynamic>favData = {
                            'uid': user?.uid,
                            'destination': widget.place.destination,
                            'description': widget.place.description,
                            'image': widget.place.image,
                            'latitude': widget.place.latitude,
                            'longitude': widget.place.longitude,
                          };
                          FirebaseFirestore.instance.collection('favourite').add(favData)
                              .catchError((error) =>
                              Fluttertoast.showToast(
                                msg:'Trip Failed To Save. $error',
                              ),
                          );
                          Fluttertoast.showToast(
                            msg:'Trip Successfully Saved',
                          );
                          Navigator.of(context).pop(
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add To Favourites",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )
                          ),
                          Icon(Icons.favorite, color: Colors.white,)
                        ],
                          ),
                      )
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}