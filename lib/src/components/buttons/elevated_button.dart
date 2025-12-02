import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class DefaultButton {
  static Padding defaultElevatedButton({String? title, Function()? onPressed}){
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            overlayColor: CustomColor.backgroundLightColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            backgroundColor: CustomColor.secondaryColor,
          ),
          child: Text(title ?? "Submit", style: GoogleFonts.inter(
          color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold
          ))
        ),
      ),
    );
  }

  static Padding defaultElevatedButtonIcon({String? title, Function()? onPressed, String? urlIcon}){
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            overlayColor: CustomColor.backgroundLightColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.black12)
            ),
            backgroundColor: Colors.white,
          ),
          icon: Image.asset(urlIcon ?? 'assets/images/logo-rrfx-2.png', width: 20),
          label: Text(title ?? "Submit", style: GoogleFonts.inter(
          color: CustomColor.textThemeLightSoftColor,
            fontSize: 14,
            fontWeight: FontWeight.bold
          ))
        ),
      ),
    );
  }
}