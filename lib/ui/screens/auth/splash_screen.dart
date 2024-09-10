import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // Import GetX package
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import the Spinkit package

import '../../controllers/auth_controller.dart';
import '../../utility/assets_path.dart';
import '../../widgets/background_widget.dart';
import '../main_bottom_nav_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    bool isUserLoggedIn = await AuthController.checkAuthState();

    if (mounted) {
      // Use GetX for navigation
      if (isUserLoggedIn) {
        Get.off(() =>  MainBottomNavScreen());
      } else {
        Get.off(() => const SignInScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SvgPicture.asset(
            'assets/images/background.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          BackgroundWidget(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetsPath.applogosvg,
                    width: 140,
                  ),
                  const SizedBox(height: 16), // Spacing between logo and text
                  const Text(
                    "Caretutors",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto', // Use any stylish font
                    ),
                  ),
                  const SizedBox(height: 8), // Spacing between title and subtitle
                  const Text(
                    "Bright Your Future",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Roboto', // Same or another font
                    ),
                  ),
                  const SizedBox(height: 40), // Additional spacing for the loader
                  const SpinKitThreeBounce(
                    color: Colors.blueAccent,
                    size: 50.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
