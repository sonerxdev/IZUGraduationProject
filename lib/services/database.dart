import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final usersReference = FirebaseFirestore.instance.collection("users");
final Reference storageReference =
    FirebaseStorage.instance.ref().child("Post Pictures");
final postReference = FirebaseFirestore.instance.collection("posts");
final activityReference = FirebaseFirestore.instance.collection("feed");
final commentReference = FirebaseFirestore.instance.collection("comment");
final followersReference = FirebaseFirestore.instance.collection("followers");
final followingReference = FirebaseFirestore.instance.collection("following");
final timelineReference = FirebaseFirestore.instance.collection("timeline");

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  Future saveUserDatatoFirestore(
    String name,
    String username,
    String email,
    String password,
    String university,
    String linkedinLink,
    String bio,
    String photoLink,
  ) async {
    return await usersReference.doc(uid).set({
      "name": name,
      "username": username,
      "email": email,
      "password": password,
      "university": university,
      "linkedinLink": linkedinLink,
      "bio": bio,
      "photoLink": photoLink,
      'uid': uid,
    });
  }

}
