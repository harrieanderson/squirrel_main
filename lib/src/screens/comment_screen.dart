import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/services/firestore_methods.dart';
import 'package:squirrel_main/src/widgets/comment_container.dart';
import 'package:squirrel_main/src/widgets/post_container.dart';
import 'package:squirrel_main/models/comment.dart';
import 'package:squirrel_main/utils/constant.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final UserModel author;
  final String currentUserId;

  const CommentsScreen(
      {super.key,
      required this.currentUserId,
      required this.post,
      required this.author});
  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<Comment> _comments = [];

  final TextEditingController _commentController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  // showPostComments(UserModel commentAuthor) {
  //   return Expanded(
  //     child: ListView.builder(
  //         shrinkWrap: true,
  //         physics: BouncingScrollPhysics(),
  //         itemCount: _comments.length,
  //         itemBuilder: (context, index) {
  //           return CommentContainer(
  //               currentUserId: widget.currentUserId, post: widget.post);
  //         }),
  //   );
  // }

  showPost() {
    return PostContainer(
        currentUserId: widget.currentUserId,
        post: widget.post,
        author: widget.author);
  }

  showComments() {
    return StreamBuilder(
        stream: commentsRef
            .doc(widget.post.id)
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: ((context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: ((context, index) => CommentContainer(
                  currentUserId: widget.currentUserId,
                  snap: snapshot.data!.docs[index].data(),
                )),
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('comment screen'),
      ),
      body: Column(
        children: [
          showPost(),
          showComments(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 55,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: EdgeInsets.only(left: 16, right: 8),
          child: FutureBuilder<UserModel>(
              future: UserRepository.getUser(widget.currentUserId),
              builder: (context, snapshot) {
                final userModel = snapshot.data;

                if (userModel == null) {
                  return Container();
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(userModel.photoUrl),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await FirestoreMethods().postComment(
                            widget.post.id,
                            _commentController.text,
                            userModel.uid,
                            userModel.username,
                            userModel.photoUrl);
                        _commentController.clear();
                        print(' the post ID is $widget.post.id');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Text(
                          'Post',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
