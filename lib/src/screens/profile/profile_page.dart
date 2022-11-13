// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unrelated_type_equality_checks

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/services/auth.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/services/firestore_methods.dart';
import 'package:squirrel_main/src/screens/profile/edit_profile_screen.dart';
import 'package:squirrel_main/src/screens/login/login_screen.dart';
import 'package:squirrel_main/src/screens/profile/notification_screen.dart';
import 'package:squirrel_main/src/widgets/follow_button.dart';
import 'package:squirrel_main/src/widgets/post_container.dart';
import 'package:squirrel_main/utils/colors.dart';
import 'package:squirrel_main/utils/constant.dart';
import 'package:squirrel_main/utils/utils.dart';

const _kAvatarRadius = 45.0;
const _kAvatarPadding = 16.0;

class ProfilePageUi extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;

  const ProfilePageUi({
    Key? key,
    required this.visitedUserId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ProfilePageUiState createState() => _ProfilePageUiState();
}

class _ProfilePageUiState extends State<ProfilePageUi> {
  late final _isOwnProfilePage = widget.visitedUserId == widget.currentUserId;

  List<Post> _allPosts = [];
  bool isFollowing = false;

  int _followersCount = 0;
  int _postsCount = 0;
  int _cullsCount = 0;

  getPostsCount() async {
    int postsCount = await DatabaseMethods.postsNumb(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _postsCount = postsCount;
      });
    }
  }

  getFollowersCount() async {
    int followersCount =
        await DatabaseMethods.followersNum(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _followersCount = followersCount;
      });
    }
  }

  getCullCount() async {
    int cullsCount = await DatabaseMethods.cullsCount(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _cullsCount = cullsCount;
      });
    }
  }

  Future<bool> getFollowingStatus() async {
    DocumentSnapshot document = await usersRef
        .doc(widget.currentUserId)
        .collection('following')
        .doc(widget.visitedUserId)
        .get();

    if (document.exists) {
      isFollowing = document.exists;
      setState(() {
        isFollowing = document.exists;
      });
      return true;
    } else {
      isFollowing = document.exists;
      setState(() {
        isFollowing = document.exists;
      });
      return false;
    }
  }

  showProfilePosts(UserModel author) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: _allPosts.length,
        itemBuilder: (context, index) {
          return PostContainer(
            post: _allPosts[index],
            author: author,
            currentUserId: widget.currentUserId,
          );
        },
      ),
    );
  }

  getAllPosts() async {
    List<Post> userPosts =
        await DatabaseMethods.getUserPosts(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _allPosts = userPosts;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllPosts();
    getPostsCount();
    getCullCount();
    getFollowingStatus();
    getFollowersCount();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isOwnProfilePage
            ? IconButton(
                onPressed: () {
                  Authenticator().signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.logout),
                color: Colors.black)
            : IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back)),
        title: Text('Profile Page'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          _isOwnProfilePage
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(
                          currentUserId: widget.currentUserId,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.notifications),
                  color: Colors.black,
                  iconSize: 35,
                )
              : Container()
        ],
      ),
      body: FutureBuilder<UserModel>(
          future: UserRepository.getUser(widget.visitedUserId),
          builder: (context, snapshot) {
            final userModel = snapshot.data;

            if (userModel == null) {
              return Container();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(userModel.photoUrl),
                        radius: _kAvatarRadius,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(_postsCount, 'posts'),
                                buildStatColumn(_followersCount, 'followers'),
                                buildStatColumn(_cullsCount, 'culls'),
                              ],
                            ),
                            _isOwnProfilePage
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FollowButton(
                                        text: 'Edit Profile',
                                        backgroundColor: Colors.black,
                                        textColor: primaryColor,
                                        borderColor: Colors.grey,
                                        function: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfileScreen(
                                                      user: userModel),
                                            ),
                                          );
                                          setState(() {});
                                        },
                                      )
                                    ],
                                  )
                                : isFollowing
                                    ? FollowButton(
                                        text: 'Unfollow',
                                        backgroundColor: Colors.white,
                                        textColor: Colors.black,
                                        borderColor: Colors.grey,
                                        function: () {
                                          DatabaseMethods().unFollowUser(
                                            widget.visitedUserId,
                                          );
                                          setState(() {
                                            isFollowing = false;
                                            _followersCount--;
                                          });
                                        },
                                      )
                                    : FollowButton(
                                        text: 'Follow',
                                        backgroundColor: Colors.blue,
                                        textColor: Colors.white,
                                        borderColor: Colors.blue,
                                        function: () {
                                          DatabaseMethods().followUser(
                                            widget.visitedUserId,
                                          );
                                          setState(() {
                                            isFollowing = true;
                                            _followersCount++;
                                          });
                                        },
                                      )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 1),
                    child: Text(
                      userModel.username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 1),
                    child: Text(userModel.bio),
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
                showProfilePosts(
                  userModel,
                ),
              ],
            );
          }),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
