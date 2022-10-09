// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squirrel_main/models/post.dart';

import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/services/firestore_methods.dart';
import 'package:squirrel_main/services/storage_methods.dart';
import 'package:squirrel_main/utils/utils.dart';
import 'package:uuid/uuid.dart';

class AddPostScreen extends StatefulWidget {
  final String uid;
  const AddPostScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  late var _isLoggedOnUser =
      userModel!.uid == FirebaseAuth.instance.currentUser;
  Uint8List? _file;
  bool _isLoading = false;
  UserModel? userModel;

  late String _postText;

  void selectImage() async {
    Uint8List file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
    });
  }

  void clearImage() {
    setState(() {
      _file == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a post'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),
        actions: [
          IconButton(
              constraints: BoxConstraints.expand(
                width: 50,
              ),
              icon: Text(
                'Post',
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                setState(() {});

                if (_postText.isNotEmpty) {
                  String image;
                  if (_file == null) {
                    image = '';
                  } else {
                    image = await StorageMethods()
                        .uploadImageToStorage('posts', _file!, true);
                    showSnackBar(
                      context,
                      'posted!',
                    );
                  }
                  String postId = const Uuid().v1();
                  Post post = Post(
                    authorId: widget.uid,
                    text: _postText,
                    image: image,
                    timestamp: Timestamp.fromDate(DateTime.now()),
                    likes: 0,
                    id: postId,
                  );
                  showSnackBar(context, 'posted!');
                  DatabaseMethods.createPost(post);
                  Navigator.pop(context);
                }
                setState(() {
                  _isLoading = false;
                });
              }),
          SizedBox(
            height: 20,
          ),
          _isLoading ? CircularProgressIndicator() : SizedBox.shrink()
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: FutureBuilder<UserModel>(
              future: UserRepository.getUser(widget.uid),
              builder: (context, snapshot) {
                final userModel = snapshot.data;
                if (userModel == null) {
                  return Container();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          userModel.photoUrl,
                        ),
                      ),
                    ),
                    Text(
                      userModel.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "What's happening?",
              suffixIcon: GestureDetector(
                onTap: () => selectImage(),
                child: Icon(
                  Icons.image,
                ),
              ),
            ),
            onChanged: (value) {
              _postText = value;
            },
          ),
          SizedBox(
            height: 3,
          ),
          _file == null
              ? Container()
              : Column(
                  children: [
                    Container(
                      height: 200,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.memory(_file!),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
