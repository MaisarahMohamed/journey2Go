import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:journey2go/main.dart';

import 'UserDB.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool showPassword = false;

  //text controllers
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();

  User? user;
  bool loading = false;

  //initialize
  Future getUserData() async {
    User userData =  await FirebaseAuth.instance.currentUser!;
    var userID = userData.uid;
    var collection = FirebaseFirestore.instance.collection('user');

    var docSnapshot = await collection.doc(userID).get();

    Map<String, dynamic> data = docSnapshot.data()!;

    setState(() {
      _firstNameController.text = data['first name'];
      _lastNameController.text = data['last name'];
      _emailController.text = userData.email!;
      user = userData;
    });
  }

  @override
  void initState(){
    super.initState();
    getUserData();
  }

  bool passwordConfirmed(){
    if (_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    } else {
      return false;
    }
  }

  Future UpdateUserData() async {
    //User authentication
    try{
      if(_passwordController.text != null){
        if(passwordConfirmed()) {
          user?.updatePassword(_passwordController.text);
          //update user data of the current user
          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).updateUserData(_firstNameController.text, _lastNameController.text,_emailController.text);
          Fluttertoast.showToast(
            msg: 'Successfully Updated!',
          );
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => HomePage())
          );
        }else{
          Fluttertoast.showToast(
            msg: "Passwords don't match please try again",
          );
        }
      }else{
        //update user data of the current user
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).updateUserData(_firstNameController.text, _lastNameController.text,_emailController.text);
        Fluttertoast.showToast(
          msg: 'Successfully Updated!',
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomePage())
        );
      }
    } on FirebaseAuthException catch(e){
      Fluttertoast.showToast(
        msg: e.message.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', scale: 3.2),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 25),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Center(
                child: Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 15,
              ),

              //First Name text field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 25),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(12))
                            ),
                            hintText: user == null ?
                            'First Name' : '$_firstNameController',
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListTile(
                        title: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 25),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(12))
                            ),
                            hintText: user == null ?
                            'Last Name' : '$_lastNameController',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              //Email text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      onTap: () {
                        Fluttertoast.showToast(
                          msg: 'Textfield Disabled',
                        );
                      },
                      enabled: false,
                      controller: _emailController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: user == null ?
                          'Email' : '$_emailController'
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              //Password text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              //Confirm Password text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Confirm Password',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => HomePage())
                        );
                      },
                      child: Text("CANCEL",
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 2.2,
                              color: Colors.black)
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => UpdateUserData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}