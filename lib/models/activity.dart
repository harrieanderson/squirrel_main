import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Activity {
  String id;
  String fromUserId;
  Timestamp timestamp;
  bool follow;

  Activity(
      {required this.id,
      required this.fromUserId,
      required this.follow,
      required this.timestamp});

  factory Activity.fromDoc(DocumentSnapshot doc) {
    return Activity(
      id: doc.id,
      fromUserId: doc['fromUserId'],
      timestamp: doc['timestamp'],
      follow: doc['follow'],
    );
  }
}
