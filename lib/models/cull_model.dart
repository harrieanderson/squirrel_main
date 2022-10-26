import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Cull {
  String uid;
  String gender;
  Timestamp timestamp;
  GeoPoint location;

  Cull(
      {required this.gender,
      required this.uid,
      required this.timestamp,
      required this.location});

  factory Cull.fromDoc(DocumentSnapshot doc) {
    return Cull(
      gender: doc['gender'],
      uid: doc['uid'],
      timestamp: doc['timestamp'],
      location: doc['location'],
    );
  }
}
