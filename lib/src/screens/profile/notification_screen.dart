// ignore_for_file: public_member_api_docs, sort_constructors_first, empty_constructor_bodies, prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/utils/constant.dart';

class NotificationsScreen extends StatefulWidget {
  final String currentUserId;

  const NotificationsScreen({Key? key, required this.currentUserId})
      : super(key: key);
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Stream<List<ActivityFeedItem>> getActivityFeed() {
    return activitiesRef
        .doc(widget.currentUserId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ActivityFeedItem.fromDoc(doc)).toList());
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
      body: StreamBuilder<List<ActivityFeedItem>>(
        stream: getActivityFeed(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final list = snapshot.data;
            if (list == null) {
              return CircularProgressIndicator();
            }
            return ListView(children: list);
          }
        },
      ),
    );
  }
}

Widget mediaPreview = Text('');
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

  const ActivityFeedItem({
    super.key,
    required this.commentData,
    required this.image,
    required this.postId,
    required this.timestamp,
    required this.type,
    required this.userId,
    required this.username,
    required this.photoUrl,
  });

  factory ActivityFeedItem.fromDoc(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ActivityFeedItem(
      commentData: data.containsKey('commentData') ? data['commentData'] : '',
      image: data.containsKey('image') ? data['image'] : '',
      postId: data.containsKey('postId') ? data['postId'] : '',
      timestamp: data.containsKey('timestamp') ? data['timestamp'] : null,
      type: data.containsKey('type') ? data['type'] : '',
      userId: data.containsKey('userId') ? data['userId'] : '',
      username: data.containsKey('username') ? data['username'] : '',
      photoUrl: data.containsKey('photoUrl') ? data['photoUrl'] : '',
    );
  }

  void configureMediaPreview() {
    if (image.isNotEmpty && type != 'like') {
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
      activityItemText = ' replied: $commentData';
    } else {
      activityItemText = "Error: unknown type $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: Column(
          children: [
            ListTile(
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
                      TextSpan(
                        text: '\n${date.hour}:${date.minute}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                      TextSpan(
                        text: ' $activityItemText',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl),
              ),
              trailing: mediaPreview,
            ),
            if (commentData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 60.0),
                child: Text(
                  commentData,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
