import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'BottomDrawer.dart';
import 'BottomDrawerFav.dart';
import 'NavBar.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List fav = [];
  List <bool> isChecked = [];
  List checkedList = [];

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
        .collection('favourite')
        .where("uid", isEqualTo: userData.uid)
        .get()
        .then((ds) {
      ds.docs.forEach((data) {
        var tempList = {
          'dest': data['destination'],
          'desc': data['description'],
          'image': data['image'],
          'latitude':data['latitude'],
          'longitude':data['longitude'],
          'doc': data.id,
        };
        setState(() {
          fav.add(tempList);
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(30),
            child:Center(
              child: Text(
                'Your Favourites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (fav.isNotEmpty) ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: fav.length,
            itemBuilder: (_, index){
              isChecked.add(false);
              return Column(
                  children: [
                    Card(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Row(
                          children: [
                            Container(
                                width: 90,
                                child: Image.network("${fav.elementAt(index)['image']}",fit: BoxFit.cover,)
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text("${fav.elementAt(index)['dest']}",overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ),
                          ],
                        ),
                        secondary: Wrap(
                            spacing: 10,
                            children: [
                              GestureDetector(
                                  onTap:(){
                                    FirebaseFirestore.instance.collection('favourite').doc('${fav.elementAt(index)['doc']}')
                                        .delete()
                                        .then((value) {
                                      setState(() {
                                        fav.removeAt(index);
                                      });
                                      Fluttertoast.showToast(
                                        msg:'Deleted from favourites',
                                      );
                                    }
                                    ).catchError((e) => Fluttertoast.showToast(msg: "Error updating document $e"));
                                  },
                                  child: Icon(Icons.delete,color: Colors.red)
                              ),
                            ]
                        ),
                        value: isChecked.elementAt(index),
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked[index] = value!;
                            if (value!){
                              checkedList.add(fav.elementAt(index));
                            }else{
                              checkedList.remove(fav.elementAt(index));
                            }
                          });
                      }),

                    ),
                  ]
              );
            },
          ) else Text('You Have No Favourites Yet', style: TextStyle(fontSize: 16),),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 25, vertical: 10),
            child: GestureDetector(
                onTap: (){
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: Colors.white,
                      builder: (context){
                        return BottomDrawerFav(checkedList: checkedList,);
                      }
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                      "Add To Itinerary",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }
}
