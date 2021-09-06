import 'package:BRT/constants.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:BRT/strings.dart';
import 'package:BRT/viewmodels/authentication.dart';
import 'package:BRT/widgets/brtFormfield.dart';
import 'package:BRT/widgets/brtbutton.dart';
import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController, _passwordController;
  AuthenticationViewModel _authenticationViewModel;
  bool _isLoading = false;
  Key _scaffoldKey = GlobalKey<ScaffoldState>();

  void _initializeValues() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _authenticationViewModel =
        Provider.of<AuthenticationViewModel>(context, listen: false);
  }

  @override
  void initState() {
    _initializeValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: BrtWhite,
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    BodyBackground(
                      size: size,
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Container(
                          padding: GlobalScreenPadding,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height:MediaQuery.of(context).size.height*0.2,
                                  width:MediaQuery.of(context).size.height*0.7,
                                  child: Image.asset(assetsDirectory + "LogoIcon.png")),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      loginMessage,
                                      style: TextStyle(
                                          color: BRTbrown, fontSize: 17),
                                    ),
                                  ),
                                ),
                                BrtFormField(
                                    title: "Email",
                                    controller: _emailController),
                                widgetSeperator(),
                                BrtFormField(
                                  title: "Password",
                                  controller: _passwordController,
                                  isObsecure: true,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Center(
                                    child: BrtButton(
                                      title: "Sign In",
                                      onPressed: () async {
                                        if (_emailController.text.isNotEmpty &&
                                            _passwordController
                                                .text.isNotEmpty) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          final response =
                                              await _authenticationViewModel
                                                  .signInUser(
                                            userName: _emailController.text,
                                            password: _passwordController.text,
                                          );
                                          if (response.didSucceed) {
                                            // setState(() {
                                            //   _isLoading = false;
                                            // });
                                            Navigator.pushReplacementNamed(
                                                context, DashBoardRoute);
                                          } else {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            showSnackbar(_scaffoldKey,
                                                "Wrong email or password");
                                          }
                                        } else {
                                          showSnackbar(_scaffoldKey,
                                              "Please fill in the values");
                                        }
                                        // Navigator.pushReplacementNamed(context, DashBoardRoute);
                                      },
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }
}

class BodyBackground extends StatelessWidget {
  const BodyBackground({
    Key key,
    @required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        padding: GlobalScreenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Image.asset(assetsDirectory + "BelowLeafIcon.png"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(assetsDirectory + "AboveLeafIcon.png"),
              ],
            ),
          ],
        )
        //  Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Container(
        //           padding: EdgeInsets.zero,
        //           alignment: Alignment.topRight,
        //           child: Image.asset(
        //               assetsDirectory + "BelowLeafIcon.png")),
        //       Center(
        //           child:
        //               Image.asset(assetsDirectory + "LogoIcon.png")),
        //       Text(
        //         loginMessage,
        //         style: TextStyle(color: BRTbrown, fontSize: 17),
        //       ),
        //       SizedBox(
        //         height: 25,
        //       ),
        //       BrtFormField(
        //           title: "Email", controller: _emailController),
        //       widgetSeperator(),
        //       BrtFormField(
        //         title: "Password",
        //         controller: _passwordController,
        //         isObsecure: true,
        //       ),
        //       Center(
        //         child: BrtButton(
        //           title: "Sign In",
        //           onPressed: () async {
        //             if (_emailController.text.isNotEmpty &&
        //                 _passwordController.text.isNotEmpty) {
        //               setState(() {
        //                 _isLoading = true;
        //               });
        //               final response =
        //                   await _authenticationViewModel.signInUser(
        //                 userName: _emailController.text,
        //                 password: _passwordController.text,
        //               );
        //               if (response.didSucceed) {
        //                 setState(() {
        //                   _isLoading = false;
        //                 });
        //                 Navigator.pushNamed(context, DashBoardRoute);
        //               } else {
        //                 setState(() {
        //                   _isLoading = false;
        //                 });
        //                 showSnackbar(
        //                     _scaffoldKey, "Wrong email or password");
        //               }
        //             } else {
        //               showSnackbar(
        //                   _scaffoldKey, "Please fill in the values");
        //             }
        //             // Navigator.pushReplacementNamed(context, DashBoardRoute);
        //           },
        //         ),
        //       ),
        //       SizedBox(height: 30),
        //       Container(
        //           alignment: Alignment.bottomLeft,
        //           child: Image.asset(
        //               assetsDirectory + "AboveLeafIcon.png")),
        //     ]),
        );
  }
}
