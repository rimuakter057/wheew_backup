import 'package:flutter/material.dart';



class MyQrView extends StatelessWidget {
  const MyQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 240,
            height: 240,
            color: Colors.white,
            child: const Icon(Icons.qr_code_2, size: 150),
          ),

          const SizedBox(height: 20),

          const Text("Show this QR to connect"),
        ],
      ),
    );
  }
}