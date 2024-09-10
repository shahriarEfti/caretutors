import 'package:caretutors/ui/screens/auth/sign_in_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX package

import '../../../data/models/network_response.dart';
import '../../../data/network_callers/network_caller.dart';
import '../../../data/utilities/urls.dart';
import '../../utility/app_colors.dart';
import '../../widgets/background_widget.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  // Define controllers and loading state in GetX Controller
  final RxBool _loadingInProgress = false.obs;
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    'Set Password',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Minimum length of password should be more than 6 letters and, combination of numbers and letters',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 24),
                  Obx(() => TextFormField(
                    controller: _passwordTEController,
                    decoration: const InputDecoration(hintText: 'Password'),
                    obscureText: true,
                    enabled: !_loadingInProgress.value,
                  )),
                  const SizedBox(height: 8),
                  Obx(() => TextFormField(
                    controller: _confirmPasswordTEController,
                    decoration: const InputDecoration(hintText: 'Confirm Password'),
                    obscureText: true,
                    enabled: !_loadingInProgress.value,
                  )),
                  const SizedBox(height: 16),
                  Obx(() => ElevatedButton(
                    onPressed: _loadingInProgress.value ? null : _onTapConfirmButton,
                    child: _loadingInProgress.value
                        ? const CircularProgressIndicator()
                        : const Text('Confirm'),
                  )),
                  const SizedBox(height: 36),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                        text: "Have an account? ",
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(color: AppColors.themeColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _onTapSignInButton(),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapSignInButton() {
    Get.offAll(() => const SignInScreen());
  }

  void _onTapConfirmButton() {
    if (_passwordTEController.text == _confirmPasswordTEController.text) {
      _resetPassword();
    } else {
      _showErrorDialog("Passwords do not match!");
    }
  }

  Future<void> _resetPassword() async {
    _loadingInProgress.value = true;

    Map<String, dynamic> requestInput = {
      "email": email,
      "OTP": otp,
      "password": _confirmPasswordTEController.text
    };

    NetworkResponse response = await NetworkCaller.postRequest(
      Urls.recoverResetPass,
      body: requestInput,
    );

    _loadingInProgress.value = false;

    if (response.responseData['status'] == 'success') {
      _clearTextField();
      _showSuccessDialog("Password reset success.");
    } else {
      _clearTextField();
      _showErrorDialog("Something went wrong, try again.");
    }
  }

  void _clearTextField() {
    _passwordTEController.clear();
    _confirmPasswordTEController.clear();
  }

  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  void _showSuccessDialog(String message) {
    Get.defaultDialog(
      title: 'Success',
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _onTapSignInButton();
      },
    );
  }
}
