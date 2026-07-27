// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:platchatapp/utils/language/app_string.dart';
// import '../../../helper/responsive_helper/responsive_helper.dart';
// import '../../../share/widgets/button/primary_button.dart';
// import '../../../share/widgets/custom_appbar/custom_appbar.dart';
// import '../../../share/widgets/text_field/custom_text_field.dart';
// import '../repository/auth_controller.dart';
//
// class DeleteAccountScreen extends StatefulWidget {
//   const DeleteAccountScreen({super.key});
//
//   @override
//   State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
// }
//
// class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
//   final AuthController authController = Get.find<AuthController>();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleDelete() async {
//     if (_formKey.currentState!.validate()) {
//       await authController.deleteAccount(
//         context: context,
//         password: _passwordController.text,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar(title:AppStrings.deleteAccount.tr),
//       body: GetBuilder<AuthController>(
//         builder: (controller) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: ResponsiveHelper.spacing(20)),
//
//                     /// Warning Box
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.red.shade200),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.warning_amber_rounded,
//                                 color: Colors.red,
//                                 size: ResponsiveHelper.fontSize(20),
//                               ),
//                               SizedBox(width: ResponsiveHelper.spacing(8)),
//                               Text(
//                                 AppStrings.warning.tr,
//                                 style: GoogleFonts.poppins(
//                                   color: Colors.red,
//                                   fontSize: ResponsiveHelper.fontSize(15),
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: ResponsiveHelper.spacing(8)),
//                           Text(
//                             AppStrings.deleteAccountWarning.tr,
//                             style: GoogleFonts.poppins(
//                               color: Colors.red.shade700,
//                               fontSize: ResponsiveHelper.fontSize(13),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     SizedBox(height: ResponsiveHelper.spacing(30)),
//
//                     /// Password Field
//                     CustomTextField(
//                       controller: _passwordController,
//                       title: AppStrings.password.tr,
//                       hintText: AppStrings.typeHere.tr,
//                       isPassword: true,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return AppStrings.passwordIsRequired.tr;
//                         }
//                         if (value.length < 6) {
//                           return AppStrings.passwordMustBe6Characters.tr;
//                         }
//                         return null;
//                       },
//                     ),
//
//                     SizedBox(height: ResponsiveHelper.spacing(30)),
//
//                     /// Delete Button
//                     Obx(
//                       () => controller.isLoadingDeleteAccount.value
//                           ? const Center(child: CircularProgressIndicator())
//                           : PrimaryButton(
//                               title: AppStrings.delete.tr,
//                               onTap: _handleDelete,
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/profile/view/screens/profile_screen.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../helper/custom_gradient_button/custom_gradient_button.dart';
import '../../../helper/custom_image/custom_image.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../../../utils/assets_path/assets_path.dart';
import '../repository/auth_controller.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleDelete() async {
    if (_formKey.currentState!.validate()) {
      await authController.deleteAccount(
        context: context,
        password: authController.passwordController.text,
      );
    }
  }

  TextStyle get _titleStyle => GoogleFonts.poppins(
    fontSize: ResponsiveHelper.fontSize(14),
    fontWeight: FontWeight.w600,
    color: const Color(0xff292929),
  );

  TextStyle get _subTitleStyle => GoogleFonts.poppins(
    fontSize: ResponsiveHelper.fontSize(11),
    fontWeight: FontWeight.w400,
    color: const Color(0xff626873),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient

        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(20),
                    vertical: ResponsiveHelper.padding(16),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          height: ResponsiveHelper.height(46),
                          width: ResponsiveHelper.width(46),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xff4B525B),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            AppStrings.deleteAccount.tr,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(19),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff292929),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.width(46),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.padding(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: ResponsiveHelper.spacing(10),
                        ),

                        /// Warning
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xffF04438),
                              size: 19,
                            ),
                            SizedBox(
                              width: ResponsiveHelper.spacing(8),
                            ),
                            Expanded(
                              child: Text(
                                AppStrings.warning.tr,
                                style: context.bodyLarge.copyWith(color: AppColors.red,fontWeight: FontWeight.w600)
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: ResponsiveHelper.spacing(5),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: ResponsiveHelper.padding(27),
                          ),
                          child: Text(
                            AppStrings.deleteAccountWarning.tr,
                            style: GoogleFonts.poppins(
                              color: const Color(0xff626873),
                              fontSize: ResponsiveHelper.fontSize(11),
                              height: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.spacing(42),
                        ),

                        Text(
                          'What happens when you delete',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff292929),
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.spacing(10),
                        ),

                        /// Information Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.padding(16),
                            vertical: ResponsiveHelper.padding(8),
                          ),
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(25),
                            gradient: AppColors.containerGradient,
                            border: Border.all(color: AppColors.white)

                          ),
                          child: Column(
                            children: [
                              _buildDeleteInfo(
                                icon: AssetsPath.allBooking,
                                title: 'All Your Bookings',
                                subtitle:
                                'Your current and past bookings will be removed',
                              ),
                              _buildDivider(),
                              _buildDeleteInfo(
                                icon: AssetsPath.payment,
                                title: 'Payment Methods',
                                subtitle:
                                'Saved payment methods will be deleted',
                              ),
                              _buildDivider(),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ProfileScreen()),
                                  );
                                },
                                child: _buildDeleteInfo(
                                  icon: AssetsPath.personal,
                                  title: 'Personal Information',
                                  subtitle:
                                  'Your profile and personal information will be erased',
                                ),
                              ),
                              _buildDivider(),
                              _buildDeleteInfo(
                                icon: AssetsPath.accountRecovery,
                                title: 'Account Recovery',
                                subtitle:
                                'You won’t be able to access your account again',
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.spacing(42),
                        ),

                        /// Password
                        CustomTextField(
                          controller: authController.passwordController,
                          title: AppStrings.password.tr,
                          hintText: AppStrings.enterYourPassword.tr,
                          isPassword: true,
                          fillColor: Colors.white.withOpacity(0.55),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.padding(16),
                            vertical: ResponsiveHelper.padding(16),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: ResponsiveHelper.width(40),
                            minHeight: ResponsiveHelper.height(16),
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: ResponsiveHelper.padding(14),
                              right: ResponsiveHelper.padding(8),
                            ),
                            child: CustomImage(
                              imageSrc: AssetsPath.passwordLogin,
                              width: ResponsiveHelper.iconSize(16),
                              height: ResponsiveHelper.iconSize(16),
                            ),
                          ),
                          // border: _fieldBorder(Colors.transparent, 1),
                          // enabledBorder: _fieldBorder(Colors.transparent, 1),
                          // focusedBorder: _fieldBorder(AppColors.blue, 1.5),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppStrings.passwordIsRequired.tr;
                            }
                            if (value.length < 6) {
                              return AppStrings.passwordMust6Character.tr;
                            }
                            return null;
                          },
                        ),

                        SizedBox(
                          height: ResponsiveHelper.spacing(10),
                        ),

                        /// Security Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xff2468C5),
                              size: 18,
                            ),
                            SizedBox(
                              width: ResponsiveHelper.spacing(7),
                            ),
                            Expanded(
                              child: Text(
                                'For security reasons, please enter your password to confirm account deletion.',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xff2468C5),
                                  fontSize: ResponsiveHelper.fontSize(10),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: ResponsiveHelper.spacing(20),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Delete Button
                Padding(
                  padding: EdgeInsets.only(
                    left: ResponsiveHelper.padding(20),
                    right: ResponsiveHelper.padding(20),
                    bottom: ResponsiveHelper.padding(20),
                  ),
                  child: Obx(
                    () => CustomGradientButton(
                      isLoading: authController.isLoadingDeleteAccount.value,
                      onPressed: _handleDelete,
                      gradient: AppColors.redGradient,
                      borderColor: const Color(0xFF6B1607),
                      shadowColor: Colors.black26,
                      prefixIcon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 19,
                      ),
                      label: AppStrings.deleteAccount.tr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteInfo({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.padding(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xff2468C5),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.spacing(14),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _titleStyle,
                ),
                SizedBox(
                  height: ResponsiveHelper.spacing(2),
                ),
                Text(
                  subtitle,
                  style: _subTitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.black.withOpacity(0.2),
    );
  }
}
