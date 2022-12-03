import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/helperfunctions/sharedpref_helper.dart';
import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/repositories/user_repository.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/src/screens/messages/chatscreen.dart';
import 'package:squirrel_main/src/widgets/user_container.dart';
import 'package:squirrel_main/utils/constant.dart';

class MessagesScreen extends StatefulWidget {
  final String currentUserId;

  const MessagesScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  List<UserModel> _usersToMessage = [];
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  // creates chatRoomId
  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await firestore
        .collection('users')
        .where("username", isGreaterThanOrEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  clearSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _search.clear());
    setState(() {
      _search.text = '';
    });
  }

  setUpUsersToMessage() async {
    List<UserModel> usersToMessage =
        await DatabaseMethods.getFollowersToMessage(widget.currentUserId);
    if (mounted) {
      setState(() {
        _usersToMessage = usersToMessage;
      });
    }
  }

  showUsers() {
    return StreamBuilder(
        stream: commentsRef
            .doc(widget.currentUserId)
            .collection('followers')
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
            itemBuilder: ((context, index) => ListTile(
                  onTap: () {
                    String roomId =
                        chatRoomId(widget.currentUserId, userMap!['uid']);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoom(
                          chatRoomId: roomId,
                          userMap: userMap!,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userMap!['photoUrl']),
                  ),
                  title: Text(
                    userMap!['username'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(userMap!['email']),
                )),
          );
        }));
  }

  userTile() {
    return ListTile(
      onTap: () {
        String roomId = chatRoomId(widget.currentUserId, userMap!['uid']);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoom(
              chatRoomId: roomId,
              userMap: userMap!,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userMap!['photoUrl']),
      ),
      title: Text(
        userMap!['username'],
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(userMap!['email']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Screen"),
        actions: const [],
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : FutureBuilder<UserModel>(
              future: UserRepository.getUser(widget.currentUserId),
              builder: (context, snapshot) {
                final userModel = snapshot.data;
                if (userModel == null) {
                  return Container();
                }
                return ListView(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: size.height / 20,
                        ),
                        Container(
                          height: size.height / 14,
                          width: size.width,
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: size.height / 14,
                            width: size.width / 1.15,
                            child: TextField(
                              controller: _search,
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    clearSearch();
                                  },
                                  icon: Icon(Icons.clear),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 50,
                        ),
                        ElevatedButton(
                          onPressed: onSearch,
                          child: Text("Search"),
                        ),
                        SizedBox(
                          height: size.height / 30,
                        ),
                        userMap != null ? showUsers() : Container()
                      ],
                    ),
                  ],
                );
              }),
    );
  }
}
