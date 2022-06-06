import 'dart:async';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_pay/pages/blank_home.dart';
import 'package:smart_pay/constants.dart';
import 'package:smart_pay/authentication/login.dart';
import 'package:smart_pay/model/auth_model.dart';
import 'package:smart_pay/authentication/verification.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode? _fullnameFocusNode;
  FocusNode? _emailFocusNode;
  FocusNode? _passwordFocusNode;

  @override
  void initState() {
    super.initState();

    _fullnameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _fullnameFocusNode!.dispose();
    _emailFocusNode!.dispose();
    _passwordFocusNode!.dispose();

    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      Constants.hideOrShowPassword = !Constants.hideOrShowPassword;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool _isSignupClicked = false;
  bool _isSuccessful = false;

  late SharedPreferences _pref;

  final Dio _dio = Dio();

  Future _getEmailToken(GetEmailTokenRequestModel emailTokenRequest) async {
    String emailTokenUrl = '${Constants.baseUrl}/auth/email';

    try {
      final response = await _dio.post(emailTokenUrl, data: emailTokenRequest);

      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future _verifyEmail(VerifyEmailRequestModel verifyRequest) async {
    String verifyUrl = '${Constants.baseUrl}/auth/email/verify';

    try {
      final response = await _dio.post(verifyUrl, data: verifyRequest);

      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future _signup(RegisterRequestModel registerRequest) async {
    String registerUrl = '${Constants.baseUrl}/auth/register';

    try {
      final response = await _dio.post(registerUrl, data: registerRequest);

      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar(context),
                _appText(),
                const SizedBox(height: 40),
                _fullname(),
                _emailField(),
                _passwordField(),
                _signupButton(),
                const SizedBox(height: 30),
                _alternativeSignup(),
                const SizedBox(height: 30),
                _signInText()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(top: 50),
      width: size.width,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.vibrate();
                SystemSound.play(SystemSoundType.click);

                Navigator.pop(context);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 3,
                child: const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.black,
                    size: 23.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Container(
          margin: const EdgeInsets.only(left: 20),
          child: Image.asset('assets/image_title.png'),
        ),
      ],
    );
  }

  Widget _fullname() {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: _fullnameFocusNode!.hasFocus
              ? const Color(0xFFFFAB63)
              : const Color(0xFFF9FAFB),
          width: 1,
        ),
        color: const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: TextFormField(
                controller: _fullnameController,
                onTap: () => _fullnameFocusNode!.requestFocus(),
                focusNode: _fullnameFocusNode,
                keyboardType: TextInputType.name,
                maxLines: 1,
                decoration: InputDecoration(
                  label: const Text('Fullname'),
                  labelStyle: _fullnameFocusNode!.hasFocus
                      ? const TextStyle(color: Color(0xFFFFAB63))
                      : const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailField() {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: _emailFocusNode!.hasFocus
              ? const Color(0xFFFFAB63)
              : const Color(0xFFF9FAFB),
          width: 1,
        ),
        color: const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: TextFormField(
                controller: _emailController,
                onTap: () => _emailFocusNode!.requestFocus(),
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                decoration: InputDecoration(
                  label: const Text('Email'),
                  labelStyle: _emailFocusNode!.hasFocus
                      ? const TextStyle(color: Color(0xFFFFAB63))
                      : const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Oops! No email... Make sure to enter a real email";
                  }
                  return RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)
                      ? null
                      : "Invalid email";
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: _passwordFocusNode!.hasFocus
              ? const Color(0xFFFFAB63)
              : const Color(0xFFF9FAFB),
          width: 1,
        ),
        color: const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: TextFormField(
                controller: _passwordController,
                onTap: () => _passwordFocusNode!.requestFocus(),
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                obscureText: Constants.hideOrShowPassword,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: _toggleVisibility,
                    child: Icon(
                      Constants.hideOrShowPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 25.0,
                      color: Colors.grey,
                    ),
                  ),
                  label: const Text('Password'),
                  labelStyle: _passwordFocusNode!.hasFocus
                      ? const TextStyle(color: Color(0xFFFFAB63))
                      : const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spinnar() {
    return const SpinKitSpinningLines(
      color: Colors.white,
      size: 40.0,
    );
  }

  Widget _dialogButton(bool isAccountDialog, String buttonText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.vibrate();
            SystemSound.play(SystemSoundType.click);

            Navigator.of(context).pop();
            Timer(
              const Duration(milliseconds: 1000),
              (() {
                Navigator.of(context).pushReplacement(
                  PageTransition(
                    child: const Login(),
                    type: PageTransitionType.fade,
                  ),
                );
              }),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE2E5FF),
                width: 1,
              ),
              // boxShadow: const [
              //   BoxShadow(
              //     color: Constant.accent,
              //     blurRadius: 10,
              //     offset: Offset(1, 1),
              //   ),
              // ],
              color: const Color(0xFFE2E5FF),
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context, String message, String buttonText) {
    showDialog(
      context: context,
      builder: (context) => ScaleAnimatedWidget.tween(
        enabled: true,
        duration: const Duration(milliseconds: 200),
        scaleDisabled: 0.5,
        scaleEnabled: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 270),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none),
                ),
                const SizedBox(height: 30),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none),
                ),
                const SizedBox(height: 20),
                _dialogButton(false, buttonText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signupButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isSignupClicked = true;
          });

          _getEmailToken(
                  GetEmailTokenRequestModel(email: _emailController.text))
              .then((value) {
            _verifyEmail(
              VerifyEmailRequestModel(
                email: _emailController.text,
                token: value['data']['token'],
              ),
            ).then((value) {
              print(value);

              _signup(
                RegisterRequestModel(
                    fullName: _fullnameController.text,
                    username: '',
                    email: _emailController.text,
                    country: 'NG',
                    password: _passwordController.text,
                    deviceName: 'web'),
              ).then((value) {
                if ((value['message'] == 'The given data was invalid.')) {
                  if (value!['errors']['password'][0] ==
                      'The password must contain at least one uppercase and one lowercase letter.') {
                    _showDialog(
                      context,
                      value['message'] + '\n' + value!['errors']['password'][0],
                      'Okay',
                    );
                  }

                  if (value!['errors']['email'][0] ==
                      'The email has already been taken.') {
                    _showDialog(
                      context,
                      value['message'] + '\n' + value!['errors']['email'][0],
                      'Okay',
                    );
                  }

                  return;
                }

                _isSignupClicked = false;
                _isSuccessful = true;

                Timer(const Duration(milliseconds: 1000), () {
                  Navigator.of(context).pushReplacement(
                    PageTransition(
                      child: const Login(),
                      type: PageTransitionType.fade,
                    ),
                  );
                });
              });
            });
          });
        },
        style: ElevatedButton.styleFrom(
          onPrimary: const Color(0xFFFFAB63),
          shadowColor: Colors.grey,
          elevation: 3,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black, Colors.black],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 50,
            alignment: Alignment.center,
            child: _isSignupClicked
                ? _spinnar()
                : Text(
                    _isSuccessful ? 'Successful' : 'Sign Up',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _alternativeSignup() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/line.png'),
            const SizedBox(width: 10),
            Container(
              alignment: Alignment.center,
              child: const Text('OR'),
            ),
            const SizedBox(width: 10),
            Image.asset('assets/line_right.png'),
          ],
        ),
        const SizedBox(height: 30),
        _platformSignupButtons()
      ],
    );
  }

  Widget _platformSignupButtons() {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigator.of(context).pushReplacement(
            //   PageTransition(
            //     child: const BottomNav(),
            //     type: PageTransitionType.fade,
            //   ),
            // );
          },
          style: ElevatedButton.styleFrom(
            onPrimary: const Color(0xFFFFAB63),
            shadowColor: Colors.grey,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade200],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              alignment: Alignment.center,
              child: Image.asset('assets/google.png', width: 25, height: 25),
            ),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            // Navigator.of(context).pushReplacement(
            //   PageTransition(
            //     child: const BottomNav(),
            //     type: PageTransitionType.fade,
            //   ),
            // );
          },
          style: ElevatedButton.styleFrom(
            onPrimary: const Color(0xFFFFAB63),
            shadowColor: Colors.grey,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey)),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade200],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              alignment: Alignment.center,
              child: Image.asset('assets/apple.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signInText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: const Login(),
                type: PageTransitionType.fade,
              ),
            );
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Color(0xFFFFAB63),
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
