import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../build_page.dart';
import './introduction_screen.dart';
import '../../utils/app_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await Future.delayed(Duration(seconds: 2));
    if (appProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => buildPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => IntroductionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(flex: 3),
              Image.asset(
                'assets/logo.png',
                width: 275,
                height: 275,
                fit: BoxFit.cover,
              ),
              Spacer(flex: 2),
              LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.yellow.shade600,
                size: 70,
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
