import 'package:flutter/material.dart';
import 'package:squirrel_main/models/post.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:intl/intl.dart';
import '../../repositories/user_repository.dart';

class CommentContainer extends StatefulWidget {
  final snap;

  final String currentUserId;
  const CommentContainer({
    super.key,
    required this.currentUserId,
    required this.snap,
  });

  @override
  State<CommentContainer> createState() => _CommentContainerState();
}

class _CommentContainerState extends State<CommentContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9, horizontal: 7),
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
                backgroundImage: NetworkImage(widget.snap['profilePic']),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.snap['name'] + ' ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: widget.snap['text'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(
                          (widget.snap['datePublished'].toDate()),
                        ),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.favorite_outline),
              )
            ],
          );
        },
      ),
    );
  }
}
