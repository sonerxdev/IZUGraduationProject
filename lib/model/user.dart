import 'package:cloud_firestore/cloud_firestore.dart';

class User1 {
  final String bio;
  final String email;
  final String linkedinLink;
  final String name;
  final String password;
  final String photoLink;
  final String uid;
  final String university;
  final String username;

  User1({
    this.bio,
    this.email,
    this.linkedinLink,
    this.name,
    this.password,
    this.photoLink,
    this.uid,
    this.university,
    this.username,
  });

  factory User1.fromDocument(DocumentSnapshot docx) {
    return User1(
      bio: docx['bio'],
      email: docx['email'],
      linkedinLink: docx['linkedinLink'],
      name: docx['name'],
      password: docx['password'],
      photoLink: docx['photoLink'],
      uid: docx.id,
      university: docx['university'],
      username: docx['username'],
    );
  }
}
