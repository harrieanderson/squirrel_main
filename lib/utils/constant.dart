import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _fireStore = FirebaseFirestore.instance;

final usersRef = _fireStore.collection('users');

final friendsRef = _fireStore.collection('friends');

final storageRef = FirebaseStorage.instance.ref();

final postsRef = _fireStore.collection('posts');

final feedRefs = _fireStore.collection('feeds');

final likesRef = _fireStore.collection('likes');

final commentsRef = _fireStore.collection('comments');

final activitiesRef = _fireStore.collection('activities');

final cullsRef = _fireStore.collection('culls');

final sightingsRef = _fireStore.collection('sightings');
