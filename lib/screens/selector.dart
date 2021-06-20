
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicamp/model/user.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/chat/chat.dart';
import 'package:unicamp/screens/home/home.dart';
import 'package:unicamp/screens/notification/notification.dart';
import 'package:unicamp/screens/profile/profile.dart';
import 'package:unicamp/services/auth.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
User1 currentUser;

class SelectorPage extends StatefulWidget {
  SelectorPage({Key key}) : super(key: key);

  @override
  _SelectorPageState createState() => _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
  int _selectedIndex = 0;
  PageController _pageController;
  AuthService authService = new AuthService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    userInfo();
  }

  userInfo() async {
    print("calisiyor fonks");
    final User gcurrentUser = auth.currentUser;
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(gcurrentUser.uid).get();

    if (!documentSnapshot.exists) {
      await followersReference
          .doc(gcurrentUser.uid)
          .collection("userFollowers")
          .doc(gcurrentUser.uid)
          .set({});

      print("veri yok aga");
    }
    currentUser = User1.fromDocument(documentSnapshot);
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: <Widget>[
            currentUser != null
                ? HomePage(gCurrentUser: currentUser)
                : Center(
                    child: circularProgressWidget(),
                  ),
            ChattingPage(),
            NotificationPage(),
            currentUser != null
                ? ProfilePage(userProfileId: currentUser.uid)
                : Center(
                    child: circularProgressWidget(),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: mainColor2,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              label: '', icon: Icon(Icons.home), backgroundColor: mainColor2),
          BottomNavigationBarItem(
              label: '', icon: Icon(Icons.chat), backgroundColor: mainColor2),
          BottomNavigationBarItem(
              label: '',
              icon: Icon(Icons.new_releases),
              backgroundColor: mainColor2),
          BottomNavigationBarItem(
              label: '',
              icon: Icon(Icons.account_circle_outlined),
              backgroundColor: mainColor2),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // userInfo();
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }
}
