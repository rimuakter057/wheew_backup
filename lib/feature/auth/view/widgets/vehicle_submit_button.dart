import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// "Submit Details" বাটন — লোডিং স্টেট, গ্রাডিয়েন্ট এবং Card উইজেট সহ
class VehicleSubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  const VehicleSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isLoading || onPressed == null;
    final borderRadius = BorderRadius.circular(ResponsiveHelper.borderRadius(30));
// এখানে আপনার ৩টি কালার কোড বসিয়ে নিন (উদাহরণস্বরূপ নিচে দেওয়া হলো)
    final Color color1 = const Color(0xFF0C7DC9); // ১ম কালার (গ্রাডিয়েন্ট শুরু)
    final Color color2 = const Color(0xFF014495); // ২য় কালার (গ্রাডিয়েন্ট মাঝখানে/শেষে)
    final Color shadowColor = const Color(0xFF6FB1FC); // ৩য় কালার (শ্যাডো-র জন্য)
    return Card(

      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // গ্রাডিয়েন্ট যেন কার্ডের রাউন্ড শেপের বাইরে না যায়
      elevation: 6, // কার্ডের সুন্দর থ্রিডি শ্যাডো
      shadowColor: AppColors.blue.withOpacity(0.5), // ইমেজের মতো ব্লু শেডের শ্যাডো
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Ink(
        width: double.infinity,
        height: ResponsiveHelper.buttonHeight(54),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          // বাটনের সুন্দর গ্রাডিয়েন্ট ব্যাকগ্রাউন্ড
          gradient: isButtonDisabled
              ? null
              : LinearGradient(
            colors: [
              color1,
              color2,
              color1,// সলিড ব্লু (ডানপাশে)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: isButtonDisabled ? Colors.grey.shade400 : null,
        ),
        child: InkWell(
          onTap: isButtonDisabled ? null : onPressed,
          splashColor: Colors.white24,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}