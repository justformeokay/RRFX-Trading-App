import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText {
  static Text titleHeadingPage(BuildContext context, {String? text}){ // untuk title page
    return Text(text ?? "Title", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center);
  }

  static Text titleSubHead(BuildContext context, {String? text}){ // untuk title lanjutan
    return Text(text ?? "Title", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center);
  }

  static Text titleMedium(BuildContext context, {String? text}){ // untuk title lanjutan
    return Text(text ?? "Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center);
  }

  static Text normal(BuildContext context, {String? text, TextAlign? align = TextAlign.center, bool? bold}){ // untuk title page
    return Text(text ?? "Title", style: GoogleFonts.openSans(fontSize: 16, fontWeight: bold == true ? FontWeight.w700 : FontWeight.normal), textAlign: align ?? TextAlign.center);
  }

  static Text underline(BuildContext context, {String? text, bool? bold}){ // untuk title page
    return Text(text ?? "Title", style: GoogleFonts.openSans(fontSize: 16, decoration: TextDecoration.underline, fontWeight: bold == true ? FontWeight.w700 : FontWeight.normal), textAlign: TextAlign.center);
  }
}