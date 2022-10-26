// ignore_for_file: file_names, unrelated_type_equality_checks

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/services/firestore_methods.dart';
import 'package:squirrel_main/src/screens/comment_screen.dart';
import 'package:squirrel_main/src/screens/profile/profile_page.dart';
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

  // buildLikes() {
  //   return StreamBuilder(
  //     stream: getLikesCount(),
  //     builder: ((context, snapshot) {
  //       if (snapshot.hasData) {} return
  //     }));
  // }

  Future<bool> getLikeStatus() async {
    DocumentSnapshot document = await likesRef
        .doc(widget.post.id)
        .collection('userLikes')
        .doc(widget.currentUserId)
        .get();

    if (document.exists) {
      _isLiked = document.exists;
      setState(() {
        _isLiked = document.exists;
      });
      return true;
    } else {
      _isLiked = document.exists;
      setState(() {
        _isLiked = document.exists;
      });
      return false;
    }
  }

  getLikesCount() async {
    int likesCount = await DatabaseMethods.likesNum(widget.post.id);
    if (mounted) {
      setState(() {
        _likesCount = likesCount;
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
    getCommentCount();
    getLikesCount();
    getLikeStatus();
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
                  if (widget.currentUserId == widget.author.uid)
                    IconButton(
                      onPressed: () {
                        showDialog(
                          useRootNavigator: false,
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  'Remove post?',
                                ]
                                    .map(
                                      (e) => InkWell(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            child: Text(e),
                                          ),
                                          onTap: () {
                                            deletePost(widget.post.id,
                                                widget.currentUserId);
                                            // remove the dialog box
                                            Navigator.of(context).pop();
                                          }),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.more_vert),
                    )
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
                    onPressed: () async {
                      FirestoreMethods().likePost(
                          widget.post.id,
                          widget.currentUserId,
                          widget.post.likes,
                          await getLikeStatus());
                      setState(() {
                        _isLiked == getLikeStatus();
                        _likesCount == getLikesCount();
                      });
                    },
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.blue : Colors.black,
                    ),
                  ),
                  Text(
                    ' $_likesCount Likes',
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
