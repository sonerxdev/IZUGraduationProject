import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:unicamp/screens/auth/login.dart';
import 'package:unicamp/screens/auth/register.dart';
import 'package:unicamp/shared/background_image_widget.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            items: [
              BackgroundPageImage(
                imageLocation: 'assets/images/uni.jpg',
              )
            ],
            options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                }),
          ),
          FadeIn(
            duration: Duration(milliseconds: 1000),
            child: Center(
              child: Padding(
                padding: context.paddingMedium,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Sadece \nÜniversiteliler İçin",
                      style: TextStyle(
                          fontSize: 46.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.dynamicHeight(0.03),
                    ),
                    Text(
                      "Arkadaşlarınızı bulun, not paylaşın ve sohbet edin.",
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.dynamicHeight(0.08),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideRightRoute(
                            page: RegisterPage(),
                          ),
                        );
                      },
                      color: Colors.white,
                      minWidth: double.infinity,
                      padding: context.paddingVertical,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Okul E-maili ile kayıt olun.',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: context.dynamicHeight(0.02),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideRightRoute(
                            page: LoginPage(),
                          ),
                        );
                      },
                      color: secondColor,
                      minWidth: double.infinity,
                      padding: context.paddingVertical,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Hesabınız var mı? Giriş yapın.',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: context.dynamicHeight(0.05),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Kayıt olduğunuzda ",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "sözleşmeyi",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Text(
                      "kabul etmiş olursunuz.",
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
