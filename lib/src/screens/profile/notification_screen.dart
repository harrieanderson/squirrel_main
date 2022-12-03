// ignore_for_file: public_member_api_docs, sort_constructors_first, empty_constructor_bodies, prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/utils/constant.dart';

import '../../../models/activity.dart';

class NotificationsScreen extends StatefulWidget {
  final String currentUserId;

  const NotificationsScreen({Key? key, required this.currentUserId})
      : super(key: key);
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activitiesRef
        .doc(widget.currentUserId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    for (var doc in snapshot.docs) {
      feedItems.add(ActivityFeedItem.fromDoc(doc));
      print("Activity feed item ${doc.data()}");
    }
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Widget>>(
        future: getActivityFeed(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return ListView(children: snapshot.data);
        }),
      ),
    );
  }
}

late Widget mediaPreview;
late String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String commentData;
  final String image;
  final String postId;
  final Timestamp timestamp;
  final String type; // 'like', 'follow', 'comment'
  final String userId;
  final String photoUrl;
  final String username;

  const ActivityFeedItem(
      {super.key,
      required this.commentData,
      required this.image,
      required this.postId,
      required this.timestamp,
      required this.type,
      required this.userId,
      required this.username,
      required this.photoUrl});

  factory ActivityFeedItem.fromDoc(DocumentSnapshot doc) {
    return ActivityFeedItem(
      commentData: doc['commentData'],
      image: doc['image'],
      postId: doc['postId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      userId: doc['userId'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
    );
  }

  configureMediaPreview() {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => print('showing post'),
        child: SizedBox(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(image),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (type == 'like') {
      activityItemText = 'liked your post';
    } else if (type == 'follow') {
      activityItemText = "is now following you";
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = "Error: unknown type $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => print('show profile'),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: activityItemText)
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
          ),
          subtitle: Text(
            timestamp.toString(),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
