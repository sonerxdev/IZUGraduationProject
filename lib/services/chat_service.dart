import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  getUserByUsername(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }

  getUserByUserEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
  }

 

  createChatRoom(String charRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(charRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addConversationMessages(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .collection("chatMessage")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .collection("chatMessage")
        .orderBy("time")
        .snapshots();
  }

  

  getChatRooms(String username) async {
    return await FirebaseFirestore.instance
        .collection("chats")
        .where(
          "users",
          arrayContains: username,
        )
        .snapshots();
  }
}
