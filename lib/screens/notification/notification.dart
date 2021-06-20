import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/profile/profile.dart';
import 'package:unicamp/screens/selector.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:timeago/timeago.dart' as tAgo;

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: mainColor,
          title: Text(
            "Bildirimler",
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
          ),
        ),
        body: Container(
          child: FutureBuilder(
            future: getNotifications(),
            builder: (context, dataSnapshot) {
              if (!dataSnapshot.hasData) {
                return Center(
                  child: circularProgressWidget(),
                );
              }
              return ListView(
                children: dataSnapshot.data,
              );
            },
          ),
        ));
  }

  getNotifications() async {
    QuerySnapshot querySnapshot = await activityReference
        .doc(currentUser.uid)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(60)
        .get();

    List<NotificationsItem> notificationsItems = [];
    querySnapshot.docs.forEach((document) {
      notificationsItems.add(NotificationsItem.fromDocument(document));
    });

    return notificationsItems;
  }
}

String notificationItemText;
Widget mediaPreview;

class NotificationsItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;
  NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.postId,
      this.userId,
      this.userProfileImg,
      this.url,
      this.timestamp});

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
      username: documentSnapshot.data()["username"],
      type: documentSnapshot.data()["type"],
      commentData: documentSnapshot.data()["commentData"],
      postId: documentSnapshot.data()["postId"],
      userId: documentSnapshot.data()["userId"],
      userProfileImg: documentSnapshot.data()["userProfileImg"],
      url: documentSnapshot.data()["url"],
      timestamp: documentSnapshot.data()["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return FadeIn(
      duration: Duration(milliseconds: 500),
      child: Padding(
        padding: EdgeInsets.only(bottom: 2.0),
        child: Container(
          color: mainColor2,
          child: ListTile(
            title: GestureDetector(
              onTap: () => goToUserProfile(context, userProfileId: userId),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(text: " $notificationItemText"),
                    ]),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
            subtitle: Text(
              tAgo.format(
                timestamp.toDate(),
              ),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: mediaPreview,
          ),
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "comment" || type == "like") {
      mediaPreview = GestureDetector(
        onTap: () => displayOwnProfile(context, userProfileId: currentUser.uid),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(url),
              )),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == "like") {
      notificationItemText = "fotoğrafını beğendi.";
    } else if (type == "comment") {
      notificationItemText = "yanıtladı: $commentData";
    } else if (type == "follow") {
      notificationItemText = "seni takip etmeye başladı.";
    } else {
      notificationItemText = "Hata, bilinmeyen tür = $type ";
    }
  }

  displayOwnProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
      context,
      SlideRightRoute(
        page: ProfilePage(
          userProfileId: currentUser.uid,
        ),
      ),
    );

    print(userProfileId);
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
}
