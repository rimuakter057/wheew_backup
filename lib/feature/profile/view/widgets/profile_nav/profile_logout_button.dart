import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/routes_name.dart';
import '../../../../../core/service/storage_service.dart';
import '../../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../../utils/app_const/app_const.dart';


Widget buildLogoutButton( {required BuildContext context}) {
  return SizedBox(
    width: double.infinity,
    height: ResponsiveHelper.buttonHeight(55),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFEBEE),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(30),
          ),
        ),
      ),
      onPressed: () async {
        await SharePrefsHelper.remove(AppConst.token);
        await SharePrefsHelper.remove(AppConst.userID);
        await SharePrefsHelper.remove(AppConst.userData);
        await SharePrefsHelper.remove(AppConst.licenceId);
        await SharePrefsHelper.remove(AppConst.nickName);
        await SharePrefsHelper.remove(AppConst.avatar);
        await SharePrefsHelper.remove(AppConst.loginUser);
        await SharePrefsHelper.remove(AppConst.loginPass);
        await SharePrefsHelper.remove(AppConst.licenseNoVerified);
        await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);

        context.goNamed(RouteName.welcome);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: Colors.redAccent,
            size: ResponsiveHelper.iconSize(20),
          ),
          SizedBox(width: ResponsiveHelper.spacing(10)),
          Text(
            'log_out'.tr,
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: ResponsiveHelper.fontSize(16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}