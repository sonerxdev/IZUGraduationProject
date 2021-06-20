import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:unicamp/model/user.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/post/post_page.dart';
import 'package:unicamp/screens/selector.dart';
import 'package:unicamp/services/auth.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';
import 'package:unicamp/shared/postUnit.dart';

class HomePage extends StatefulWidget {
  final User1 gCurrentUser;
  HomePage({this.gCurrentUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PostWidget> posts;
  List<String> followingsList = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(40.0),
    topRight: Radius.circular(40.0),
  );
  AuthService service = new AuthService();
  PanelController _pc = new PanelController();
  double _panelHeightClosed = 0.0;
  AuthService authService = new AuthService();

  getTimelinePosts() async {
    QuerySnapshot querySnapshot = await timelineReference
        .doc(widget.gCurrentUser.uid)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .get();

    List<PostWidget> allPosts = querySnapshot.docs
        .map((document) => PostWidget.fromDocument(document))
        .toList();

    setState(() {
      this.posts = allPosts;
    });
  }

  getFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .doc(currentUser.uid)
        .collection("userFollowing")
        .get();

    setState(() {
      followingsList =
          querySnapshot.docs.map((document) => document.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getTimelinePosts();
    getFollowings();
  }

  createUserTimeline() {
    if (posts == null) {
      return Center(
        child: circularProgressWidget(),
      );
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: mainColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: mainColor,
              elevation: 0.0,
              title: Container(
                height: context.dynamicHeight(0.3),
                width: context.dynamicWidth(0.3),
                child: Center(
                  child: Lottie.asset('assets/images/1.json'),
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                    icon: Icon(Icons.add_comment_rounded),
                    onPressed: () {
                      setState(() {
                        authService.userInfo();
                        _pc.open();
                      });
                    })
              ],
            )
          ];
        },
        body: SlidingUpPanel(
            controller: _pc,
            minHeight: _panelHeightClosed,
            borderRadius: radius,
            backdropEnabled: true,
            backdropTapClosesPanel: true,
            panel: currentUser != null
                ? PostPage(
                    gCurrentUser: currentUser,
                  )
                : Center(
                    child: circularProgressWidget(),
                  ),
            body: RefreshIndicator(
              child: createUserTimeline(),
              onRefresh: () => getTimelinePosts(),
            )),
      ),
    );
  }
}
