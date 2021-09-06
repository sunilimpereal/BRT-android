import 'dart:async';

import 'package:BRT/constants.dart';
import 'package:BRT/viewmodels/authentication.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AuthenticationRoute);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Image.asset(assetsDirectory + "LogoIcon.png")),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Image.asset(
              assetsDirectory + "PoweredIcon.png",
              height: 150,
              width: 150,
            ),
          )
        ],
      ),
    );
  }
}

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthenticationViewModel>(context);
    return FutureBuilder(
      future: authVM.tryAutoLogIn(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (authVM.isAuthenticated) {
            return Dashboard();
          } else {
            return LoginPage();
          }
        }
        return Container();
      },
    );
  }
}
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final authVM = Provider.of<AuthenticationViewModel>(context);
//     return FutureBuilder(
//       future: authVM.tryAutoLogIn(),
