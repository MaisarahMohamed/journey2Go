import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:journey2go/FavouritesPage.dart';
import 'package:journey2go/auth/UserAccount.dart';
import 'package:journey2go/auth/CheckStatus.dart';
import 'package:journey2go/Trip.dart';
import 'package:journey2go/main.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  User? user;
  String? firstName;
  String? lastName;

  //initialize
  Future getUserData() async {
    User userData =  await FirebaseAuth.instance.currentUser!;
    var userID = userData.uid;
    var collection = FirebaseFirestore.instance.collection('user');

    var docSnapshot = await collection.doc(userID).get();

    Map<String, dynamic> data = docSnapshot.data()!;

    setState(() {
      firstName = data['first name'];
      lastName = data['last name'];
      user = userData;
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminder'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please login first'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst,);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();
    getUserData();
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: user == null?
                          Text("Not Logged In")
                          :Text("$firstName $lastName"),
            accountEmail: user == null?
                            Text("")
                            :Text("${user?.email}"),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cover.jpg'),
                  fit: BoxFit.cover
              ),
              color: Colors.red[700],
            ),
          ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Planned Trips'),
            onTap: () {
              if(user == null){
              _showMyDialog();
              }else{
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Itinerary()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favourites'),
            onTap: () {
              if(user == null){
                _showMyDialog();
              }else{
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FavouritesPage()),
                );
              }
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(' Account Settings'),
            onTap: (){
              if(user == null){
                _showMyDialog();
              }else{
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>EditProfilePage()));
              }
            }
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.power_settings_new_rounded),
            title: Text('Logout'),
            onTap: (){
              if(user==null){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>CheckStatus()),
                );
              }else{
                FirebaseAuth.instance.signOut();
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>CheckStatus()),
                );
              };
            },
          ),
        ],
      ),
    );
  }
}
