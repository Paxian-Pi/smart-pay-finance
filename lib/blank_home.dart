import 'dart:async';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_pay/constants.dart';

import 'login.dart';

class BlankHome extends StatefulWidget {
  const BlankHome({Key? key}) : super(key: key);

  @override
  State<BlankHome> createState() => _BlankHomeState();
}

class _BlankHomeState extends State<BlankHome> {
  final Dio _dio = Dio();

  late String _secretMessage = '';

  late SharedPreferences _pref;

  Future _getSecretMessage() async {
    String secretUrl = '${Constants.baseUrl}/dashboard';

    _pref = await SharedPreferences.getInstance();

    try {
      _dio.options.headers["Authorization"] =
          'Bearer ${_pref.getString(Constants.authToken)}';
      final response = await _dio.get(secretUrl);

      // if (kDebugMode) print('smart_pay_res: ${response.data}');

      setState(() {
        _secretMessage = response.data['data']['secret'];
      });

      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future _logout() async {
    String logoutUrl = '${Constants.baseUrl}/logout';

    try {
      final response = await _dio.post(logoutUrl);

      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  @override
  void initState() {
    super.initState();

    _getSecretMessage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              _appBar(context),
              const SizedBox(height: 100),
              Image.asset('assets/logo.png'),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _secretMessage == ''
                    ? _spinnar()
                    : Text(
                        _secretMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spinnar() {
    return const SpinKitSpinningLines(
      color: Colors.black,
      size: 40.0,
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.vibrate();
                SystemSound.play(SystemSoundType.click);

                _showDialog(
                  context,
                  'Are you sure?',
                  'Yes, Logout',
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 3,
                child: const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Icon(
                    Icons.logout,
                    color: Colors.black,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ],
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

            _logout().then((value) async {
              if (kDebugMode) print('smart_pay_logged_out => $value');

              _pref = await SharedPreferences.getInstance();

              _pref.remove(Constants.authToken);
              _pref.remove(Constants.loginPIN);

              Navigator.of(context).pop();

              Timer(const Duration(milliseconds: 300), () {
                Navigator.of(context).pushReplacement(
                  PageTransition(
                    child: const Login(),
                    type: PageTransitionType.leftToRight,
                  ),
                );
              });
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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 295),
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
                  'Logout!',
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
