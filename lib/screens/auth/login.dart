import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/screens/auth/register.dart';
import 'package:unicamp/screens/selector.dart';
import 'package:unicamp/services/auth.dart';
import 'package:unicamp/services/chat_service.dart';
import 'package:unicamp/services/helper.dart';
import 'package:unicamp/shared/background_image_widget.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  QuerySnapshot snapshotUserInfo;

  AuthService _authService = new AuthService();

  TextEditingController emailTextEditingController =
      new TextEditingController();

  ChatService chatService = new ChatService();

  loginFunction() {
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });

      dynamic result = _authService.loginFunction(email, password).then((x) {
        if (x == null) {
          setState(() {
            SnackBar snackBar = SnackBar(
              content: Text(
                "Şifre ya da E-Posta Hatalı!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w300),
              ),
              backgroundColor: Colors.red,
              duration: Duration(milliseconds: 2000),
              elevation: 20.0,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            print("sifre ya da e posta hatali");
            loading = false;
          });
        } else {
          chatService
              .getUserByUserEmail(emailTextEditingController.text)
              .then((val) {
            snapshotUserInfo = val;
            HelpFunctions.saveUserName(
                snapshotUserInfo.docs[0].data()["username"]);
          });

          Navigator.of(context).pushAndRemoveUntil(
              SlideRightRoute(page: SelectorPage()), ModalRoute.withName(''));
          print("basarili");

          SnackBar snackBar = SnackBar(
            content: Text(
              "Giriş yapma başarılı.",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w300),
            ),
            backgroundColor: secondColor,
            duration: Duration(milliseconds: 3000),
            elevation: 20.0,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }
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
                      imageLocation: 'assets/images/uni3.jpg',
                    ),
                    SingleChildScrollView(
                      child: Container(
                        height: context.dynamicHeight(0.7),
                        alignment: Alignment.center,
                        padding: context.paddingHorizontalMedium,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Giriş Yap",
                                style: TextStyle(
                                    fontSize: 30.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: context.dynamicHeight(0.05),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.alternate_email,
                                    color: Colors.white,
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
                                          ? ' Geçerli bir mail adresi girin.'
                                          : null),
                                      onChanged: (input) {
                                        setState(() {
                                          email = input;
                                        });
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
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: context.dynamicWidth(0.03)),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: true,
                                      validator: (input) => (input.isEmpty ||
                                              input.length < 8)
                                          ? 'Geçersiz şifre. Şifreniz en az 7 karakter olmalı. '
                                          : null,
                                      onChanged: (input) {
                                        setState(() {
                                          password = input;
                                        });
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
                                height: context.dynamicHeight(0.02),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: context.paddingVertical,
                                    child: Text(
                                      'Şifreni mi unuttun?',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                              ButtonWidget(
                                width: context.dynamicWidth(0.7),
                                buttonColor: secondColor,
                                textColor: Colors.white,
                                borderColor: secondColor,
                                text: "Giriş Yap",
                                onPressed: () async {
                                  await loginFunction();
                                },
                              ),
                              SizedBox(
                                height: context.dynamicHeight(0.01),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: context.paddingVertical,
                                      child: Text(
                                        'Hesabınız mı yok?',
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
                                          page: RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding: context.paddingVertical,
                                        child: Text(
                                          'Kaydolun.',
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
