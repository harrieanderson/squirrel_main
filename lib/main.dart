import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/src/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'helperfunctions/sharedpref_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Future.wait([
    SharedPreferenceHelper.instance.initialise(),
  ]).then((_) => runApp(
        App(),
      ));
}
