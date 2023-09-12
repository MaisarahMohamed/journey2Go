import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:journey2go/auth/CheckStatus.dart';
import 'package:journey2go/auth/authPage.dart';
import 'package:journey2go/auth/forgotPassword.dart';
import 'package:journey2go/NavBar.dart';

class Login extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const Login({Key? key,required this.showRegisterPage}): super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool loading = false;

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    try {
      setState(() {
        loading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Fluttertoast.showToast(
        msg: 'Successfully Logged In!',
      );
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => CheckStatus()),
      );
    } on FirebaseAuthException catch (e){
      Fluttertoast.showToast(
        msg: e.message.toString(),
      );
      setState(() {
        loading = false;
      });
    }
  }

  @override

  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Hello
              Text('Hello!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  )
              ),
              SizedBox(height:10),
              Text(
                  "We're Glad You're Here!",
                  style: TextStyle(fontSize:20)
              ),
              SizedBox(height:50),

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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context){
                              return ForgotPassword();
                            }
                          ),
                        );
                      },
                      child: Text('Forgot Password?')
                    ),
                  ],
                ),
              ),

              SizedBox(height:10),
              //sign in button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:25),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:Center
                        (child: loading? CircularProgressIndicator() : Text(
                          'Sign In',
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

              //Not a member? Register Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member?'),
                  GestureDetector(
                    onTap: widget.showRegisterPage,
                    child: Text(' Register now',
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
    );
  }
}