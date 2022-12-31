import 'package:cloud_firestore/cloud_firestore.dart';

class Sighting {
  String uid;
  String species;
  Timestamp timestamp;
  GeoPoint location;

  Sighting(
      {required this.species,
      required this.uid,
      required this.timestamp,
      required this.location});

  factory Sighting.fromDoc(DocumentSnapshot doc) {
    return Sighting(
      species: doc['species'],
      uid: doc['uid'],
      timestamp: doc['timestamp'],
      location: doc['location'],
    );
  }
}
