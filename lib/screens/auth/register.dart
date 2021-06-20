import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/auth/login.dart';
import 'package:unicamp/screens/selector.dart';
import 'package:unicamp/services/auth.dart';
import 'package:unicamp/services/helper.dart';
import 'package:unicamp/shared/background_image_widget.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  AuthService _authService = new AuthService();
  TextEditingController userNameTextEditingController =
      new TextEditingController();

  TextEditingController emailTextEditingController =
      new TextEditingController();

  var x;
  File file;

  bool loading = false;
  File imageFile;
  String name = ' ';
  String username = ' ';
  String email = ' ';
  String password = ' ';
  String university = ' ';
  String linkedinLink = ' ';
  String photoLink = ' ';
  String bio = '';

  String state = "Üniversite Seçin";

  List<String> items = [
    '',
    'İstanbul Sabahattin Zaim Üniversitesi',
    'İstanbul Üniversitesi',
    'Orta Doğu Teknik Üniversitesi',
    'İstanbul Teknik Üniversitesi',
    'Boğaziçi Üniversitesi',
  ];

  signInFunction(BuildContext context) {
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });

      HelpFunctions.saveUserEmail(emailTextEditingController.text);
      HelpFunctions.saveUserName(userNameTextEditingController.text);

      Future uploadPic() async {
        Reference firebaseStorageReference =
            FirebaseStorage.instance.ref().child(imageFile.path);

        UploadTask uploadTask = firebaseStorageReference.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        x = (await taskSnapshot.ref.getDownloadURL()).toString();

        await _authService.registerFunction(
          name,
          username,
          email,
          password,
          university,
          linkedinLink,
          bio,
          x,
        );
      }

      if (imageFile != null) {
        uploadPic();
      } else {
        _authService.registerFunction(
          name,
          username,
          email,
          password,
          university,
          linkedinLink,
          bio,
          'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        );
      }

      Navigator.of(context).pushAndRemoveUntil(
          SlideRightRoute(page: SelectorPage()),
          ModalRoute.withName('Home Page'));

      SnackBar snackBar = SnackBar(
        content: Text(
          "Başarıyla kayıt oldunuz.",
          style: TextStyle(
              color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
        ),
        backgroundColor: secondColor,
        duration: Duration(milliseconds: 3000),
        elevation: 20.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  captureImageWithCamera() async {
    Navigator.pop(context);
    imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    setState(() {
      this.file = imageFile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Yeni Gönderi",
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Kamera",
                style:
                    TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Galeri",
                style:
                    TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "İptal",
                style:
                    TextStyle(fontWeight: FontWeight.w300, color: Colors.blue),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: circularProgressWidget(),
          )
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: FadeIn(
                duration: Duration(milliseconds: 500),
                child: Stack(
                  children: [
                    BackgroundPageImage(
                      imageLocation: 'assets/images/uni.jpg',
                    ),
                    SingleChildScrollView(
                      child: Container(
                        padding: context.paddingHorizontal,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: context.dynamicHeight(0.05),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: context.dynamicWidth(0.1),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 60,
                                    child: ClipOval(
                                      child: new SizedBox(
                                        width: context.dynamicWidth(0.3),
                                        height: context.dynamicHeight(0.3),
                                        child: (imageFile != null)
                                            ? Image.file(
                                                imageFile,
                                                fit: BoxFit.fill,
                                              )
                                            : Image.asset(
                                                'assets/images/1.png',
                                                fit: BoxFit.fill,
                                              ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    color: secondColor,
                                    icon: Icon(Icons.camera_alt_outlined,
                                        size: 30),
                                    onPressed: () {
                                      takeImage(context);
                                    },
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_outlined,
                                    color: secondColor,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.03)),
                                  Expanded(
                                    child: TextFormField(
                                      validator: (input) =>
                                          input.isEmpty ? 'İsim girin' : null,
                                      onChanged: (input) {
                                        setState(() => name = input);
                                      },
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                      decoration:
                                          InputDecoration(
                                          hintText: "İsim",
                                          hintStyle:
                                              TextStyle(color: Colors.white54),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    color: secondColor,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.03)),
                                  Expanded(
                                    child: TextFormField(
                                      controller: userNameTextEditingController,
                                      validator: (input) => input.isEmpty
                                          ? 'Kullanıcı adı girin'
                                          : null,
                                      onChanged: (input) {
                                        setState(() => username = input);
                                      },
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                            hintText: "Kullanıcı adı",
                                            hintStyle: TextStyle(
                                                color: Colors.white54),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)))
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.alternate_email_rounded,
                                    color: secondColor,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.03)),
                                  Expanded(
                                    child: TextFormField(
                                      controller: emailTextEditingController,
                                      validator: (input) => (input.length
                                                      .toInt() <
                                                  6 ||
                                              !input.contains("edu.tr") ||
                                              !input.contains("@")
                                          ? ' Geçerli bir okul mail adresi girin.'
                                          : null),
                                      onChanged: (input) {
                                        setState(() => email = input);
                                      },
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                      decoration:
                                          InputDecoration(
                                          hintText: "Email",
                                          hintStyle:
                                              TextStyle(color: Colors.white54),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: secondColor,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.03)),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: true,
                                      validator: (input) => input.length < 6
                                          ? 'Şifre girin'
                                          : null,
                                      onChanged: (input) {
                                        setState(() => password = input);
                                      },
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                      decoration:
                                          InputDecoration(
                                          hintText: "Şifre",
                                          hintStyle:
                                              TextStyle(color: Colors.white54),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: context.dynamicHeight(0.03),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    color: secondColor,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.1)),
                                  Expanded(
                                    child: CupertinoPickerWidget(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      children: [
                                        for (var i in items) Text(i.toString())
                                      ],
                                      text: state,
                                      onSelectedItemChanged: (int index) {
                                        setState(() {
                                          this.state = items[index];
                                          university = this.state;
                                          print(state);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: secondColor,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.1)),
                                  Expanded(
                                    child: TextFormField(
                                      validator: (input) => input.isEmpty
                                          ? 'Linkedin linki'
                                          : null,
                                      onChanged: (input) {
                                        setState(() => linkedinLink = input);
                                      },
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          hintText: "Linkedin hesabınızın url'si",
                                          hintStyle:
                                              TextStyle(color: Colors.white54),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: context.dynamicHeight(0.03),
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.favorite,
                                    color: secondColor,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.03)),
                                  Expanded(
                                    child: TextField(
                                        maxLines: 5,
                                        onChanged: (input) {
                                          setState(() => bio = input);
                                        },
                                        style: TextStyle(color: secondColor),
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(40))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(40))),
                                            hintText: ' Bio',
                                            filled: true,
                                            fillColor: Color(0xFF2A3442),
                                            border: InputBorder.none)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: context.dynamicHeight(0.03),
                              ),
                              ButtonWidget(
                                width: context.dynamicWidth(0.7),
                                buttonColor: secondColor,
                                textColor: Colors.white,
                                borderColor: secondColor,
                                text: "Kaydol",
                                onPressed: () {
                                  signInFunction(context);
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: context.paddingVertical,
                                      child: Text(
                                        'Zaten hesabınız var mı?',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.02)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: LoginPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding: context.paddingVertical,
                                        child: Text(
                                          'Giriş yapın.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
