import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicamp/screens/auth/onboarding_screen.dart';
import 'package:unicamp/screens/selector.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          print("data exists");
          return SelectorPage();
        } else {
          return OnboardingPage();
        }
      },
    );
  }
}
