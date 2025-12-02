import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelTextField {
  static Column labelName({String? label, Widget? child}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label ?? "Name", style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 12
        )),
        const SizedBox(height: 8),
        child ?? const SizedBox()
      ],
    );
  }
}