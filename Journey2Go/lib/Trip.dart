import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:journey2go/NavBar.dart';
import 'EditTrip.dart';

class Itinerary extends StatefulWidget {
  const Itinerary({Key? key}) : super(key: key);

  @override
  State<Itinerary> createState() => _ItineraryState();
}

class _ItineraryState extends State<Itinerary> {

  List trips = [];

  @override
  void initState(){
    super.initState();
    getUserData();
    //getTrip();
  }

  //initialize
  Future getUserData() async {
    User userData =  await FirebaseAuth.instance.currentUser!;

    FirebaseFirestore.instance
        .collection('trip')
        .where("uid", isEqualTo: userData.uid)
        .orderBy('date', descending: false)
        .orderBy('time', descending: false)
        .get()
        .then((ds) {
      ds.docs.forEach((data) {
        var tempList = {
          'dest': data['destination'],
          'desc': data['description'],
          'image': data['image'],
          'time': data['time'],
          'date': data['date'],
          'startFrom': data['startFrom'],
          'doc': data.id,
        };
        setState(() {
          trips.add(tempList);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png',scale: 3.2),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
      ),
      drawer: NavBar(),
      backgroundColor: Colors.grey[100],

      //Title
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(30),
              child:Center(
                child: Text(
                  'Your Itinerary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily:'Lobster',
                  ),
                ),
              ),
            ),
             trips.isNotEmpty ? ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: trips.length,
              itemBuilder: (_, index){
                return Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: Container(
                          width: 90,
                          child: Image.network("${trips.elementAt(index)['image']}",fit: BoxFit.cover,)),
                          title: Text("${trips.elementAt(index)['date']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${trips.elementAt(index)['dest']}"),
                              Text("${trips.elementAt(index)['time']}"),
                              Text("Start From: ${trips.elementAt(index)['startFrom']}", overflow: TextOverflow.ellipsis, maxLines: 1,)
                            ],
                          ),
                          trailing:Wrap(
                            spacing: 10,
                            children: [
                              GestureDetector(
                                onTap:(){
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => EditTrip(trip: trips[index])),
                                  );
                                },
                                child: Icon(Icons.edit,color: Colors.lightBlue)
                              ),
                              GestureDetector(
                                onTap:(){
                                  FirebaseFirestore.instance.collection('trip').doc('${trips.elementAt(index)['doc']}')
                                  .delete()
                                  .then((value) {
                                    setState(() {
                                      trips.removeAt(index);
                                    });
                                    Fluttertoast.showToast(
                                      msg:'Trip Deleted',
                                    );
                                  }
                                  ).catchError((e) => Fluttertoast.showToast(msg: "Error updating document $e"));
                                },
                                child: Icon(Icons.delete,color: Colors.red)
                              ),
                            ]
                          ),
                        ),
                      ),
                    ]
                 );
                },
              ):Text('Your Itinerary is Empty...', style: TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );

  }
}




