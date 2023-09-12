import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journey2go/NavBar.dart';
import 'package:journey2go/auth/UserDB.dart';

import 'CheckStatus.dart';

class Register extends StatefulWidget {
  final VoidCallback showLoginPage;
  const Register({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();


  bool loading = false;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future SignUp() async {
    //User authentication
    if (passwordConfirmed()) {
      setState(() {
        loading = true;
      });
      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );


        //create a new doc for the user with uid
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).updateUserData(_firstNameController.text, _lastNameController.text,_emailController.text);
        Fluttertoast.showToast(
          msg: 'Successfully Registered!',
        );
        setState(() {
          loading = false;
        });
      } on FirebaseAuthException catch(e){
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
          msg: e.message.toString(),
        );
      }
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => CheckStatus()),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Passwords don't match. Try again.",
      );
      setState(() {
        loading = false;
      });
    }
  }

  bool passwordConfirmed(){
    if (_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    } else {
      return false;
    }
  }

  void pickUpLoadImage()async{
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 130,
        maxWidth: 130,
        imageQuality: 75
    );


  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', scale: 3.2),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
        automaticallyImplyLeading: false
      ),
      backgroundColor: Colors.grey[100],
      drawer: NavBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Hello
                Text('Welcome!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    )
                ),
                SizedBox(height:10),
                Text(
                    "Register Below with your details.",
                    style: TextStyle(fontSize:20)
                ),
                SizedBox(height:50),

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
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'First Name',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height:10),

                //Last Name text field
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
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Last Name',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height:10),

                //Email text field
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height:10),

                //Password text field
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
                SizedBox(height:10),

                //Confirm Password text field
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
                SizedBox(height:10),

                //sign up button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:25),
                  child: GestureDetector(
                    onTap: SignUp,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:Center
                        (child: loading? CircularProgressIndicator(): Text(
                          'Sign Up',
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
                SizedBox(height:10),

                //I am a member? Register Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('I am a member.'),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(' Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
