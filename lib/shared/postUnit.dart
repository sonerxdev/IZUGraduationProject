import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:lottie/lottie.dart';
import 'package:unicamp/model/user.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/post/comments.dart';
import 'package:unicamp/screens/profile/profile.dart';
import 'package:unicamp/screens/selector.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';

class PostWidget extends StatefulWidget {
  final String postId;
  final String ownerId;

  final dynamic likes;

  final String username;

  final String description;

  final String url;

  PostWidget({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.url,
  });

  factory PostWidget.fromDocument(DocumentSnapshot documentSnapshot) {
    return PostWidget(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      url: documentSnapshot["url"],
    );
  }

  int getLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int counter = 0;
    likes.values.forEach((eachvalue) {
      if (eachvalue == true) {
        counter = counter + 1;
      }
    });

    return counter;
  }

  @override
  _PostWidgetState createState() => _PostWidgetState(
      postId: this.postId,
      ownerId: this.ownerId,
      likes: this.likes,
      username: this.username,
      description: this.description,
      url: this.url,
      likeCount: getLikes(this.likes));
}

class _PostWidgetState extends State<PostWidget> {
  final String postId;
  final String ownerId;

  Map likes;

  final String username;

  final String description;

  final String url;
  int likeCount;
  bool isLiked;
  bool showEmoji = false;
  final String currentOnlineUserId = currentUser?.uid;

  bool showPhoto = true;

  _PostWidgetState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.url,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return FadeIn(
      duration: Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.doc(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Center(
            child: circularProgressWidget(),
          );
        }

        User1 user = User1.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoLink),
            backgroundColor: Colors.grey,
          ),
          tileColor: mainColor,
          title: GestureDetector(
            onTap: () => goToUserProfile(context, userProfileId: user.uid),
            child: Text(
              user.username,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            ),
          ),
          //subtitle: Text("deneme mesajı"),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () => postDelete(context),
                )
              : Text(""),
        );
      },
    );
  }

  removerUserPost() async {
    postReference
        .doc(ownerId)
        .collection("usersPosts")
        .doc(postId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    storageReference.child("post_$postId.jpg").delete();

    QuerySnapshot querySnapshot = await activityReference
        .doc(ownerId)
        .collection("feedItems")
        .where("postId", isEqualTo: postId)
        .get();

    querySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    QuerySnapshot commentQuerySnapshot =
        await commentReference.doc(postId).collection("comments").get();

    commentQuerySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    SnackBar snackBar = SnackBar(
      content: Text(
        "Gönderi başarıyla silindi.",
        style: TextStyle(
            color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
      ),
      backgroundColor: secondColor,
      duration: Duration(milliseconds: 2000),
      elevation: 20.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  postDelete(BuildContext mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: mainColor,
            title: Text(
              "Gönderi silinsin mi?",
              style:
                  TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Sil",
                  style: TextStyle(
                      fontWeight: FontWeight.w300, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  removerUserPost();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  "İptal",
                  style: TextStyle(
                      fontWeight: FontWeight.w300, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  goToUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
      context,
      SlideRightRoute(
        page: ProfilePage(
          userProfileId: userProfileId,
        ),
      ),
    );

    print(userProfileId);
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityReference
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityReference.doc(ownerId).collection("feedItems").doc(postId).set({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.uid,
        "timestamp": DateTime.now(),
        "url": url,
        "userProfileImg": currentUser.photoLink
      });
    } else {}
  }

  checkUserLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;
    if (_liked) {
      postReference
          .doc(ownerId)
          .collection("usersPosts")
          .doc(postId)
          .update({"likes.$currentOnlineUserId": false});
      removeLike();
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });

      SnackBar snackBar = SnackBar(
        content: Text(
          "Beğenilmekten vazgeçildi.",
          style: TextStyle(
              color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
        ),
        backgroundColor: secondColor,
        duration: Duration(milliseconds: 2000),
        elevation: 20.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (!_liked) {
      postReference
          .doc(ownerId)
          .collection("usersPosts")
          .doc(postId)
          .update({"likes.$currentOnlineUserId": true});
      addLike();
      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showEmoji = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showEmoji = false;
        });
      });

      SnackBar snackBar = SnackBar(
        content: Text(
          "Gönderi beğenildi.",
          style: TextStyle(
              color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
        ),
        backgroundColor: secondColor,
        duration: Duration(milliseconds: 2000),
        elevation: 20.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => checkUserLikePost(),
      onTap: () {
        setState(() {
          showPhoto = false;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          showPhoto
              ? Stack(children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                              colors: [Colors.black45, Colors.black45],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter)
                          .createShader(rect);
                    },
                    blendMode: BlendMode.darken,
                    child: Image.network(url),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100.0),
                      child: Text(
                        "$description",
                        style: TextStyle(
                            fontSize: 46.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ])
              : Image.network(url),
          showEmoji
              ? FadeIn(
                  child: Center(
                    child: Lottie.asset('assets/images/like.json'),
                  ),
                )
              : Text("")
        ],
      ),
    );
  }

  createPostFooter() {
    return Padding(
      padding: context.paddingMedium,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => checkUserLikePost(),
                child: Icon(
                  isLiked ? Icons.star : Icons.star_border,
                  size: 28.0,
                  color: Colors.yellow,
                ),
              ),
              SizedBox(
                width: context.dynamicWidth(0.03),
              ),
              GestureDetector(
                onTap: () => goToCommentPage(context,
                    postId: postId, ownerId: ownerId, url: url),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: context.dynamicWidth(0.03),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                margin: context.paddingVertical,
                child: Text(
                  "$likeCount beğeni",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
              )
            ],
          ),
          SizedBox(
            width: context.dynamicWidth(0.03),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // margin: context.paddingVertical,
                child: Text(
                  "$username",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: context.dynamicWidth(0.03),
              ),
              Text(
                "$description",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              )
            ],
          )
        ],
      ),
    );
  }

  goToCommentPage(BuildContext context,
      {String postId, String ownerId, String url}) {
    Navigator.push(
      context,
      SlideRightRoute(
        page: CommentPage(
            postId: postId, postOwnerId: ownerId, postImageUrl: url),
      ),
    );
  }
}
