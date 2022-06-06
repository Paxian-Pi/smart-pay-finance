import 'dart:async';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_pay/constants.dart';
import 'package:smart_pay/login.dart';
import 'package:smart_pay/model/auth_model.dart';

import 'blank_home.dart';

class Verification extends StatefulWidget {
  const Verification({Key? key}) : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  FocusNode? _focusNode;

  late SharedPreferences _pref;

  final Dio _dio = Dio();

  Future _login(LoginRequestModel loginRequest) async {
    String loginUrl = '${Constants.baseUrl}auth/login';

    try {
      final response = await _dio.post(loginUrl, data: loginRequest);

      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _appBar(context),
                const SizedBox(height: 150),
                _appText(),
                const SizedBox(height: 40),
                _pinInput(),
                const SizedBox(height: 50),
                _loginButton()
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text('Enter your PIN',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 15),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text(
                'This PIN enables you to re-login without having to re-type your credentials!'),
          ),
        ],
      ),
    );
  }

  Widget _pinInput() {
    return Container(
      alignment: Alignment.center,
      child: Pinput(
        focusNode: _focusNode,
        onCompleted: (pin) async {
          if (kDebugMode) print(pin);

          _pref = await SharedPreferences.getInstance();
          if (kDebugMode) print(_pref.getString(Constants.loginPIN));

          if (_pref.getString(Constants.loginPIN) != null) {
            if (_pref.getString(Constants.loginPIN) == pin) {
              Navigator.of(context).pushReplacement(
                PageTransition(
                  child: const BlankHome(),
                  type: PageTransitionType.fade,
                ),
              );
            } else {
              _showDialog(
                  context,
                  'Wrong PIN!\nTap outside this dialog to try again...',
                  'Back To Login?');
            }

            return;
          }

          // Save user's re-login PIN
          _pref = await SharedPreferences.getInstance();
          _pref.setString(Constants.loginPIN, pin);

          Navigator.of(context).pushReplacement(
            PageTransition(
              child: const BlankHome(),
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
      ),
    );
  }

  Widget _loginButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            PageTransition(
              child: const Login(),
              type: PageTransitionType.fade,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          onPrimary: const Color(0xFFFFAB63),
          shadowColor: Colors.grey,
          elevation: 3,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black),
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
            child: const Text(
              'Cancel | Back To Login',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogButton(String buttonText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.vibrate();
            SystemSound.play(SystemSoundType.click);

            Navigator.of(context).pop();

            Timer(const Duration(milliseconds: 500), () {
              Navigator.of(context).push(
                PageTransition(
                  child: const Login(),
                  type: PageTransitionType.leftToRight,
                ),
              );
            });
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
                _dialogButton(buttonText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
