import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:journey2go/AddTrip.dart';
import 'package:journey2go/AddTripFav.dart';
import 'package:journey2go/models/StartAddressModel.dart';

import 'main.dart';

class BottomDrawerFav extends StatefulWidget {
  BottomDrawerFav({Key? key, required this.checkedList}) : super(key: key);
  final List checkedList;

  @override
  State<BottomDrawerFav> createState() => _BottomDrawerFavState();
}

class _BottomDrawerFavState extends State<BottomDrawerFav> {

  TextEditingController _address = TextEditingController();
  final _form = GlobalKey<FormState>();
  String address = '';
  String googleApikey = "AIzaSyAQiFVO-8_aDV8RikLqmvc9QaGA2dDD4_Y";
  double? lat;
  double? lang;
  bool loading = false;
  late startPlan startLocation;

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

  Future<void> GetAddressFromLatLong(Position position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    setState(() {
      _address.text = '${place.street} ${place.thoroughfare}, ${place.subLocality}, ${place.postalCode} ${place.locality} , ${place.country}';
      lat = position.latitude;
      lang = position.longitude;
    });
    setState((){loading = false;});
  }

  void validateAndSave(BuildContext context){
    final form = _form.currentState;
    if(form!.validate())
    {
      setState(() {
        startLocation = startPlan(address: _address.text,latitude: lat, longitude: lang);
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context){
            return AddTripFav(startLocation: startLocation, checkedList: widget.checkedList,);
          })
      );
    }
    else
    {
      Fluttertoast.showToast(msg: 'Please Fill In The Form');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          children: [
            Form(
              key: _form,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Start Planning',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Where does your journey start?',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    focusNode: FocusNode(),
                                    enableInteractiveSelection: false,
                                    controller: _address,
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: _address.clear,
                                          icon: Icon(Icons.clear),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey
                                            ),
                                            borderRadius: BorderRadius.circular(12)
                                        ),
                                        labelText: "Starting Location",
                                        hintText: "Your Location"
                                    ),
                                    validator: (value) => value!.isEmpty ? 'Address Cannot Be Blank':null,
                                    onTap: () async {
                                      var place = await PlacesAutocomplete.show(
                                          context: context,
                                          apiKey: googleApikey,
                                          mode: Mode.overlay,
                                          types: [],
                                          strictbounds: false,
                                          components: [Component(Component.country, 'my')],
                                          //google_map_webservice package
                                          onError: (err){
                                            print(err);
                                          }
                                      );
                                      if(place != null){
                                        setState(() {
                                          _address.text = place.description.toString();
                                          address = place.description.toString();
                                        });

                                        //form google_maps_webservice package
                                        final plist = GoogleMapsPlaces(apiKey:googleApikey,
                                          apiHeaders: await GoogleApiHeaders().getHeaders(),
                                          //from google_api_headers package
                                        );
                                        String placeid = place.placeId ?? "0";
                                        final detail = await plist.getDetailsByPlaceId(placeid);
                                        final geometry = detail.result.geometry!;
                                        setState(() {
                                          lat = geometry.location.lat;
                                          lang = geometry.location.lng;
                                        });
                                        FocusScope.of(context).requestFocus(FocusNode());
                                      };
                                    },
                                  ),
                                ),
                              ),
                              loading?
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  child: CircularProgressIndicator(),
                                  height: 20,
                                  width: 20,
                                ),
                              ):
                              IconButton(
                                  onPressed: ()async{
                                    Position position = await _getGeoLocationPosition();
                                    GetAddressFromLatLong(position);
                                  },
                                  icon: Icon(Icons.gps_fixed,color: Colors.blue,)
                              )
                            ],
                          ),
                          SizedBox(height:20),
                          //Continue Button

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: GestureDetector(
                              onTap: (){validateAndSave(context);},
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center
                                  (child: Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )
                                )
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

