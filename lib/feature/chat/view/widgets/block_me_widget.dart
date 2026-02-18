import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';



class BlockMeWidget extends StatelessWidget {
  const BlockMeWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      padding:  ResponsiveHelper.all(16),

      margin:  ResponsiveHelper.all(12),

      decoration: BoxDecoration(

        color: Colors.grey.shade200,

        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),

      ),

      child:  Row(

        children: [

          Icon(
            Icons.lock,
            color: Colors.grey,
          ),

          SizedBox(width: ResponsiveHelper.spacing(10)),

          Expanded(
            child: Text(
              "You can't send message to this user",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:GoogleFonts.poppins (
                  fontSize: ResponsiveHelper.fontSize(14),
                  fontWeight: FontWeight.w500
              ),
            ),
          ),

        ],

      ),

    );

  }

}