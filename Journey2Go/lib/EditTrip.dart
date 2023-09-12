import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'NavBar.dart';
import 'Trip.dart';

class EditTrip extends StatefulWidget {
  final trip;
  const EditTrip({Key? key, required this.trip}) : super(key: key);

  @override
  State<EditTrip> createState() => _EditTripState();
}

class _EditTripState extends State<EditTrip> {
  TextEditingController _date = TextEditingController();
  TextEditingController _time = TextEditingController();

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
    _date.text = widget.trip['date'];
    _time.text = widget.trip['time'];
    getUserData();
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
          body: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              margin: EdgeInsets.symmetric(horizontal: 30,vertical: 150),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                      child: Text(
                        'Edit Your Trip',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                  ),
                  Text(
                    'Your Destination:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  Text(
                    '${widget.trip['dest']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Starting From:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      '${widget.trip['startFrom']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  //Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color:Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left:20),
                        child: TextField(
                          controller: _date,
                          decoration: InputDecoration(
                            icon: Icon(Icons.calendar_today_rounded),
                            border: InputBorder.none,
                            labelText: "Select Date",
                          ),
                          onTap: ()async{
                            DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(_date.text),
                                firstDate: DateTime(DateTime.now().year),
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
                  SizedBox(height:30),

                  //Time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color:Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left:20),
                        child: TextField(
                          controller: _time,
                          decoration: InputDecoration(
                            icon: Icon(Icons.access_time_rounded),
                            border: InputBorder.none,
                            labelText: "Select Time",
                          ),
                          readOnly: true,  //set it true, so that user will not able to edit text
                          onTap: () async {
                            TimeOfDay? pickedTime =  await showTimePicker(
                              initialTime: TimeOfDay(hour:int.parse(_time.text.split(":")[0]),minute: int.parse(_time.text.split(":")[1])),
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
                  ),
                  SizedBox(height:20),

                  //Save button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: GestureDetector(
                      onTap: (){
                        if(user != null){
                          FirebaseFirestore.instance.collection('trip').doc('${widget.trip['doc']}')
                              .update(
                                {
                                  'date' : '${_date.text}',
                                  'time' : '${_time.text}',
                                }
                              )
                              .then((value) {
                            Fluttertoast.showToast(
                              msg:'Trip Saved Successfully!',
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Itinerary()),
                            );
                          })
                            .catchError((error) =>
                            Fluttertoast.showToast(
                              msg:'Trip Failed To Edit. $error',
                            ),
                          );
                        }

                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center
                          (child: Text(
                            "Edit Trip",
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
    );
  }
}
