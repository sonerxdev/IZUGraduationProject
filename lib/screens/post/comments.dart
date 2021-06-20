import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/selector.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:timeago/timeago.dart' as tAgo;

class CommentPage extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  final String postImageUrl;
  CommentPage({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  _CommentPageState createState() => _CommentPageState(
      postId: postId, postOwnerId: postOwnerId, postImageUrl: postImageUrl);
}

class _CommentPageState extends State<CommentPage> {
  final String postId;
  final String postOwnerId;

  final String postImageUrl;
  _CommentPageState({this.postId, this.postOwnerId, this.postImageUrl});

  TextEditingController commentTexEditingController = TextEditingController();

  retrieveComment() {
    return StreamBuilder(
        stream: commentReference
            .doc(postId)
            .collection("comments")
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(
              child: circularProgressWidget(),
            );
          }

          List<Comment> comments = [];
          dataSnapshot.data.docs.forEach((document) {
            comments.add(Comment.fromDocument(document));
          });
          return ListView(
            children: comments,
          );
        });
  }

  saveComment() {
    commentReference.doc(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentTexEditingController.text,
      "timestamp": DateTime.now(),
      "url": currentUser.photoLink,
      "userId": currentUser.uid,
    });

    bool isNotPostOwner = postOwnerId != currentUser.uid;
    if (isNotPostOwner) {
      activityReference.doc(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentData": commentTexEditingController.text,
        "postId": postId,
        "userId": currentUser.uid,
        "username": currentUser.username,
        "userProfileImg": currentUser.photoLink,
        "url": postImageUrl,
        "timestamp": DateTime.now(),
      });
    }
    commentTexEditingController.clear();

    SnackBar snackBar = SnackBar(
      content: Text(
        "Yorum kaydedildi.",
        style: TextStyle(
            color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
      ),
      backgroundColor: secondColor,
      duration: Duration(milliseconds: 3000),
      elevation: 20.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          title: Text(
            "Yorumlar",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: retrieveComment(),
            ),
            Divider(),
            ListTile(
              title: TextFormField(
                controller: commentTexEditingController,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    hintText: 'Yorum yazın.',
                    hintStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                    filled: true,
                    fillColor: mainColor2,
                    border: InputBorder.none),
                style: TextStyle(color: Colors.white),
              ),
              trailing: OutlinedButton(
                onPressed: saveComment,
                child: Text(
                  "Kaydet",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.username, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot["username"],
      userId: documentSnapshot["userId"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: mainColor2,
        child: Column(
          children: [
            ListTile(
              title: Text(
                username + ":  " + comment,
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(
                tAgo.format(timestamp.toDate()),
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
