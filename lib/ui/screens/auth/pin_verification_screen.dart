import 'dart:async';

import 'package:caretutors/ui/screens/auth/reset_password_screen.dart';
import 'package:caretutors/ui/screens/auth/sign_in_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../data/models/network_response.dart';
import '../../../data/network_callers/network_caller.dart';
import '../../../data/utilities/urls.dart';
import '../../utility/app_colors.dart';
import '../../widgets/background_widget.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final TextEditingController _pinTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loadingInProgress = false;
  bool _isResendEnabled = true;
  int _start = 60;
  late Timer _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      'Pin Verification',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A 6 digits verification pin has been sent to your email address',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 24),
                    _buildPinCodeTextField(),
                    const SizedBox(height: 16),
                    _loadingInProgress
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _otpVerification();
                        }
                      },
                      child: const Text('Verify'),
                    ),
                    const SizedBox(height: 16),
                    _buildResendOtpSection(),
                    const SizedBox(height: 36),
                    _buildSignInSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInSection() {
    return Center(
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
              recognizer: TapGestureRecognizer()..onTap = _onTapSignInButton,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPinCodeTextField() {
    return PinCodeTextField(
      length: 6,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white,
        selectedFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        selectedColor: AppColors.themeColor,
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: Colors.transparent,
      keyboardType: TextInputType.number,
      enableActiveFill: true,
      controller: _pinTEController,
      appContext: context,
    );
  }

  Widget _buildResendOtpSection() {
    return Center(
      child: TextButton(
        onPressed: _isResendEnabled ? _resendOtp : null,
        child: Text(
          _isResendEnabled
              ? 'Resend OTP'
              : 'Resend OTP in $_start seconds',
          style: const TextStyle(color: AppColors.themeColor),
        ),
      ),
    );
  }

  void _onTapSignInButton() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
    );
  }

  Future<void> _otpVerification() async {
    setState(() {
      _loadingInProgress = true;
    });

    String otp = _pinTEController.text.trim();

    NetworkResponse response = await NetworkCaller.getResponse(
      "${Urls.recoverVerifyOTP}/${widget.email}/$otp",
    );

    setState(() {
      _loadingInProgress = false;
    });

    if (response.isSuccess && response.responseData['status'] == 'success') {
      _clearOtpField();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email, otp: otp),
        ),
      );
    } else if (response.responseData['status'] == 'fail') {
      _clearOtpField();
      if (mounted) {
        _oneButtonDialog(
          context,
          "Failed!",
          "Please enter a valid OTP!",
          Icons.error_outline_rounded,
        );
      }
    } else {
      _clearOtpField();
      if (mounted) {
        _oneButtonDialog(
          context,
          "Failed!",
          "Something went wrong!",
          Icons.error_outline_rounded,
        );
      }
    }
  }

  void _clearOtpField() {
    _pinTEController.clear();
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResendEnabled = false;
      _start = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start == 0) {
          _isResendEnabled = true;
          _timer.cancel();
        } else {
          _start--;
        }
      });
    });

    NetworkResponse response = await NetworkCaller.getResponse(
      "${Urls.recoverVerifyEmail}/${widget.email}",
    );

    if (response.isSuccess && response.responseData['status'] == 'success') {
      if (mounted) {
        _oneButtonDialog(
          context,
          "Success!",
          "OTP has been resent to your email.",
          Icons.check_circle_outline_rounded,
        );
      }
    } else if (response.responseData['status'] == 'fail') {
      if (mounted) {
        _oneButtonDialog(
          context,
          "Failed!",
          "This email is not registered!",
          Icons.error_outline_rounded,
        );
      }
    } else {
      if (mounted) {
        _oneButtonDialog(
          context,
          "Failed!",
          "Something went wrong!",
          Icons.error_outline_rounded,
        );
      }
    }
  }

  void _oneButtonDialog(BuildContext context, String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinTEController.dispose();
    _timer.cancel();
    super.dispose();
  }
}