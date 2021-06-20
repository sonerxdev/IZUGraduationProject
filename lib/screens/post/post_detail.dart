import 'package:flutter/material.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/postUnit.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;
  final String userId;

  PostDetailPage({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postReference
            .doc(userId)
            .collection("usersPosts")
            .doc(postId)
            .get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(
              child: circularProgressWidget(),
            );
          }
          PostWidget post = PostWidget.fromDocument(dataSnapshot.data);
          return Center(
            child: Scaffold(
              backgroundColor: mainColor,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: mainColor,
                elevation: 0.0,
                title: Text(
                  post.description,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
              ),
              body: ListView(
                children: [
                  Container(
                    color: mainColor,
                    child: post,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
