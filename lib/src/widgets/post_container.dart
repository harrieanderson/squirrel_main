// ignore_for_file: file_names

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/services/firestore_methods.dart';
import 'package:squirrel_main/src/screens/comment_screen.dart';
import 'package:squirrel_main/src/screens/profile_page.dart';
import 'package:squirrel_main/utils/constant.dart';
import 'package:squirrel_main/utils/utils.dart';

class PostContainer extends StatefulWidget {
  final Post post;
  final UserModel author;
  final String currentUserId;
  const PostContainer(
      {Key? key,
      required this.post,
      required this.author,
      required this.currentUserId})
      : super(key: key);

  @override
  State<PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  int _likesCount = 0;
  bool _isLiked = false;
  int _commentsCount = 0;

  getCommentCount() async {
    int commentsCount = await DatabaseMethods.commentsNum(widget.post.id);
    if (mounted) {
      setState(() {
        _commentsCount = commentsCount;
      });
    }
  }

  initPostLikes() async {
    bool isLiked =
        await DatabaseMethods.isLikePost(widget.currentUserId, widget.post);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  likePost() {
    if (_isLiked) {
      setState(() {
        _isLiked = false;
        _likesCount--;
      });
    } else {
      DatabaseMethods.likePost(widget.currentUserId, widget.post);
      setState(() {
        _isLiked = true;
        _likesCount++;
      });
    }
  }

  deletePost(String postId, String userId) async {
    try {
      await FirestoreMethods().deletePost(postId, userId);
    } catch (err) {
      showSnackBar(context, err.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likes;
    initPostLikes();
    getCommentCount();
  }

  goToProfilePage(UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePageUi(
              currentUserId: widget.currentUserId,
              visitedUserId: user.uid,
            ),
          ),
        );
      },
      child: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(user.photoUrl),
      ),
    );
  }

  goToProfilePageText(UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePageUi(
              currentUserId: widget.currentUserId,
              visitedUserId: user.uid,
            ),
          ),
        );
      },
      child: Text(
        widget.author.username,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              goToProfilePage(widget.author),
              Row(
                children: [
                  Column(
                    children: [
                      goToProfilePageText(widget.author),
                      Text(
                        ' ' +
                            widget.post.timestamp
                                .toDate()
                                .toString()
                                .substring(0, 16),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentsScreen(
                  author: widget.author,
                  post: widget.post,
                  currentUserId: widget.currentUserId,
                ),
              ),
            ),
            child: Text(
              widget.post.text,
            ),
          ),
          widget.post.image.isEmpty
              ? SizedBox.shrink()
              : Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.post.image),
                        ),
                      ),
                    )
                  ],
                ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: likePost,
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.blue : Colors.black,
                    ),
                  ),
                  Text(
                    _likesCount.toString() + ' Likes',
                  ),
                ],
              ),
              FutureBuilder<UserModel>(
                  future: UserRepository.getUser(widget.currentUserId),
                  builder: (context, snapshot) {
                    final userModel = snapshot.data;
                    if (userModel == null) {
                      return Container();
                    }

                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            author: widget.author,
                            post: widget.post,
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.comment),
                          Text('View all $_commentsCount comments')
                        ],
                      ),
                    );
                  }),
            ],
          ),
          Divider(
            thickness: 5,
          )
        ],
      ),
    );
  }
}
