import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelTextField {
  static Column labelName({String? label, Widget? child, bool? required}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label ?? "Name", style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 12
            )),
            if (required == true)
              Text(" *", style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: CupertinoColors.systemRed,
              )),
          ],
        ),
        const SizedBox(height: 8),
        child ?? const SizedBox()
      ],
    );
  }
}