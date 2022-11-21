// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:squirrel_main/models/user.dart';
// import 'package:squirrel_main/repositories/user_repository.dart';

// class UserContainer extends StatefulWidget {
//   final String currentUserId;
//   const UserContainer({super.key, required this.currentUserId});

//   @override
//   State<UserContainer> createState() => _UserContainerState();
// }

// class _UserContainerState extends State<UserContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<UserModel>(
//       future: UserRepository.getUser(widget.currentUserId),
//       builder: (context, snapshot) {
//         final userModel = snapshot.data;

//         if (userModel == null) {
//           return Container();
//         }

//         return GestureDetector(
//           child: Container(
//             onTap: () {
//               // String roomId = chatRoomId(widget.currentUserId, userMap!['uid']);
        
//               // Navigator.of(context).push(
//               //   MaterialPageRoute(
//               //     builder: (_) => ChatRoom(
//               //       chatRoomId: roomId,
//               //       userMap: userMap!,
//               //     ),
//               //   ),
//               // );
//             },
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(userModel.photoUrl),
//             ),
//             title: Text(
//               userModel.username,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             subtitle: Text(''),
//           ),
//         );
//       },
//     );
//   }
// }
