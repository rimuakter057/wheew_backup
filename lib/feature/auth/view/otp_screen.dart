import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/share/widgets/button/primary_button.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/color/app_colors.dart';


class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthController controller = AuthController();
  bool hasError = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint("==============================${widget.email}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'verification_code'.tr),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.padding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'enter_verification_code'.tr,
                style: TextStyle(fontSize: ResponsiveHelper.fontSize(16),),
              ),
              SizedBox(height: ResponsiveHelper.height(16),),
              Text('we_sent_6_digit_code'.tr, style: TextStyle(fontSize: ResponsiveHelper.fontSize(14),)),

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
                  fieldHeight:ResponsiveHelper.iconSize(52),
                  fieldWidth: ResponsiveHelper.iconSize(52),

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
                  fontSize: ResponsiveHelper.fontSize(16)
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
              PrimaryButton(
                title: 'send'.tr,

                //     onTap: () {
                //   context.pushNamed(RouteName.resetPassword);
                // },
                onTap: () async {
                  if (_otpController.text.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("otp_required".tr)));
                    return;
                  }

                  final otpToken = await controller.verifyOtp(
                    email: widget.email,
                    otp: _otpController.text,
                    context: context,
                  );

                  if (otpToken != null) {
                    // Navigate with token
                    context.pushNamed(
                      RouteName.resetPassword,
                      extra: {"otpToken": otpToken, "email": widget.email},
                    );
                    _otpController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
