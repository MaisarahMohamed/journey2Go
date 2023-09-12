import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journey2go/NavBar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();

  @override

  void dispose(){
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim());
      Fluttertoast.showToast(
        msg: 'Password Email link sent. Check your Email',
      );
    } on FirebaseAuthException catch(e){
      Fluttertoast.showToast(
        msg: e.message.toString(),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Journey2Go',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily:'Lobster',
            )
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
      ),
      backgroundColor: Colors.grey[100],
      drawer: NavBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter your Email and we will send you a password reset link',
              style: TextStyle(
                fontSize: 20,
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
          
          MaterialButton(
            onPressed: passwordReset,
            child: Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            color:Colors.red[700]
          )
        ],
      ),
    );
  }
}
