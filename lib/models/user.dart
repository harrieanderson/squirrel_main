import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String uid;
  String photoUrl;
  String username;
  String firstName;
  String secondName;
  String bio;
  List following;
  List followers;

  int culls;

  UserModel(
      {required this.username,
      required this.firstName,
      required this.secondName,
      required this.uid,
      required this.photoUrl,
      required this.email,
      required this.bio,
      required this.following,
      required this.followers,
      required this.culls});

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
        username: snapshot["username"],
        uid: snapshot["uid"],
        firstName: snapshot['firstname'],
        secondName: snapshot['secondname'],
        email: snapshot["email"],
        photoUrl: snapshot["photoUrl"],
        bio: snapshot["bio"],
        following: snapshot["following"],
        followers: snapshot["followers"],
        culls: snapshot['culls']);
  }

  Map<String, dynamic> toMap() => {
        "username": username,
        "firstname": firstName,
        "secondname": secondName,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "following": following,
        "followers": followers,
        "culls": culls,
      };
}
