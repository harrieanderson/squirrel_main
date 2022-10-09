import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:squirrel_main/models/user.dart' as model;
import 'package:squirrel_main/services/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.UserModel.fromSnap(documentSnapshot);
  }
}

class Authenticator {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String firstName,
      required String secondName,
      required String username,
      required String bio,
      required Uint8List? file}) async {
    String res = "An error occured";

    try {
      if (email.isNotEmpty ||
          firstName.isNotEmpty ||
          secondName.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String photoUrl =
            'https://firebasestorage.googleapis.com/v0/b/squirrel-84cdc.appspot.com/o/profilepics%2Fdefault_pic.png?alt=media&token=b1ab9a60-b5a8-4acd-aa32-a49167082fd6';
        if (file != null) {
          photoUrl = await StorageMethods()
              .uploadImageToStorage('profilepics', file, false);
        }

        //   model
        model.UserModel _user = model.UserModel(
            username: username,
            firstName: firstName,
            secondName: secondName,
            uid: cred.user!.uid,
            email: email,
            photoUrl: photoUrl,
            culls: 0,
            friends: [],
            bio: bio);

        // add user to our database
        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(_user.toMap());
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await _auth.signOut();
  }
}
