import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id;
  String authorId;
  String text;
  String image;
  Timestamp timestamp;
  final likes;

  Comment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.image,
    required this.timestamp,
    required this.likes,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      authorId: doc['authorId'],
      text: doc['text'],
      image: doc['image'],
      timestamp: doc['timestamp'],
      likes: doc['likes'],
    );
  }
}
