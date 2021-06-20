import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:lottie/lottie.dart';
import 'package:unicamp/screens/profile/profile.dart';
import 'package:unicamp/services/chat_service.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

String _myName;

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchTextEditingController =
      new TextEditingController();
  ChatService chatService = new ChatService();

  QuerySnapshot searchSnapshot;
  //String userId;

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return searchTile(
                  username: searchSnapshot.docs[index].data()["username"],
                  email: searchSnapshot.docs[index].data()["email"],
                  photoLink: searchSnapshot.docs[index].data()["photoLink"],
                  userId: searchSnapshot.docs[index].data()["uid"]);
            })
        : Expanded(
            flex: 2,
            child: Center(
              child: Lottie.asset('assets/images/search.json'),
            ),
          );
  }

  // findUserId(String userId){
  //   return searchSnapshot != null ?
  //   String userId = searchSnapshot.docs[index].data()
  // }

  initiateSearch() {
    if (searchTextEditingController.text.isNotEmpty) {
      chatService
          .getUserByUsername(searchTextEditingController.text)
          .then((val) {
        setState(() {
          searchSnapshot = val;
        });
      });
    }
  }

  ///// Kullanıcıyı mesajlasma sayfasına gonderme islemleri
 

  Widget searchTile(
      {String username, String email, String photoLink, String userId}) {
    return FadeIn(
        duration: Duration(milliseconds: 500),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(photoLink),
          ),
          onTap: () {
           
            goToUserProfile(context, userProfileId: userId, username: username );
          },
          tileColor: mainColor2,
          subtitle: Text(
            email,
            style: TextStyle(color: Colors.white),
          ),
          title: Text(
            username,
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  goToUserProfile(BuildContext context, {String userProfileId, String username}) {

      Navigator.push(
      context,
      SlideRightRoute(
        page: ProfilePage(
           userProfileId: userProfileId, username: username
        ),
      ),
    );

   
    print(userProfileId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Kişi Ara",
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            centerTitle: true,
            backgroundColor: mainColor,
            elevation: 0.0,
          ),
          body: Container(
            color: mainColor,
            child: Column(
              children: [
                Container(
                  margin: context.paddingMedium,
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: searchTextEditingController,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            hintText: 'Kullanıcı adı yazın.',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                            filled: true,
                            fillColor: mainColor2,
                            border: InputBorder.none),
                      )),
                      IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            initiateSearch();
                          })
                    ],
                  ),
                ),
                searchList()
              ],
            ),
          ),
        ),
      ),
    );
  }
}



getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b ";
  }
}
