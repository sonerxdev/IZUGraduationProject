import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unicamp/model/user.dart';
import 'package:unicamp/services/database.dart';
  final FirebaseAuth auth = FirebaseAuth.instance;

class AuthService {
  //firebase auth nesnesi
  User1 currentUser;

  userInfo() async {
    print("calisiyor fonks");
   final User gcurrentUser = auth.currentUser;
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(gcurrentUser.uid).get();

    if (!documentSnapshot.exists) {
      print("veri yok aga");
    }
    return currentUser = User1.fromDocument(documentSnapshot);
  }

  

  //user1 classına göre user nesnesi. Model/user.dart a bağlı.
  User1 _userFromFirebaseUser(User user) {
    return user != null ? User1(uid: user.uid) : null;
  }

  Future registerFunction(
      String name,
      String username,
      String email,
      String password,
      String university,
      String linkedinLink,
      String bio,
      String photoLink) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      //her kullanıcı kaydında kullanıcıya göre otomatik belge oluşturulur.
      await DatabaseService(uid: user.uid).saveUserDatatoFirestore(name, username, email,
          password, university, linkedinLink, bio, photoLink);


      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future loginFunction(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}

