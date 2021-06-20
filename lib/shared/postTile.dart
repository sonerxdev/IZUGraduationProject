import 'package:flutter/material.dart';
import 'package:unicamp/screens/post/post_detail.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/postUnit.dart';

class PostTile extends StatelessWidget {
  final PostWidget post;

  PostTile(this.post);

  displayPost(context) {

      Navigator.push(
      context,
      SlideRightRoute(
        page: PostDetailPage(postId: post.postId, userId: post.ownerId),
      ),
    );

    
   
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.network(
          post.url,
          // height: 200.0,
          fit: BoxFit.fitHeight,
        ),
      ),
      onTap: () => displayPost(context),
    );
  }
}
