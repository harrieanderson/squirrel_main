// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/services/storage_methods.dart';
import 'package:squirrel_main/utils/utils.dart';

const _kAvatarRadius = 45.0;
const _kAvatarPadding = 8.0;

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String _name;
  late String _bio;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Uint8List? _image;
  UserModel? userModel;

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  @override
  void initState() {
    super.initState();
    _name = widget.user.username;
    _bio = widget.user.bio;
  }

  saveProfile() async {
    print('pressed 2');
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
      String profilePictureUrl = '';
      if (_image == null) {
        profilePictureUrl = widget.user.photoUrl;
      } else {
        profilePictureUrl = await StorageMethods()
            .uploadImageToStorage('profilepics', _image!, false);
      }
      print('reached');
      UserModel user = UserModel(
          username: _name,
          firstName: widget.user.firstName,
          secondName: widget.user.secondName,
          uid: widget.user.uid,
          photoUrl: profilePictureUrl,
          email: widget.user.email,
          bio: _bio,
          friends: widget.user.friends,
          culls: widget.user.culls);
      DatabaseMethods.updateUserInfo(user);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit page'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(_kAvatarPadding),
                  child: Stack(
                    children: [
                      _image != null
                          ? GestureDetector(
                              onTap: () {
                                selectImage();
                              },
                              child: CircleAvatar(
                                radius: 45,
                                backgroundImage: MemoryImage(_image!),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                selectImage();
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundImage:
                                        NetworkImage(widget.user.photoUrl),
                                  ),
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.black54,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      widget.user.username,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(widget.user.bio)
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    saveProfile();
                  },
                  child: Container(
                    width: 100,
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    initialValue: widget.user.username,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.blue),
                    ),
                    validator: (input) =>
                        input!.trim().length < 2 ? 'Enter a valid name' : null,
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    initialValue: widget.user.bio,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      labelStyle: TextStyle(color: Colors.blue),
                    ),
                    onSaved: (value) {
                      _bio = value!;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Colors.blue,
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),
            )
          ],
        ));
  }
}
