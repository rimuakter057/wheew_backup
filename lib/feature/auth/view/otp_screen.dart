import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
//import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/color/app_colors.dart';
import '../../../utils/extension/string_extension.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key /* required this.phoneNumber*/});

  //final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool hasError = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_otpController.text.length != 6) {
      setState(() => hasError = true);
      return;
    }

    setState(() => hasError = false);

    /// Navigate after success
    context.goNamed(RouteName.otp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('verification_code'.tr)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.padding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('enter_verification_code'.tr,
                style: TextStyle(fontSize:16),

              ),
              SizedBox(height: 16,),
              Text('we_sent_6_digit_code'.tr,
              style: TextStyle(fontSize: 14),
              ),

              //const Spacer(),
              const SizedBox(height: 32),

              /// OTP FIELD
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                enableActiveFill: true,
                backgroundColor: Colors.transparent,
                cursorColor: AppColors.successColor,

                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 52,
                  fieldWidth: 52,

                  activeColor: AppColors.successColor,
                  selectedColor: AppColors.brandHoverColor,
                  inactiveColor: Colors.transparent,

                  activeFillColor: AppColors.softBrandColor,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: AppColors.softBrandColor,
                ),

                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),

                beforeTextPaste: (text) => true,

                onChanged: (_) {
                  if (hasError) setState(() => hasError = false);
                },

                onCompleted: (value) {
                  debugPrint('OTP: $value');
                },
              ),
              const Spacer(),
              PrimaryButton(title: 'vrify'.tr, onTap: () {
                context.goNamed(RouteName.resetPassword);
              }),
            ],
          ),
        ),
      ),
    );
  }
}