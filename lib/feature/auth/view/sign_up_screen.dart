// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:platchatapp/core/service/api_client.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/cypto_service.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/feature/privacy_policy/privacy_policy_screen.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../core/router/route_path.dart';
import '../../../core/router/routes_name.dart';
import '../../../core/service/api_checker.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/auth_controller.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../repository/auth_repository.dart';
import '../repository/country_list.dart';


Future<void> onSignupSuccess(String userId) async {
  final cryptoService = CryptoService();

  // Key pair জেনারেট + secure storage-এ সেভ
  final keyPair = await cryptoService.generateKeyPair();
  await cryptoService.savePrivateKey(keyPair);

  // Console-এ দেখার জন্য দুটো key প্রিন্ট করা
  final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
  final publicKey = await keyPair.extractPublicKey();

  print('===== KEY GENERATED =====');
  print('Private Key (base64): ${base64Encode(privateKeyBytes)}');
  print('Public Key (base64): ${base64Encode(publicKey.bytes)}');
  print('==========================');
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.find<AuthController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool agree = false;
  bool agreeTerms = false; // required
  bool? agreeOtherTerms; // optional (nullable)

  String? selectedDesignation;
  String? selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = "Italia";
    countryController.text = "Italia";
  }

  @override
  void dispose() {
    nicknameController.dispose();
    licenseController.dispose();
    passwordController.dispose();
    emailController.dispose();
    countryController.dispose();
    cityController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, size: ResponsiveHelper.iconSize(24)),
        ),
        title: Text(
          AppStrings.signUp.tr,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: ResponsiveHelper.fontSize(18),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: ResponsiveHelper.spacing(30)),

              /// Nickname
              CustomTextField(
                controller: nicknameController,
                title: AppStrings.nickName.tr,
                hintText: AppStrings.typeHere1.tr,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.toLowerCase());
                  }),
                ],

                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.nicknameIsRequired.tr
                    : null,
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Designation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.selectDesignation.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  DropdownButtonFormField2<String>(
                    value: selectedDesignation,
                    hint: Text(
                      AppStrings.select.tr,
                      style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                    ),
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(12),
                        vertical: ResponsiveHelper.padding(16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: ResponsiveHelper.borderWidth(1.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: ResponsiveHelper.borderWidth(2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: ResponsiveHelper.borderWidth(1.5),
                        ),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'owner',
                        child: Text(
                          AppStrings.owner.tr,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(16),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'occasional_driver',
                        child: Text(
                          AppStrings.occasionalDriver.tr,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(16),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedDesignation = value),
                    validator: (value) =>
                        value == null ? AppStrings.pleaseSelectDesignation.tr : null,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: ResponsiveHelper.height(160),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height: ResponsiveHelper.height(48),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(16),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// License Number
              CustomTextField(
                controller: licenseController,
                title: AppStrings.licenseNumber.tr,
                hintText: AppStrings.typeHere.tr,

                // validator: (value) {
                //   if (value == null || value.trim().isEmpty) {
                //     return 'License number is required';
                //   } else if (value.trim().length < 7) {
                //     return AppStrings.licenseNumberMustBe.tr;
                //   }
                //   return null;
                // },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.licenseNumberRequired.tr;
                  }

                  final text = value.trim();

                  // Check total length
                  if (text.length < 6 || text.length > 7) {
                    return AppStrings.licenseNumberMustBe.tr;
                  }

                  // Count letters and numbers
                  final letterCount = RegExp(
                    r'[A-Za-z]',
                  ).allMatches(text).length;

                  final numberCount = RegExp(r'[0-9]').allMatches(text).length;

                  if (letterCount < 3 || numberCount < 3) {
                    return AppStrings.licenceValidator.tr;
                  }

                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),
              /*CustomTextField(
                title: AppStrings.email.tr,
                hintText: AppStrings.emailOnlyForRecoverPassword.tr,
              )*/
              CustomTextField(
                controller: emailController,
                title: AppStrings.email.tr + " (" + AppStrings.onlyForRecovery.tr + ")",
                hintText: AppStrings.typeHere1.tr,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.emailIsRequired.tr;
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return AppStrings.enterValidEmail.tr;
                  }
                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Country
              // CustomTextField(
              //   controller: countryController,
              //   title: AppStrings.country.tr,
              //   hintText: AppStrings.typeHere.tr,
              //   validator: (value) => (value == null || value.trim().isEmpty)
              //       ? AppStrings.countryIsRequired.tr
              //       : null,
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.country.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  DropdownButtonFormField2<String>(
                    value: selectedCountry,
                    isExpanded: true,
                    hint: Text(
                      AppStrings.select.tr,
                      style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(12),
                        vertical: ResponsiveHelper.padding(16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    items: countries
                        .map(
                          (country) => DropdownMenuItem(
                            value: country,
                            child: Text(country, style: context.bodySmall),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value;
                        countryController.text = value ?? '';
                      });
                    },
                    validator: (value) =>
                        value == null ? AppStrings.countryIsRequired.tr : null,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// City
              CustomTextField(
                controller: cityController,
                title: "${AppStrings.city.tr} (${AppStrings.optional.tr})",
                hintText: AppStrings.typeHere.tr,

              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Password
              CustomTextField(
                controller: passwordController,
                title: AppStrings.password.tr,
                hintText: AppStrings.password.tr,
                isPassword: true,

                // validator: (value) {
                //   if (value == null || value.trim().isEmpty) {
                //     return AppStrings.passwordIsRequired.tr;
                //   } else if (value.trim().length < 6) {
                //     return AppStrings.passwordMustBe6Characters.tr;
                //   }
                //
                //   return null;
                // },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.passwordIsRequired.tr;
                  }

                  final password = value.trim();

                  if (password.length < 8) {
                    return AppStrings.passwordMustBeAtLeast8Characters.tr;
                  }

                  if (!RegExp(r'[A-Z]').hasMatch(password)) {
                    return AppStrings.passwordMustContainUppercase.tr;
                  }

                  if (!RegExp(r'[a-z]').hasMatch(password)) {
                    return AppStrings.passwordMustContainLowercase.tr;
                  }

                  if (!RegExp(r'[0-9]').hasMatch(password)) {
                    return AppStrings.passwordMustContainNumber.tr;
                  }

                  if (!RegExp(
                    r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\]~`]',
                  ).hasMatch(password)) {
                    return AppStrings.passwordMustContainSpecialCharacter.tr;
                  }

                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              /// Confirm Password
              CustomTextField(
                controller: confirmPasswordController,
                title: AppStrings.confirmPassword.tr,
                hintText: AppStrings.confirmPassword.tr,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.confirmYourPassword.tr;
                  } else if (value.trim().length < 6) {
                    return AppStrings.passwordMustBe6Characters.tr;
                  }
                  if (value != passwordController.text) {
                    return AppStrings.passwordDoNotMatch.tr;
                  }
                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(12)),

              /// Agree Terms
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ResponsiveHelper.width(24),
                    height: ResponsiveHelper.height(24),
                    child: Checkbox(
                      value: agree,
                      activeColor: Colors.green,
                      onChanged: (value) =>
                          setState(() => agree = value ?? false),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        children: [
                          TextSpan(
                            text: AppStrings.iAgreeTo.tr + ' ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                          TextSpan(
                            text: AppStrings.termsAndConditions.tr,
                            style: GoogleFonts.poppins(
                              color: AppColors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: ResponsiveHelper.fontSize(14),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Privacy Policy link open
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WebViewScreen(url: ApiUrl.terms),
                                  ),
                                );
                              },
                          ),

                          TextSpan(
                            text: AppStrings.and.tr,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: AppStrings.privacyPolicy.tr,
                            style: GoogleFonts.poppins(
                              color: AppColors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: ResponsiveHelper.fontSize(14),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Privacy Policy link open
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PrivacyPolicyScreen(
                                      url: ApiUrl.privacy,
                                    ),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),

              SizedBox(height: ResponsiveHelper.spacing(20)),

              PrimaryButton(
                title: AppStrings.continueText.tr,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) {
                    showErrorSnackBar(AppStrings.pleaseFillAllFields.tr);
                    return;
                  }

                  if (selectedDesignation == null) {
                    showErrorSnackBar(AppStrings.pleaseSelectDesignation.tr);
                    return;
                  }

                  if (!agree) {
                    showWarningSnackBar(AppStrings.pleaseAcceptTerms.tr);
                    return;
                  }

                  showLoadingDialog(
                    message: AppStrings.creatingAccount.tr,
                    context: context,
                  );

                  try {
                    final response = await AuthRepository().register(
                      licenceId: licenseController.text.trim(),
                      nickName: nicknameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      confirmPassword: confirmPasswordController.text.trim(),
                      designation: selectedDesignation!,
                      country: selectedCountry ?? '',
                      city: cityController.text.trim(),
                    );

                    developer.log(
                      'Register Result -> code: ${response.statusCode}, body: ${response.body}',
                      name: 'SIGNUP',
                    );

                    if (!context.mounted) return;

                    hideLoadingDialog(context);

                    final Map<String, dynamic>? body = response.body.isNotEmpty
                        ? jsonDecode(response.body) as Map<String, dynamic>
                        : null;

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      final token = body?['token'];

                      if (token != null && token.toString().isNotEmpty) {
                        await SharePrefsHelper.setString(
                          AppConst.token,
                          token.toString(),
                        );
                      }

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Registration successful'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );



                      final cryptoService = CryptoService();

                      // Key pair জেনারেট + secure storage-এ সেভ
                      final keyPair = await cryptoService.generateKeyPair();
                      await cryptoService.savePrivateKey(keyPair);

                      // Console-এ দেখার জন্য দুটো key প্রিন্ট করা
                      final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
                      final publicKey = await keyPair.extractPublicKey();

                      print('===== KEY GENERATED =====');
                      print('Private Key (base64)==================: ${base64Encode(privateKeyBytes)}');
                      print('Public Key (base64)====================: ${base64Encode(publicKey.bytes)}');
                      print('==========================');

                      final publicKeyBase64 = base64Encode(publicKey.bytes);
                      _registerDeviceKey(publicKeyBase64);

                      context.go(RoutePath.vehicle);
                      return;
                    }

                    final message =
                        body?['message']?.toString() ??
                        'Request failed (${response.statusCode})';

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                  } on TimeoutException {
                    if (!context.mounted) return;

                    hideLoadingDialog(context);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Server is not responding. Please check your connection.',
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  } on SocketException {
                    if (!context.mounted) return;

                    hideLoadingDialog(context);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No internet connection. Please check your network.',
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  } on FormatException {
                    if (!context.mounted) return;

                    hideLoadingDialog(context);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Unexpected server response.'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  } catch (e, st) {
                    developer.log('Register Exception: $e', name: 'SIGNUP');
                    developer.log('StackTrace: $st', name: 'SIGNUP');

                    if (!context.mounted) return;

                    hideLoadingDialog(context);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                  }
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(8)),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: AppStrings.alreadyAccount1.tr),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteName.signIn);
                          },
                          child: Text(
                            AppStrings.signIn.tr,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(14),
                              color: AppColors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _handleSignUp() async {
  //   if (!_formKey.currentState!.validate()) {
  //     showErrorSnackBar('Please fill all fields');
  //     return;
  //   }

  //   if (!agree) {
  //     showErrorSnackBar('Please accept terms');
  //     return;
  //   }

  //   final success = await authController.registerAndLogin(
  //     context: context,
  //     licenceId: licenseController.text.trim(),
  //     nickName: nicknameController.text.trim(),
  //     password: passwordController.text.trim(),
  //     confirmPassword: confirmPasswordController.text.trim(),
  //     designation: selectedDesignation!,
  //   );

  //   if (success && context.mounted) {
  //     showSuccessToast('Registration successful!');
  //     context.goNamed(RouteName.signIn);
  //   }
  // }

  void showWarningSnackBar(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _registerDeviceKey(String publicKeyBase64) async {
    try {
      print('🔑 Device Key Registration Started...');
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = 'unknown_device';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
      }
      
      print('📱 Device ID: $deviceId');
      print('🔑 Public Key Base64: $publicKeyBase64');

      final response = await ApiClient.postData(
        uri: '/chat/e2ee/device-key',
        body: {
          'deviceId': deviceId,
          'publicKey': publicKeyBase64,
        },
      );

      print('📡 Device Key API Response Code: ${response.statusCode}');
      print('📡 Device Key API Response Body: ${response.body}');
    } catch (e, stackTrace) {
      print('❌ Failed to register device key silently: $e');
      print(stackTrace);
    }
  }
}
