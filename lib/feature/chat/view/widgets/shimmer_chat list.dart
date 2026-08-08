import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(8)),
          child: Shimmer.fromColors(
            baseColor: AppColors.grey[300]!,
            highlightColor: AppColors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // first Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildSkeleton(
                          ResponsiveHelper.width(25),
                          ResponsiveHelper.height(25),
                        ),
                        SizedBox(width: ResponsiveHelper.width(8)),
                        _buildSkeleton(
                          ResponsiveHelper.width(150),
                          ResponsiveHelper.height(10),
                        ),
                      ],
                    ),
                    SizedBox(width: ResponsiveHelper.width(8)),
                    _buildSkeleton(
                      ResponsiveHelper.width(60),
                      ResponsiveHelper.height(20),
                    ),
                  ],
                ),
                Gap(ResponsiveHelper.height(12)),

                // 2nd Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSkeleton(
                      ResponsiveHelper.width(80),
                      ResponsiveHelper.height(10),
                    ),
                    SizedBox(width: ResponsiveHelper.width(8)),
                    _buildSkeleton(
                      ResponsiveHelper.width(80),
                      ResponsiveHelper.height(10),
                    ),
                  ],
                ),
                Gap(ResponsiveHelper.height(8)),

                // line
                _buildSkeleton(double.infinity, ResponsiveHelper.height(14)),

                Gap(8.h),
                _buildSkeleton(
                  ResponsiveHelper.width(200),
                  ResponsiveHelper.height(14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(double width, double height, {bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
        color: AppColors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}



