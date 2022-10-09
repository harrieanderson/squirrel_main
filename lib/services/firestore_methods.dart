import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/utils/constant.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = 'Some Error occurred';
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        commentsRef.doc(postId).collection("comments").add({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now()
        });
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> addFriend(String uid, String friendId) async {
    try {
      DocumentSnapshot snap = await usersRef.doc(uid).get();
      List friends = (snap.data()! as dynamic);
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> deletePost(String postId, String userId) async {
    try {
      postsRef.doc(userId).collection('userPosts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        postsRef.doc(uid).collection('userPosts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        postsRef.doc(uid).collection('userPosts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
