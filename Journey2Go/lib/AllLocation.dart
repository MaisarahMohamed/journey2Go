import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

import 'package:flutter/material.dart';
import 'package:journey2go/AddTrip.dart';
import 'package:journey2go/services/http_service.dart';
import 'package:journey2go/services/scraper_service.dart';

import 'BottomDrawer.dart';
import 'PlaceInfo.dart';
import 'models/LocationsModel.dart';
import 'models/TripModel.dart';
import 'models/package_model.dart';

class AllLocation extends StatefulWidget {
  const AllLocation({Key? key}) : super(key: key);

  @override
  State<AllLocation> createState() => _AllLocationState();
}

class _AllLocationState extends State<AllLocation> with AutomaticKeepAliveClientMixin<AllLocation>{
  bool loading = false;
  bool loadingPic = false;
  List <PackageModel> destination = [];
  List <Location> coordinates = [];
  List <PlaceModel> places = [];
  List <bool> isChecked = [];
  List checkedList = [];
  User? user;

  @override
  void initState(){
    super.initState();
    scrapeLocation();
  }

  Future<void> scrapeLocation()async{
    destination.clear();
    places.clear();
    loading = true;
    setState(() {});
    final html = await HttpService.get();
    if(html != null) destination =  ScraperService.run(html);
    getCoordinates();
    setState(() {});
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
    setState(() {
      loading = false;
    });
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
                  'Welcome To Kuala Lumpur',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            //List of places
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: loading ? CircularProgressIndicator() : GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 210,
                ),
                itemCount: places.length,
                itemBuilder: (ctx, index) {
                  isChecked.add(false);
                  return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => PlaceInfo(place: places[index]))
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
                                    Image.network("${places
                                      .elementAt(index)
                                      .image}",
                                    height: 170,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    frameBuilder: (_, image, loadingBuilder, __) {
                                      if (loadingBuilder == null) {
                                        return const SizedBox(
                                          height: 170,
                                          child: Center(
                                              child: CircularProgressIndicator()),
                                        );
                                      }
                                      return image;
                                    },
                                    loadingBuilder: (BuildContext context, Widget image,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return image;
                                      return SizedBox(
                                        height: 170,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes !=
                                                null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
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
                                                  checkedList.add(places.elementAt(index));
                                                }else{
                                                  checkedList.removeWhere((element) => element.destination == places.elementAt(index).destination);
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
                                    padding: EdgeInsets.symmetric(vertical: 5,
                                        horizontal: 6),
                                    child: Column(
                                      children: [
                                        Text("${places.elementAt(index).destination}",
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
            ),
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
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: Colors.white,
                      builder: (context){
                        return BottomDrawer(checkedList: checkedList,);
                      }
                  )
                  : _showMyDialog();
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