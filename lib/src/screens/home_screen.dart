// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/src/screens/search_screen.dart';
import 'package:squirrel_main/src/widgets/post_container.dart';
import 'package:squirrel_main/utils/constant.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _homeScreenPosts = [];
  bool _loading = false;

  buildHomeScreenPosts(Post post, UserModel author) {
    return PostContainer(
      post: post,
      author: author,
      currentUserId: widget.currentUserId,
    );
  }

  showHomeScreenPosts(String currentUserId) {
    List<Widget> homePostsList = [];
    for (Post post in _homeScreenPosts) {
      homePostsList.add(
        FutureBuilder(
          future: usersRef.doc(post.authorId).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              UserModel author = UserModel.fromSnap(snapshot.data);
              return buildHomeScreenPosts(post, author);
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      );
    }
    return homePostsList;
  }

  setupHomeScreenPosts() async {
    setState(() {
      _loading = true;
    });
    QuerySnapshot allPostsSnap = await postsRef
        .doc(widget.currentUserId) // obtain a DocumentReference object
        .collection('userPosts') // access the 'userPosts' collection
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> allPosts =
        allPostsSnap.docs.map((doc) => Post.fromDoc(doc)).toList();
    if (mounted) {
      setState(() {
        _homeScreenPosts = allPosts;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setupHomeScreenPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    currentUserId: widget.currentUserId,
                  ),
                ),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
        automaticallyImplyLeading: false,
        title: Text('Home'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => setupHomeScreenPosts(),
        child: ListView(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            _loading ? LinearProgressIndicator() : SizedBox.shrink(),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 5),
                Column(
                  children: _homeScreenPosts.isEmpty && _loading == false
                      ? [
                          SizedBox(height: 5),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'There is No New posts',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ]
                      : showHomeScreenPosts(widget.currentUserId),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
