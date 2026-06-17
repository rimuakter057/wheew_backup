// import 'package:flutter/material.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
//
// class PlateDialog {
//   static Future<void> show(
//     BuildContext context,
//     String plate,
//   ) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.check_circle,
//               color: Colors.green,
//               size: 48,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "Scanned Number",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               plate,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.2,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//         Row(children: [
//           TextButton(
//             onPressed: () async {
//               // final result = await PlateDialog.verifyUser(
//               //   plateNumber: plateNumber, // তোমার plate variable
//               // );
//               //
//               // if (result) {
//               //   debugPrint("VERIFY SUCCESS");
//               // } else {
//               //   debugPrint("VERIFY FAILED");
//               // }
//             },
//             child: const Text(
//               "Verify",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//  SizedBox(width: ResponsiveHelper.width(4),),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               "OK",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],)
//         ],
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class PlateDialog {
  static Future<void> show(
      BuildContext context,
      String plate,
      Future<bool> Function(String plate) onVerify,
      ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Scanned Number",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              plate,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final result = await onVerify(plate);

                  Navigator.pop(context); // close loader
                  Navigator.pop(context); // close plate dialog

                  debugPrint(result ? "SUCCESS" : "FAILED");
                },
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(width: ResponsiveHelper.width(4)),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}