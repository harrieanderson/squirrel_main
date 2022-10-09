// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:squirrel_main/src/screens/add_post_screen.dart';
import 'package:squirrel_main/src/screens/googlemaps/google_map_screen.dart';
import 'package:squirrel_main/src/screens/home_screen.dart';
import 'package:squirrel_main/src/screens/messages/message.dart';
import 'package:squirrel_main/src/screens/profile_page.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final screens = [
    HomeScreen(
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
    ),
    GoogleMapScreen(
        key: UniqueKey(), uid: FirebaseAuth.instance.currentUser!.uid),
    // Center(
    //   child: Text('3'),
    // ),
    MessagesScreen(),
    ProfilePageUi(
        visitedUserId: FirebaseAuth.instance.currentUser!.uid,
        currentUserId: FirebaseAuth.instance.currentUser!.uid)
  ];
  int current_index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: current_index == 0 || current_index == 3
          ? FloatingActionButton(
              heroTag: null,
              elevation: 3,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPostScreen(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: IconButton(
                    onPressed: () => _onItemTapped(0),
                    icon: Icon(Icons.home),
                    color: current_index == 0 ? Colors.red : null),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    _onItemTapped(1);
                  },
                  icon: Icon(Icons.fmd_good),
                  color: current_index == 1 ? Colors.red : null,
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 2,
                width: current_index == 0 ? 60 : 0,
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    _onItemTapped(2);
                  },
                  icon: Icon(Icons.message),
                  color: current_index == 2 ? Colors.red : null,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    _onItemTapped(3);
                  },
                  icon: Icon(Icons.person),
                  color: current_index == 3 ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        children: screens,
        index: current_index,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      current_index = index;
    });
  }
}
