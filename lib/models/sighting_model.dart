import 'package:cloud_firestore/cloud_firestore.dart';

class Sighting {
  String uid;
  String colour;
  Timestamp timestamp;
  GeoPoint location;

  Sighting(
      {required this.colour,
      required this.uid,
      required this.timestamp,
      required this.location});

  factory Sighting.fromDoc(DocumentSnapshot doc) {
    return Sighting(
      colour: doc['color'],
      uid: doc['uid'],
      timestamp: doc['timestamp'],
      location: doc['location'],
    );
  }
}
