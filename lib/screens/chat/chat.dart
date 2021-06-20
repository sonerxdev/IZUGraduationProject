import 'package:flutter/material.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/chat/conversation_page.dart';
import 'package:unicamp/screens/search/search.dart';
import 'package:unicamp/services/chat_service.dart';
import 'package:unicamp/services/helper.dart';

import 'package:unicamp/shared/constants.dart';

class ChattingPage extends StatefulWidget {
  ChattingPage({Key key}) : super(key: key);

  @override
  _ChattingPageState createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  ChatService chatService = new ChatService();
  Stream chatRoomStream;

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(
                  child: circularProgressWidget(),
                )
              : ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return ChatRoomTile(
                      snapshot.data.docs[index]
                          .data()["chatRoomId"]
                          .toString()
                          .replaceAll("_", "")
                          .replaceAll(Constants.myName, ""),
                      snapshot.data.docs[index].data()["chatRoomId"],
                    );
                  });
        });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelpFunctions.getUserName();
    chatService.getChatRooms(Constants.myName).then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: mainColor,
              elevation: 0.0,
              title: Text(
                "Sohbet",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              centerTitle: true,
            )
          ];
        },
        body: chatRoomList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            FadeInRoute(
              page: SearchPage(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: mainColor2,
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final String username;
  final String chatRoomId;

  ChatRoomTile(this.username, this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          SlideRightRoute(
            page: ConversationPage(
              chatRoomId: chatRoomId,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        child: Text(
          "${username.substring(0, 1).toUpperCase()}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      title: Text(
        username,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
