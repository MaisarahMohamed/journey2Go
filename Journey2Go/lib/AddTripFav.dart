import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:journey2go/NavBar.dart';
import 'package:intl/intl.dart';
import 'package:journey2go/Trip.dart';
import 'package:journey2go/models/TripModel.dart';
import 'models/LocationsModel.dart';
import 'models/StartAddressModel.dart';

class AddTripFav extends StatefulWidget {
  final startPlan startLocation;
  final List checkedList;
  AddTripFav({Key? key, required this.startLocation, required this.checkedList}):super(key:key);

  @override
  State<AddTripFav> createState() => _AddTripFavState();
}

class _AddTripFavState extends State<AddTripFav> {

  TextEditingController _date = TextEditingController();
  TextEditingController _time = TextEditingController();
  List <bool> isChecked = [];
  List <TripModel> selected = [];

  late TimeOfDay time;

  late User user;
  List <PlaceModel> fav = [];


  //initialize
  Future getUserData() async {
    User userData =  FirebaseAuth.instance.currentUser!;
      setState(() {
        user = userData;
      });
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,// user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Overview'),
          content: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Your trip will be on : ',style: TextStyle(fontWeight: FontWeight.bold),),
                      Text('${_date.text}')
                    ],
                  ),
                  Row(
                    children: [
                      Text('Starting from : ',style: TextStyle(fontWeight: FontWeight.bold)),
                      Flexible(child: Text('${widget.startLocation.address}',overflow: TextOverflow.ellipsis,maxLines: 1,))
                    ],
                  ),
                  Row(
                    children: [
                      Text('At : ',style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_time.text)
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Trip We Planned For You: ',style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),


                  for(int i=0 ; i<selected.length; i++)
                    Row(
                      children: [
                        Text('${(TimeOfDay(
                            hour:(int.parse(_time.text.split(":")[0])+(i+1)),
                            minute: int.parse(_time.text.split(":")[1]))).format(context)} - '),
                        Flexible(
                          child: Text(selected[i].destination.toString(),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                    ),

                ],
              )),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Text('Cancel',style: TextStyle(color: Colors.white),),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: ElevatedButton(
                onPressed: (){
                  for(int i=0;i<selected.length;i++) {
                    Map<String, dynamic>tripData = {
                      'uid': user.uid,
                      'destination': selected.elementAt(i).destination,
                      'description': selected.elementAt(i).description,
                      'startFrom': widget.startLocation.address,
                      'image': selected.elementAt(i).image,
                      'date': _date.text,
                      'time': (TimeOfDay(hour:(int.parse(_time.text.split(":")[0])+(i+1)),
                          minute: int.parse(_time.text.split(":")[1]))).format(context),
                    };
                    FirebaseFirestore.instance.collection('trip').add(tripData)
                        .catchError((error) =>
                        Fluttertoast.showToast(
                          msg:'Trip Failed To Save. $error',
                        ),
                    );
                  }
                  Fluttertoast.showToast(
                    msg:'Trip Successfully Saved',
                  );
                  Navigator.pushNamedAndRemoveUntil(context, '/itinerary', (r) => false);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Text('Save',style: TextStyle(color: Colors.white),),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  List<PlaceModel> getPlacesWithinDistance(double d, List<PlaceModel> p, startPlan l){
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
  void initState(){
    super.initState();
    getUserData();
    print(widget.checkedList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ),
          drawer: NavBar(),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                          child: Text(
                            'Save Your Trip',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                      ),
                    ),

                    SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Starting From:',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              '${widget.startLocation.address}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    //Date
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:25),
                      child: Row(
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(right:3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color:Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:5),
                                    child: TextField(
                                      controller: _date,
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.calendar_today_rounded),
                                        border: InputBorder.none,
                                        labelText: "Select Date",
                                      ),
                                      onTap: ()async{
                                        DateTime? pickeddate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101)
                                        );
                                        if(pickeddate != null){
                                          setState(() {
                                            _date.text = DateFormat('dd/MM/yyyy').format(pickeddate);
                                          });
                                        };
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left:3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color:Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:5),
                                    child: TextField(
                                      controller: _time,
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.access_time_rounded),
                                        border: InputBorder.none,
                                        labelText: "Select Time",
                                      ),
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
                              ),)
                          ]
                      ),
                    ),
                    SizedBox(height:20),
                    //Save button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: GestureDetector(
                        onTap: (){
                          if(_date.text == '' || _time.text == ''){
                            Fluttertoast.showToast(
                                msg: 'Please Fill Out Form'
                            );
                          }else{
                            selected.clear();
                            for(int i =0; i<widget.checkedList.length; i++){
                              double distance = Geolocator.distanceBetween(widget.checkedList.elementAt(i)['latitude']!, widget.checkedList.elementAt(i)['longitude']!,
                                  widget.startLocation.latitude!, widget.startLocation.longitude!);

                              TripModel trip = TripModel(
                                destination: widget.checkedList[i]['dest'],
                                description: widget.checkedList[i]['desc'],
                                image: widget.checkedList[i]['image'],
                                startDest: widget.startLocation.address,
                                latitude: widget.checkedList[i]['latitude'],
                                longitude: widget.checkedList[i]['longitude'],
                                distance: distance,
                              );
                              setState(() {
                                  selected.add(trip);
                              });

                            }
                            setState(() {
                                selected.sort((a,b)=> b.distance!.compareTo(a.distance!));
                            });

                            _showDialog();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center
                            (child: Text(
                              "Save Trip",
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
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

