import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../Profile Components/Logine.dart';


Future<void> registerWithEmailAndPassword(String email, String name,
    String username, String address, String phoneNumber) async {
  try {
    User? userid = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('userdata')
        .doc(userid!.uid)
        .set({
      'uid': userid!.uid,
      'email': email,
      'name': name,
      'username': username,
      'address': address,
      'phoneNumber': phoneNumber,
    });
    await FirebaseFirestore.instance.collection('users').doc(userid!.uid).set({
      'uid': userid!.uid,
      'email': email,
      'name': name,
      'username': username,
      'address': address,
      'phoneNumber': phoneNumber,
    }).then((value) => {
          FirebaseAuth.instance.signOut(),
          Get.to(() => LoginPage()),
        });
  } catch (e) {}
}
