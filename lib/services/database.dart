import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:squirrel_main/helperfunctions/sharedpref_helper.dart';
import 'package:squirrel_main/models/activity.dart';
import 'package:squirrel_main/models/comment.dart';
import 'package:squirrel_main/models/cull_model.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/sighting_model.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/utils/constant.dart';

class DatabaseMethods {
  static void updateUserInfo(UserModel user) {
    usersRef.doc(user.uid).update({
      'username': user.username,
      'bio': user.bio,
      'photoUrl': user.photoUrl
    });
  }

  static Future<int> followersNum(String userId) async {
    QuerySnapshot followersSnapshot =
        await usersRef.doc(userId).collection('followers').get();
    return followersSnapshot.docs.length;
  }

  static Future<int> commentsNum(String postId) async {
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection('comments').get();
    return commentsSnapshot.docs.length;
  }

  static Future<int> likesNum(String postId) async {
    QuerySnapshot likesSnapshot =
        await likesRef.doc(postId).collection('userLikes').get();
    return likesSnapshot.docs.length;
  }

  static Future<int> postsNumb(String userId) async {
    QuerySnapshot postNumSnapshot =
        await postsRef.doc(userId).collection('userPosts').get();
    return postNumSnapshot.docs.length;
  }

  static Future<int> cullsCount(String userId) async {
    QuerySnapshot cullsSnapshot =
        await cullsRef.doc(userId).collection('userCulls').get();
    return cullsSnapshot.docs.length;
  }

  static Future<List<UserModel>> searchUsers(String name) async {
    final usersSnapshot = await usersRef
        .where('username', isGreaterThanOrEqualTo: name)
        .where('username', isLessThan: '${name}z')
        .get();

    final list = usersSnapshot.docs.map((doc) {
      return UserModel.fromSnap(doc);
    }).toList();
    return list;
  }

  static Future<List<UserModel>> getFollowersToMessage(String username) async {
    final usersSnapshot = await usersRef.get();
    print(usersSnapshot.docs);

    final list = usersSnapshot.docs.map((doc) {
      return UserModel.fromSnap(doc);
    }).toList();
    return list;
  }

  Future<void> followUser(
    uid,
  ) async {
    await usersRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(uid)
        .set({});

    await usersRef
        .doc(uid)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({});
  }

  Future<void> unFollowUser(uid) async {
    await usersRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(uid)
        .delete();

    await usersRef
        .doc(uid)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  }

  Stream<QuerySnapshot> getUserByUsername(String username) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .snapshots();
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exist
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatRoomMessages(chatRoomId) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('ts')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatRooms() {
    String? myUsername = SharedPreferenceHelper().userName;
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }

  static void addCull(Cull cull) {
    cullsRef.doc(cull.uid).set({'cullTime': cull.timestamp});
    cullsRef.doc(cull.uid).collection("userCulls").add({
      "uid": cull.uid,
      "gender": cull.gender,
      "timestamp": cull.timestamp,
      "location": cull.location
    });
  }

  static void addSighting(Sighting sighting) {
    sightingsRef.doc(sighting.uid).set({'sightingTime': sighting.timestamp});
    sightingsRef.doc(sighting.uid).collection("userSightings").add({
      "uid": sighting.uid,
      "species": sighting.colour,
      "timestamp": sighting.timestamp,
      "location": sighting.location
    });
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: username)
        .get();
  }

  static void createPost(Post post) {
    postsRef.doc(post.authorId).set({'postTime': post.timestamp});
    postsRef.doc(post.authorId).collection("userPosts").add({
      "text": post.text,
      "image": post.image,
      "authorId": post.authorId,
      "timestamp": post.timestamp,
      "likes": post.likes
    });
  }

  static Future<List<Post>> getUserPosts(String currentUserId) async {
    QuerySnapshot userPostsSnap = await postsRef
        .doc(currentUserId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> userPosts =
        userPostsSnap.docs.map((doc) => Post.fromDoc(doc)).toList();
    return userPosts;
  }

  static Future<List<Post>> getHomeScreenPosts(String currentUserId) async {
    QuerySnapshot homePostsSnap = await FirebaseFirestore.instance
        .collectionGroup('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> homeScreenPosts =
        homePostsSnap.docs.map((doc) => Post.fromDoc(doc)).toList();

    return homeScreenPosts;
  }

  static Future<List<UserModel>> getUsersToMessage(String currentUserId) async {
    QuerySnapshot userMessageSnap =
        await usersRef.doc(currentUserId).collection('followers').get();
    List<UserModel> usersToMessage =
        userMessageSnap.docs.map((doc) => UserModel.fromSnap(doc)).toList();

    return usersToMessage;
  }

  Future likePost(
      Post post, String currentUserId, List likes, bool current) async {
    String res = "Some error occurred";
    try {
      if (current) {
        likesRef
            .doc(post.id)
            .collection('userLikes')
            .doc(currentUserId)
            .delete();
      } else {
        likesRef
            .doc(post.id)
            .collection('userLikes')
            .doc(currentUserId)
            .set({});
        addActivity(
          currentUserId,
          post,
          false,
          '',
        );
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  static void unlikePost(String currentUserId, Post post) {
    DocumentReference postDocProfile =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postDocProfile.get().then((doc) {
      int likes = doc['likes'];
      postDocProfile.update({'likes': likes - 1});
    });

    likesRef
        .doc(post.id)
        .collection('postLikes')
        .doc(currentUserId)
        .get()
        .then((doc) => doc.reference.delete());
  }

  static Future<bool> isLikePost(String currentUserId, Post post) async {
    DocumentSnapshot userDoc = await likesRef
        .doc(post.id)
        .collection('postLikes')
        .doc(currentUserId)
        .get();

    return userDoc.exists;
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .doc(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .get();

    List<Activity> activities = userActivitiesSnapshot.docs
        .map((doc) => Activity.fromDoc(doc))
        .toList();

    return activities;
  }

  static void addActivity(
      String currentUserId, Post? post, bool follow, String followedUserId) {
    if (follow) {
      activitiesRef.doc(followedUserId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        "follow": true,
      });
    } else {
      //like
      activitiesRef.doc(post!.id).collection('userActivities').add({
        'fromUserId': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        "follow": false,
      });
    }
  }
}
