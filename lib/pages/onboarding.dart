import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_pay/authentication/login.dart';
import 'package:smart_pay/pages/blank_home.dart';
import 'package:smart_pay/constants.dart';
import 'package:smart_pay/authentication/verification.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  late SharedPreferences _pref;
  
  void _getAppState() async {
    _pref = await SharedPreferences.getInstance();
    
    if (_pref.getString(Constants.authToken) != null) {
      Navigator.of(context).push(
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: const Verification(),
        ),
      );
      
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    _getAppState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: SafeArea(
            child: IntroductionScreen(
              pages: [
                PageViewModel(
                  title: '',
                  body: '',
                  image: null,
                  decoration: gePageDecoration('assets/onboarding1.png', false),
                ),
                PageViewModel(
                  title: '',
                  body: '',
                  image: null,
                  decoration: gePageDecoration('assets/onboarding2.png', true),
                  footer: _buttonGetStarted(context),
                ),
              ],
              done: const Text(
                'Next',
                style: TextStyle(fontSize: 20),
              ),
              onDone: () => _login(context),
              doneColor: const Color(0xFFFFAB63),
              showSkipButton: true,
              skip: const Text(
                'Skip',
                style: TextStyle(fontSize: 20),
              ),
              skipColor: const Color(0xFFFFAB63),
              skipFlex: 0,
              nextFlex: 0,
              nextColor: const Color(0xFFFFAB63),
              next: const Icon(Icons.arrow_forward),
              dotsDecorator: getDotDecorator(),
              // onChange: (index) => print('Page $index selected'),
              globalBackgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBackgroundImage(String path) {
    return Center(
      child: Image.asset(path, width: 250),
    );
  }

  PageDecoration gePageDecoration(String imagePath, bool isButtonAvailable) =>
      PageDecoration(
        boxDecoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        bodyTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
        descriptionPadding: const EdgeInsets.all(16),
        imagePadding: const EdgeInsets.only(top: 280.0),
        contentMargin: isButtonAvailable
            ? const EdgeInsets.only(top: 400.0)
            : const EdgeInsets.only(top: 70.0),
        // pageColor: Constant.white,
      );

  DotsDecorator getDotDecorator() => DotsDecorator(
        color: Colors.grey,
        size: const Size(10, 10),
        activeColor: Colors.black,
        activeSize: const Size(21, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );

  void _login(context) {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const Login(),
      ),
    );
  }

  Widget _buttonGetStarted(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        ElevatedButton(
          onPressed: () {
            _login(context);
          },
          style: ElevatedButton.styleFrom(
            onPrimary: const Color(0xFFFFAB63),
            shadowColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.black)),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.black],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
              alignment: Alignment.center,
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
