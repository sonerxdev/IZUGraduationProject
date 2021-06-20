import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/services/chat_service.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';

class ConversationPage extends StatefulWidget {
  final String chatRoomId;

  const ConversationPage({Key key, this.chatRoomId}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  TextEditingController messageController = new TextEditingController();

  ChatService chatService = new ChatService();

  Stream chatMessagesStream;

  ScrollController _scrollController;

  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Center(
                child: circularProgressWidget(),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    snapshot.data.docs[index].data()["message"],
                    snapshot.data.docs[index].data()["sendBy"] ==
                        Constants.myName,
                  );
                },
              );
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      chatService.addConversationMessages(widget.chatRoomId, messageMap);
      messageController.text = "";
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    chatService.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessagesStream = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: Duration(milliseconds: 300),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.chatRoomId
                .toString()
                .replaceAll("_", "")
                .replaceAll(Constants.myName, ""),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 20.0,
            ),
          ),
          backgroundColor: mainColor2,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            color: mainColor,
            child: Column(
              children: [
                Expanded(child: ChatMessageList()),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: mainColor,
                    child: Container(
                      margin: context.paddingLow,
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: messageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40))),
                                hintText: 'Bir mesaj yazın.',
                                hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                                filled: true,
                                fillColor: mainColor2,
                                border: InputBorder.none),
                          )),
                          IconButton(
                              icon: Icon(
                                Icons.send_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                sendMessage();
                                _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeIn);
                                messageController.text = '';
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: Duration(milliseconds: 300),
      child: Container(
        padding: context.paddingLow,
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: isSendByMe ? Colors.blueGrey : Colors.indigoAccent,
            borderRadius: isSendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23),
                  ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
