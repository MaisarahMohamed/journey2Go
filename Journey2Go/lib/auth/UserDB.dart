import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({required this.uid});

  //collection reference
  final CollectionReference user = FirebaseFirestore.instance.collection('user');

  Future updateUserData(String firstName, String lastName, String email) async{
    return await user.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'email': email,
    });
  }
}