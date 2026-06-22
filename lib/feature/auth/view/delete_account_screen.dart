import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../share/widgets/custom_appbar/custom_appbar.dart';
import '../../../share/widgets/text_field/custom_text_field.dart';
import '../repository/auth_controller.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (_formKey.currentState!.validate()) {
      await authController.deleteAccount(
        context: context,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title:AppStrings.deleteAccount.tr),
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ResponsiveHelper.spacing(20)),

                    /// Warning Box
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: ResponsiveHelper.fontSize(20),
                              ),
                              SizedBox(width: ResponsiveHelper.spacing(8)),
                              Text(
                                AppStrings.warning.tr,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: ResponsiveHelper.fontSize(15),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveHelper.spacing(8)),
                          Text(
                            AppStrings.deleteAccountWarning.tr,
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade700,
                              fontSize: ResponsiveHelper.fontSize(13),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(30)),

                    /// Password Field
                    CustomTextField(
                      controller: _passwordController,
                      title: AppStrings.password.tr,
                      hintText: AppStrings.typeHere.tr,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.passwordIsRequired.tr;
                        }
                        if (value.length < 6) {
                          return AppStrings.passwordMustBe6Characters.tr;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: ResponsiveHelper.spacing(30)),

                    /// Delete Button
                    Obx(
                      () => controller.isLoadingDeleteAccount.value
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              title: AppStrings.delete.tr,
                              onTap: _handleDelete,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
