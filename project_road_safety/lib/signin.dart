import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'forgot_password.dart';
import 'navigate_screen.dart';
import 'snackbar.dart';
import 'theme.dart';

class SignIn extends StatefulWidget {
  const SignIn();

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  final _auth = FirebaseAuth.instance;
  String _loginError = '';

  bool _obscureTextPassword = true;

  Future<void> _login(BuildContext scaffoldContext) async {
    try {
      final email = loginEmailController.text;
      final password = loginPasswordController.text;

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigatePage()),
      );
    } catch (e) {
      setState(() {
        _loginError = 'Invalid email or password. Please try again.';
      });
       CustomSnackBar(scaffoldContext, Text('Error: $_loginError'));
    }
  }

  @override
  void dispose() {
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodeEmail,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: 'Email Address',
                            hintStyle: TextStyle(fontSize: 17.0),
                          ),
                          onSubmitted: (_) {
                            focusNodePassword.requestFocus();
                          },
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodePassword,
                          controller: loginPasswordController,
                          obscureText: _obscureTextPassword,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextPassword
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {
                            // _toggleSignInButton();
                          },
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 170.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  // boxShadow: <BoxShadow>[
                  //   BoxShadow(
                  //     color: CustomTheme.loginGradientStart,
                  //     offset: Offset(1.0, 6.0),
                  //     blurRadius: 20.0,
                  //   ),
                  //   BoxShadow(
                  //     color: CustomTheme.loginGradientEnd,
                  //     offset: Offset(1.0, 6.0),
                  //     blurRadius: 20.0,
                  //   ),
                  // ],
                  gradient: LinearGradient(
                      colors: <Color>[
                       Color.fromARGB(255, 68, 72, 78),
                        Color.fromARGB(255, 219, 218, 217)
                      ],
                      begin: FractionalOffset(0.2, 0.2),
                      end: FractionalOffset(1.0, 1.0),
                      stops: <double>[0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  // splashColor: CustomTheme.loginGradientEnd,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  onPressed: () {
                    _login(context);
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return ForgotPassword();
                  }));
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    // decoration: TextDecoration.underline,
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                )),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 10.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       Container(
          //         decoration: const BoxDecoration(
          //           gradient: LinearGradient(
          //               colors: <Color>[
          //                 Colors.white,
          //                 Colors.white10,
          //               ],
          //               begin: FractionalOffset(0.0, 0.0),
          //               end: FractionalOffset(1.0, 1.0),
          //               stops: <double>[0.0, 1.0],
          //               tileMode: TileMode.clamp),
          //         ),
          //         width: 100.0,
          //         height: 1.0,
          //       ),
          //       const Padding(
          //         padding: EdgeInsets.only(left: 15.0, right: 15.0),
          //         child: Text(
          //           'Or',
          //           style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 16.0,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         decoration: const BoxDecoration(
          //           gradient: LinearGradient(
          //               colors: <Color>[
          //                 Colors.white10,
          //                 Colors.white,
          //               ],
          //               begin: FractionalOffset(0.0, 0.0),
          //               end: FractionalOffset(1.0, 1.0),
          //               stops: <double>[0.0, 1.0],
          //               tileMode: TileMode.clamp),
          //         ),
          //         width: 100.0,
          //         height: 1.0,
          //       ),
          //     ],
          //   ),
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Padding(
          //       padding: const EdgeInsets.only(top: 10.0, right: 40.0),
          //       child: GestureDetector(
          //         onTap: () => CustomSnackBar(
          //             context, const Text('Facebook button pressed')),
          //         child: Container(
          //           padding: const EdgeInsets.all(15.0),
          //           decoration: const BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.white,
          //           ),
          //           child: const Icon(
          //             FontAwesomeIcons.facebookF,
          //             color: Color(0xFF0084ff),
          //           ),
          //         ),
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 10.0),
          //       child: GestureDetector(
          //         onTap: () => CustomSnackBar(
          //             context, const Text('Google button pressed')),
          //         child: Container(
          //           padding: const EdgeInsets.all(15.0),
          //           decoration: const BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.white,
          //           ),
          //           child: const Icon(
          //             FontAwesomeIcons.google,
          //             color: Color(0xFF0084ff),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  void _toggleSignInButton() {
    CustomSnackBar(context, const Text('Login button pressed'));
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }
}
