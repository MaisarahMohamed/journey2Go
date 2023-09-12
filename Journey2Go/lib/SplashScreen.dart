import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:journey2go/auth/authPage.dart';
import 'package:page_transition/page_transition.dart';

import 'main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        ///TODO Add your image under assets folder
        child: Image.asset(
            'assets/logoSplash.png',
            scale:2.5
        ),
      ),
      backgroundColor: Colors.indigo[900]!,
      nextScreen: const AuthPage(),
      splashIconSize: 250,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.topToBottom,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
