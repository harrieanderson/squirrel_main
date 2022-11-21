import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:squirrel_main/utils/constant.dart';
import 'package:squirrel_main/services/database.dart';

class FirestoreMethods {
  // makes comment to a post
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

  Future<void> deletePost(String postId, String userId) async {
    try {
      postsRef.doc(userId).collection('userPosts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }
}
