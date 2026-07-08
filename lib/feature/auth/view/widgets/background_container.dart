// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class CustomBackgroundContainer extends StatelessWidget {
//   final Widget child;
//
//   const CustomBackgroundContainer({Key? key, required this.child}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(32.0), // কন্টেইনারের রাউন্ডেড কর্নার
//       child: BackdropFilter(
//         // ব্যাকগ্রাউন্ড ব্লার করার জন্য (Frosted Glass Effect)
//         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//         child: Container(
//           padding: const EdgeInsets.all(24.0),
//           decoration: BoxDecoration(
//             // হালকা সাদাটে ও স্বচ্ছ ব্যাকগ্রাউন্ড কালার
//             color: Color(0xFFCDD6E5),
//             borderRadius: BorderRadius.circular(32.0),
//       border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
//
//             // হালকা শ্যাডো ইফেক্ট
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: child, // এর ভেতরে আপনার Vehicle Model এবং Colors এর উইজেটগুলো বসবে
//         ),
//       ),
//     );
//   }
// }


import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBackgroundContainer extends StatelessWidget {
  final Widget child;

  const CustomBackgroundContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32.0);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.1),
          color: const Color(0xFFCDD6E5),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            // ভুলটি এখানে সংশোধন করা হয়েছে: Border.all এর বদলে BorderSide ব্যবহার করা হয়েছে
            side: BorderSide(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }
}