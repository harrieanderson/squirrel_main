import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/utils/constant.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = 'Some Error occurred';
    try {
      if (text.isNotEmpty) {
        commentsRef.doc(postId).collection("comments").add({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'datePublished': DateTime.now()
        });
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap = await usersRef.doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await usersRef.doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await usersRef.doc(uid).update({
          'following': FieldValue.arrayRemove([uid])
        });
      } else {
        await usersRef.doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await usersRef.doc(uid).update({
          'following': FieldValue.arrayUnion([uid])
        });
      }
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

  Future likePost(String postId, String uid, List likes, bool current) async {
    String res = "Some error occurred";
    try {
      if (current) {
        likesRef.doc(postId).collection('userLikes').doc(uid).delete();
      } else {
        likesRef.doc(postId).collection('userLikes').doc(uid).set({});
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
