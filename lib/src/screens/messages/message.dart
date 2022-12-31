import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/helperfunctions/sharedpref_helper.dart';
import 'package:squirrel_main/src/screens/messages/chatscreen.dart';
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
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

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

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? userMap;

    return Scaffold(
      appBar: AppBar(
        title: Text("Messages Screen"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search users",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                    },
                  ),
                ),
                controller: searchController,
                onChanged: (value) {
                  // Clear the map of users
                  userMap!.clear();

                  // Search for users inside the "usersRef" collection
                  usersRef
                      .where("username", isGreaterThanOrEqualTo: value)
                      .get()
                      .then(
                    (querySnapshot) {
                      for (var doc in querySnapshot.docs) {
                        userMap![doc.id] = doc.data();
                      }
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.get().asStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                List<Map<String, dynamic>> userMaps = documents
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                if (userMaps.isNotEmpty) {
                  return ListView.builder(
                    itemCount: userMaps.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> user = userMaps[index];
                      userMap = user;

                      return ListTile(
                        onTap: () {
                          String roomId =
                              chatRoomId(widget.currentUserId, user['uid']);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: roomId,
                                userMap: user,
                              ),
                            ),
                          );
                        },
                        leading: user['photoUrl'] != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(user['photoUrl']),
                              )
                            : null,
                        title: Text(
                          user['username'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(user['email']),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No users found"));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
