import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';

class StepUtilities {
  static Padding stepOnlineRegister({required Size size, int? progressStart, int? progressEnd, String? title, Function()? onPressed, int? currentAllPageStatus = 1}){
    return Padding(
      padding: const EdgeInsets.only(bottom: 35, top: 5, left: 12, right: 12),
      child: SizedBox(
        height: size.width / 3.2,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Progress", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("$progressStart/$progressEnd", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold))
                  ],
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title ?? "Title", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("$currentAllPageStatus/3", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14))
                    ],
                  )
                )
              ],
            ),
            SizedBox(
              width: size.width,
              child: DefaultButton.defaultElevatedButton(
                  onPressed: onPressed,
                  title: LanguageGlobalVar.SELANJUTNYA.tr
              ),
            ),
          ],
        ),
      ),
    );
  }
}