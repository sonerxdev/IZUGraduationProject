import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicamp/model/user.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/auth/login.dart';
import 'package:unicamp/services/auth.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;
  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  AuthService _authService = new AuthService();
  TextEditingController profileNameTextEditingController =
      new TextEditingController();
  TextEditingController bioTextEditingController = new TextEditingController();

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User1 user;
  bool _bioValid = true;

  bool _profileNameValid = true;

  @override
  void initState() {
    super.initState();
    getDisplayUserInfo();
  }

  getDisplayUserInfo() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(widget.currentOnlineUserId).get();
    user = User1.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.name;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  

  updateUserData() {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 110
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_bioValid && _profileNameValid) {
      usersReference.doc(widget.currentOnlineUserId).update({
        "name": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text
      });

      SnackBar snackBar = SnackBar(
        content: Text(
          "Profil düzenleme başarılı!",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text(
          "Profili Düzenle",
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 0.0,
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      body: loading
          ? Center(
              child: circularProgressWidget(),
            )
          : ListView(
              children: [
                Container(
                  color: mainColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                        child: CircleAvatar(
                          radius: 52.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoLink),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            createProfileNameTextFormField(),
                            createBioTextFormField(),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          onPressed: updateUserData,
                          child: Text(
                            "Güncelle",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          color: secondColor,
                          onPressed: () {
                            _authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                SlideRightRoute(page: LoginPage()),
                                ModalRoute.withName(''));
                          },
                          child: Text(
                            "Çıkış Yap",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "İsim",
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "isim yazin",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Colors.white,
            )),
            hintStyle:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
            errorText: _profileNameValid ? null : "İsim çok kısa",
          ),
        )
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio",
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "Bio yazin",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Colors.white,
            )),
            hintStyle:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
            errorText: _bioValid ? null : "Bio çok uzun.",
          ),
        )
      ],
    );
  }
}
