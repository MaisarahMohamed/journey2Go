import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journey2go/Dashboard.dart';
import 'package:journey2go/PlanTrip.dart';
import 'package:journey2go/auth/authPage.dart';
import 'package:journey2go/main.dart';

class CheckStatus extends StatelessWidget {
  const CheckStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData && snapshot.data != null){
            return HomePage();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}