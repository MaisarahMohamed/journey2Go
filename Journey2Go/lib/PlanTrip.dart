/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:journey2go/main.dart';
import 'models/StartAddressModel.dart';

class PlanTripPage extends StatefulWidget {
  const PlanTripPage({Key? key}) : super(key: key);

  @override
  State<PlanTripPage> createState() => _PlanTripPageState();
}

class _PlanTripPageState extends State<PlanTripPage> {

  TextEditingController _sDate = TextEditingController();
  TextEditingController _time = TextEditingController();
  TextEditingController _address = TextEditingController();
  final _form = GlobalKey<FormState>();
  User? user;
  String address = '';
  Position? _currentPosition;
  late TimeOfDay time;
  late startAddress startLocation;
  String googleApikey = "AIzaSyAQiFVO-8_aDV8RikLqmvc9QaGA2dDD4_Y";

  Future<Position> _getGeoLocationPosition() async {
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
      _address.text = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }



  void validateAndSave(){
    final form = _form.currentState;
    if(form!.validate())
    {

      Navigator.push(context,
        MaterialPageRoute(builder: (context) => HomePage(isBottomSheetShow: false,)),
      );
    }
    else
    {
      Fluttertoast.showToast(msg: 'Please Fill In The Form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage('assets/Klcc.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.black87,
                  ]
              )
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Image.asset('assets/logo.png', scale: 3.2),
              centerTitle: true,
              backgroundColor: Colors.indigo[900],
              automaticallyImplyLeading: false
            ),
            body: Form(
              key: _form,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                child: Center(
                  child: SingleChildScrollView(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Plan Your Trip',
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
                                          final lat = geometry.location.lat;
                                          final lang = geometry.location.lng;

                                          startLocation = startAddress(address: address, latitude: lat, longitude: lang);
                                          FocusScope.of(context).requestFocus(FocusNode());
                                        };
                                      },
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: ()async{
                                      Position position = await _getGeoLocationPosition();
                                      GetAddressFromLatLong(position);
                                      },
                                    icon: Icon(Icons.gps_fixed,color: Colors.blue,))
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'When is your trip?',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                //Start Date
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 2),
                                    child: TextFormField(
                                      controller: _sDate,
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.calendar_today_rounded),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey
                                              ),
                                              borderRadius: BorderRadius.circular(12)
                                          ),
                                          labelText: "Start Date",
                                          hintText: "dd/MM/yyyy"
                                      ),
                                      validator: (value) => value!.isEmpty ? 'Please Pick a Date':null,
                                      onTap: ()async{
                                        DateTime? pickeddate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2101)
                                        );
                                        if(pickeddate != null){
                                          setState(() {
                                            _sDate.text = DateFormat('dd/MM/yyyy').format(pickeddate);
                                          });
                                        };
                                      },
                                    ),
                                  ),
                                ),
                                //End Date
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: TextFormField(
                                      controller: _time,
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.access_time_rounded ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey
                                              ),
                                              borderRadius: BorderRadius.circular(12)
                                          ),
                                          labelText: "End Date",
                                          hintText: "dd/MM/yyyy"
                                      ),
                                      validator: (value) => value!.isEmpty ? 'Please Pick a Time':null,
                                      readOnly: true,  //set it true, so that user will not able to edit text
                                      onTap: () async {
                                        TimeOfDay? pickedTime =  await showTimePicker(
                                          initialTime: TimeOfDay.now(),
                                          context: context,
                                        );

                                        if(pickedTime != null ){
                                          DateTime pickedtime = DateFormat.Hm().parse(pickedTime.format(context).toString());
                                          //converting to DateTime so that we can further format on different pattern.
                                          String formattedTime = DateFormat('HH:mm').format(pickedtime);

                                          setState(() {
                                            _time.text = formattedTime; //set the value of text field.
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height:20),
                            //Continue Button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: GestureDetector(
                                onTap: (){validateAndSave();},
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
            ),
          ),
        ),
      ),
    );
  }
}
*/

