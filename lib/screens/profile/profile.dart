import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unicamp/model/user.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/chat/conversation_page.dart';
import 'package:unicamp/screens/profile/edit_profile.dart';
import 'package:unicamp/screens/search/search.dart';
import 'package:unicamp/screens/selector.dart';
import 'package:unicamp/services/auth.dart';
import 'package:unicamp/services/chat_service.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/background_image_widget.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';
import 'package:unicamp/shared/postTile.dart';
import 'package:unicamp/shared/postUnit.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  final String username;
  ProfilePage({this.userProfileId, this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = new AuthService();

  final String currentOnlineUserId = currentUser?.uid;
  bool loading = false;
  int countPosts = 0;
  List<PostWidget> postLists = [];
  String postOrientation = "grid";
  int countTotalFollowers = 0;
  int countTotalFollowing = 0;
  String headerSchool = "";
  bool following = false;
  User1 user2;
  String linkedinUrl;

  @override
  void initState() {
    super.initState();
    setState(() {
      getProfilePosts();
      getFollowers();
      getFollowings();
      checkFollowing();
      getSchoolNameAndLinkedinUrl();
    });
  }

  getFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .get();

    setState(() {
      countTotalFollowers = querySnapshot.docs.length;
    });
  }

  getFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .doc(widget.userProfileId)
        .collection("userFollowing")
        .get();

    setState(() {
      countTotalFollowing = querySnapshot.docs.length;
    });
  }

  checkFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .doc(currentOnlineUserId)
        .get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  getSchoolNameAndLinkedinUrl() async {
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(widget.userProfileId).get();
    user2 = User1.fromDocument(documentSnapshot);

    setState(() {
      headerSchool = user2.university;
      linkedinUrl = user2.linkedinLink;
    });
  }

  void customLaunchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("$url   bulunamadı.");
    }
  }

  createProfileTopView() {
    return FutureBuilder(
        future: usersReference.doc(widget.userProfileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(
              child: circularProgressWidget(),
            );
          }

          User1 user = User1.fromDocument(dataSnapshot.data);

          return Padding(
            padding: context.paddingLow,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoLink),
                    ),
                    SizedBox(
                      width: context.dynamicWidth(0.05),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(
                          height: context.dynamicHeight(0.01),
                        ),
                        Text(
                          "@" + user.username,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(
                          height: context.dynamicHeight(0.02),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: dynamicButton(),
                            )
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
                SizedBox(
                  height: context.dynamicHeight(0.03),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: context.paddingVertical,
                  child: Text(
                    user.bio,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70),
                  ),
                )
              ],
            ),
          );
        });
  }

  Column userFollowDetailColumns(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  dynamicButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return globalButtonTitleandFunction(
          title: "Profili düzenle", performFunction: editProfile);
    } else if (following) {
      return globalButtonTitleandFunction(
          title: "Takibi Bırak", performFunction: unfollowUser);
    } else if (!following) {
      return globalButtonTitleandFunction(
          title: "Takip Et", performFunction: followUser);
    }
  }

  startMessaging(String username) {
    print("${Constants.myName}");
    if (username != Constants.myName) {
      String chatRoomId = getChatRoomId(username, Constants.myName);
      List<String> users = [username, Constants.myName];
      Map<String, dynamic> charRoomMap = {
        "users": users,
        "chatRoomId": chatRoomId
      };
      ChatService().createChatRoom(chatRoomId, charRoomMap);
      Navigator.push(
        context,
        SlideRightRoute(
          page: ConversationPage(
            chatRoomId: chatRoomId,
          ),
        ),
      );
      SnackBar snackBar = SnackBar(
        content: Text(
          "İlk mesajını gönder!",
          style: TextStyle(
              color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
        ),
        backgroundColor: secondColor,
        duration: Duration(milliseconds: 2000),
        elevation: 20.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      //buradan profile yol vericez.
      print("kendine mesaj atamazsin!");
    }
  }

  Row showMessageAndLinkedinButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;

    if (!ownProfile) {
      return Row(
        children: [
          SizedBox(
            width: context.dynamicWidth(0.03),
          ),
          Expanded(
            child: MaterialButton(
              onPressed: () {
                startMessaging(widget.username);
              },
              color: following ? secondColor : Colors.blue,
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 13,
              ),
              child: Text(
                "Mesaj",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: context.dynamicWidth(0.03),
          ),
          Expanded(
            child: MaterialButton(
              onPressed: () {
                customLaunchUrl(linkedinUrl);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              color: following ? Colors.blue : Colors.blue,
              minWidth: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 13,
              ),
              child: Text(
                "Linkedin",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: context.dynamicWidth(0.03),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          SizedBox(
            height: 0.0,
            width: 0.0,
          ),
        ],
      );
    }
  }

  unfollowUser() {
    setState(() {
      following = false;
    });

    followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .doc(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    followingReference
        .doc(currentOnlineUserId)
        .collection("userFollowing")
        .doc(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    activityReference
        .doc(widget.userProfileId)
        .collection("feedItems")
        .doc(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    SnackBar snackBar = SnackBar(
      content: Text(
        "Takibi bıraktın.",
        style: TextStyle(
            color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
      ),
      backgroundColor: secondColor,
      duration: Duration(milliseconds: 2000),
      elevation: 20.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  followUser() {
    setState(() {
      following = true;
    });

    followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .doc(currentOnlineUserId)
        .set({});

    followingReference
        .doc(currentOnlineUserId)
        .collection("userFollowing")
        .doc(widget.userProfileId)
        .set({});

    activityReference
        .doc(widget.userProfileId)
        .collection("feedItems")
        .doc(currentOnlineUserId)
        .set({
      "type": "follow",
      "owner": widget.userProfileId,
      "username": currentUser.username,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser.photoLink,
      "userId": currentOnlineUserId
    });

    SnackBar snackBar = SnackBar(
      content: Text(
        "Takip edildi.",
        style: TextStyle(
            color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
      ),
      backgroundColor: secondColor,
      duration: Duration(milliseconds: 2000),
      elevation: 20.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  globalButtonTitleandFunction({String title, Function performFunction}) {
    return Container(
      child: MaterialButton(
        onPressed: performFunction,
        color: following ? Colors.red : Colors.blue,
        minWidth: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 13,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
      context,
      SlideRightRoute(
        page: EditProfilePage(currentOnlineUserId: currentOnlineUserId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        BackgroundPageImage(
          imageLocation: 'assets/images/uni.jpg',
        ),
        Container(
          alignment: Alignment.topCenter,
          margin: context.paddingHigh,
          padding: EdgeInsets.only(top: 50.0),
          child: Text(
            headerSchool,
            style: TextStyle(
                fontSize: 30.0,
                color: Colors.white,
                fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: context.dynamicHeight(0.3),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: mainColor,
                ),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          createProfileTopView(),
                          SizedBox(
                            height: context.dynamicHeight(0.03),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              userFollowDetailColumns("Gönderi", countPosts),
                              userFollowDetailColumns("Takipçi", countTotalFollowers),
                              userFollowDetailColumns("Takip", countTotalFollowing),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: context.dynamicHeight(0.03),
                    ),
                    showMessageAndLinkedinButton(),
                    SizedBox(
                      height: context.dynamicHeight(0.01),
                    ),
                    createListandGridPostOrientation(),
                    displayProfilePost(),
                    SizedBox(
                      height: context.dynamicHeight(0.03),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  displayProfilePost() {
    if (loading) {
      return Center(
        child: circularProgressWidget(),
      );
    } else if (postLists.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: context.dynamicHeight(0.4),
            width: context.dynamicWidth(0.8),
            child: Center(
              child: Lottie.asset('assets/images/nopost.json'),
            ),
          ),
          Text(
            "Henüz gönderi yok.",
            style: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.w300),
          )
        ],
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTilesList = [];
      postLists.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(eachPost)));
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postLists,
      );
    }
  }

  //hata burda bu fonksiyon çalışmıyor.
  getProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postReference
        .doc(widget.userProfileId)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .get();

    setState(() {
      loading = false;
      countPosts = querySnapshot.docs.length;
      postLists = querySnapshot.docs
          .map((documentSnapshot) => PostWidget.fromDocument(documentSnapshot))
          .toList();
    });
  }

  createListandGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        )
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
