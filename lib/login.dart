import 'dart:async';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_pay/blank_home.dart';
import 'package:smart_pay/constants.dart';
import 'package:smart_pay/model/auth_model.dart';
import 'package:smart_pay/onboarding.dart';
import 'package:smart_pay/signup.dart';
import 'package:smart_pay/verification.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode? _emailFocusNode;
  FocusNode? _passwordFocusNode;

  @override
  void initState() {
    super.initState();

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _emailFocusNode!.addListener(() {
      if (kDebugMode) {
        print('focusNode updated: hasFocus: ${_emailFocusNode!.hasFocus}');
      }
    });

    _passwordFocusNode!.addListener(() {
      if (kDebugMode) {
        print('focusNode updated: hasFocus: ${_passwordFocusNode!.hasFocus}');
      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
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

  bool _isLoginClicked = false;

  late SharedPreferences _pref;

  final Dio _dio = Dio();

  Future _login(LoginRequestModel loginRequest) async {
    String loginUrl = '${Constants.baseUrl}/auth/login';

    try {
      final response = await _dio.post(loginUrl, data: loginRequest);

      if (kDebugMode) print('smart_pay_res: ${response.data}');

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
                _emailField(),
                _passwordField(),
                _forgotPassword(),
                _loginButton(),
                const SizedBox(height: 30),
                _alternativeLogin(),
                const SizedBox(height: 30),
                _signUpText()
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
          child: Image.asset('assets/hi_there.png'),
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.only(left: 20),
          child: const Text('Welcome back, sign in to your account'),
        ),
      ],
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
        // boxShadow: const [
        //   BoxShadow(
        //     color: Constant.accent,
        //     blurRadius: 10,
        //     offset: Offset(1, 1),
        //   ),
        // ],
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
                      : "This is not an email";
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
        // boxShadow: const [
        //   BoxShadow(
        //     color: Constant.accent,
        //     blurRadius: 10,
        //     offset: Offset(1, 1),
        //   ),
        // ],
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

  Widget _forgotPassword() {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 10),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(right: 20.0),
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Color(0xFFFFAB63),
            fontSize: 16,
          ),
        ),
      ),
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

            Timer(const Duration(milliseconds: 500), () {
              Navigator.of(context).push(
                PageTransition(
                  child: const Signup(),
                  type: PageTransitionType.rightToLeft,
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
                _dialogButton(false, buttonText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _spinnar() {
    return const SpinKitSpinningLines(
      color: Colors.white,
      size: 40.0,
    );
  }

  Widget _loginButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isLoginClicked = true;
          });
          
          _login(
            LoginRequestModel(
                email: _emailController.text,
                password: _passwordController.text,
                deviceName: 'web'),
          ).then((value) async {
            // if (kDebugMode) print(value);

            _isLoginClicked = false;

            // Check if user is registered or verified
            if (value['message'] == 'The given data was invalid.') {
              _showDialog(
                context,
                value['message'] + '\n' + value['errors']['email'][0],
                'Create An Account',
              );
              return;
            } else {
              _pref = await SharedPreferences.getInstance();

              if (kDebugMode) print(value['data']['token']);
              
              // Save authorization token to sheared preferences
              _pref.setString(Constants.authToken, value['data']['token']);

              // Check if user has re-login PIN
              if (_pref.getString(Constants.loginPIN) == null) {
                Navigator.of(context).pushReplacement(
                  PageTransition(
                    child: const Verification(),
                    type: PageTransitionType.fade,
                  ),
                );

                return;
              }

              Navigator.of(context).pushReplacement(
                PageTransition(
                  child: const BlankHome(),
                  type: PageTransitionType.fade,
                ),
              );
            }
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
            child: _isLoginClicked
                ? _spinnar()
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _alternativeLogin() {
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
                side: const BorderSide(color: Colors.grey)),
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

  Widget _signUpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account? ',
          style: TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              PageTransition(
                child: const Signup(),
                type: PageTransitionType.fade,
              ),
            );
          },
          child: const Text(
            'Sign Up',
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
