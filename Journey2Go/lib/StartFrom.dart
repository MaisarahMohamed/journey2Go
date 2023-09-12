import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart' as code;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as locator;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:journey2go/services/http_service.dart';
import 'package:journey2go/services/scraper_service.dart';
import 'AddTrip.dart';
import 'PlaceInfo.dart';
import 'models/LocationsModel.dart';
import 'models/StartAddressModel.dart';
import 'models/package_model.dart';

class StartFrom extends StatefulWidget {
  const StartFrom({Key? key}) : super(key: key);

  @override
  State<StartFrom> createState() => _StartFromState();
}

class _StartFromState extends State<StartFrom> with AutomaticKeepAliveClientMixin<StartFrom>{
  startPlan startLocation = startPlan(address: 'Not Specified', latitude: null, longitude: null);
  String googleApikey = "AIzaSyAQiFVO-8_aDV8RikLqmvc9QaGA2dDD4_Y";
  TextEditingController _address = TextEditingController();
  bool loading = false;
  bool loadingPlace = false;
  bool loadingPic = false;
  List checkedList = [];
  List <bool> isChecked = [];
  List <code.Location> coordinates = [];
  List <PackageModel> destination = [];
  List <PlaceModel> places3000 = [];
  List <PlaceModel> places = [];
  late double long;
  late double lat;
  User? user;

  @override
  void initState(){
    // TODO: implement initState
    scrapeLocation();
    super.initState();
  }

  Future<void> scrapeLocation()async{
    setState(() {
      loadingPlace = true;
    });
    destination.clear();
    places.clear();
    setState(() {});
    final html = await HttpService.get();
    if(html != null) destination =  ScraperService.run(html);
    getCoordinates();
  }

  Future<void> getCoordinates()async{
    for(int i=0 ; i < destination.length ; i++){
      coordinates = await code.locationFromAddress('${destination.elementAt(i).destination}');
      code.Location coord = coordinates[0];
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
    setState(() {
      loadingPlace = false;
    });
  }

  List<PlaceModel> getPlacesWithinDistance(double d, List<PlaceModel> p, startPlan l){
    List<PlaceModel> tempList = [];
    for(int i=0; i<p.length; i++){
      double distance = locator.Geolocator.distanceBetween(l.latitude!, l.longitude!,
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
          children: [
            Container(
              padding: EdgeInsets.only(top: 30),
              child:Center(
                child: Text(
                  'Where Do You Want To Start',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            //Current Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _address,
                decoration: InputDecoration(
                  suffixIcon: places3000.isEmpty ? IconButton(
                    onPressed: (){
                      setState(() {
                        places3000 = getPlacesWithinDistance(3000, places, startLocation);
                        print(startLocation.address);
                      });
                    },
                    icon: Icon(Icons.search),
                  )
                  :IconButton(
                    onPressed: (){
                      setState(() {
                        places3000.clear();
                        startLocation = startPlan(address: 'Not Specified', latitude: null, longitude: null);
                        _address.text = 'Not Specified';
                      });
                    },
                      icon: Icon(Icons.close),
                    ),

                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey
                        ),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    hintText: startLocation.address != 'Not Specified' ? startLocation.address: "Search Your Starting Location"
                ),
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
                      long = geometry.location.lng;
                      startLocation = startPlan(address: _address.text, latitude: lat, longitude: long);
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                  };
                },
              ),
            ),
            startLocation.address == 'Not Specified'?
            Container(
              padding: EdgeInsets.only(top: 30),
              child:Center(
                child: Text(
                  'Please Enter Your Starting Location...',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            )

            :Padding(
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
