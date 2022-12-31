import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:squirrel_main/helperfunctions/sharedpref_helper.dart';
import 'package:squirrel_main/models/activity.dart';
import 'package:squirrel_main/models/cull_model.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/sighting_model.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/utils/constant.dart';

class DatabaseMethods {
  // when user edit's a page, this info get's updated
  static void updateUserInfo(UserModel user) {
    usersRef.doc(user.uid).update({
      'username': user.username,
      'bio': user.bio,
      'photoUrl': user.photoUrl
    });
  }

  // fetches the number of followers a user has
  static Future<int> followersNum(String userId) async {
    QuerySnapshot followersSnapshot =
        await usersRef.doc(userId).collection('followers').get();
    return followersSnapshot.docs.length;
  }

  // gets the length of comments made on a single post
  static Future<int> commentsNum(String postId) async {
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection('comments').get();
    return commentsSnapshot.docs.length;
  }

  // fetches the number of likes on a post
  static Future<int> likesNum(String postId) async {
    QuerySnapshot likesSnapshot =
        await likesRef.doc(postId).collection('userLikes').get();
    return likesSnapshot.docs.length;
  }

  // fetches the length of the posts made by a user

  static Future<int> postsNumb(String userId) async {
    QuerySnapshot postNumSnapshot =
        await postsRef.doc(userId).collection('userPosts').get();
    return postNumSnapshot.docs.length;
  }

  // fetches the length of the cull collection based on UID
  static Future<int> cullsCount(String userId) async {
    QuerySnapshot cullsSnapshot =
        await cullsRef.doc(userId).collection('userCulls').get();
    return cullsSnapshot.docs.length;
  }

  // searches user based on user name
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

  static Future<List<UserModel>> getFollowersToMessage(String uid) async {
    final usersSnapshot = await usersRef.get();
    print(usersSnapshot.docs);

    final list = usersSnapshot.docs.map((doc) {
      return UserModel.fromSnap(doc);
    }).toList();
    return list;
  }

  // takes care of following users
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
    // addActivity(uid, null, true, followedUserId)
  }

  // takes care of unfollowing users
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

  // creates firebase colletion for culls made based on UID
  static void addCull(Cull cull) {
    cullsRef.doc(cull.uid).set({'cullTime': cull.timestamp});
    cullsRef.doc(cull.uid).collection("userCulls").add({
      "uid": cull.uid,
      "gender": cull.gender,
      "timestamp": cull.timestamp,
      "location": cull.location
    });
  }

  // creates firebase collection for sightings based on UID
  static void addSighting(Sighting sighting) {
    sightingsRef.doc(sighting.uid).set({'sightingTime': sighting.timestamp});
    sightingsRef.doc(sighting.uid).collection("userSightings").add({
      "uid": sighting.uid,
      "species": sighting.species,
      "timestamp": sighting.timestamp,
      "location": sighting.location
    });
  }

  // adds user post to their own post collection
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

  // get's user posts to display to their own profile
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

  // gets posts to display to home screen
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

  // like and unliking posts
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
        // addActivity(currentUserId, post, false, '');
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // gets activities when a user interacts with another user
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

  // adds activity to the activities
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
