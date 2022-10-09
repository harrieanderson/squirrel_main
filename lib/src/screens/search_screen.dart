// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:squirrel_main/models/user.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/src/screens/profile_page.dart';

class SearchScreen extends StatefulWidget {
  final String currentUserId;

  const SearchScreen({Key? key, required this.currentUserId}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchString = '';
  TextEditingController _searchController = TextEditingController();

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      searchString = '';
    });
  }

  buildUserTile(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(user.photoUrl),
      ),
      title: Text(user.username),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            hintText: 'Search Users...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                clearSearch();
              },
            ),
            filled: true,
          ),
          onChanged: (input) {
            if (input.isNotEmpty) {
              searchString = _searchController.text;
              setState(() {});
            }
          },
        ),
      ),
      body: searchString.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 200,
                  ),
                  Text(
                    'Search Users...',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<UserModel>>(
              future: DatabaseMethods.searchUsers(searchString),
              builder: (context, snapshot) {
                final list = snapshot.data;

                if (list == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (list.isEmpty) {
                  return Center(
                    child: Text('No users found'),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return buildUserTile(list[index]);
                  },
                );
              },
            ),
    );
  }
}
