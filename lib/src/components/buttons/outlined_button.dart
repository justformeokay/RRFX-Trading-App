import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class CustomOutlinedButton {
  static SizedBox defaultOutlinedButton({Function()? onPressed, String? title}){
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          elevation: 0,
          overlayColor: CustomColor.secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0)
          ),
          side: BorderSide(
            color: CustomColor.secondaryColor
          )
        ),
        child: Text(title ?? "Submit", textAlign: TextAlign.center, style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: CustomColor.secondaryColor
        ))
      ),
    );
  }
}