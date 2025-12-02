import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';

class SimpleUtilities {
  static final List<Map<String, dynamic>> listType = [
    {
      "name" : "Floating",
      "spread" : 6,
      "follow_usd_course" : false,
      "leverage" : "1:500"
    },
    {
      "name" : "Fixed",
      "spread" : 10,
      "follow_usd_course" : false,
      "leverage" : "1:500"
    },
    {
      "name" : "Random",
      "spread" : 12,
      "follow_usd_course" : true,
      "leverage" : "1:700"
    },
  ];

  static Padding titleCreateReal(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageGlobalVar.CREATE_TRADING_ACCOUNT.tr, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(LanguageGlobalVar.SELECT_TRADING_ACCOUNT.tr, style: GoogleFonts.inter(fontSize: 14, color: CustomColor.textThemeLightSoftColor))
        ],
      ),
    );
  }

  static Padding tileAccount({Function()? onPressed, String? title, bool? selected, String? spread}){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: selected == true ? null : Border.all(color: CustomColor.textThemeDarkSoftColor),
            borderRadius: BorderRadius.circular(16.0),
            color: selected == true ? CustomColor.backgroundIcon : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(5),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selected == true ? CustomColor.defaultColor : CustomColor.textThemeDarkSoftColor,
                  border: Border.all(color: CustomColor.textThemeDarkSoftColor),
                  shape: BoxShape.circle
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(title ?? "Unknown Type", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: CustomColor.textThemeLightSoftColor)),
                  const SizedBox(height: 4),
                  Text("Spread mulai dari $spread point", style: GoogleFonts.inter(fontSize: 12, color: CustomColor.defaultColor))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Container cardInfoAccountType({Size? size, String? first, String? second, String? third}){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: CustomColor.backgroundIcon,
        borderRadius: BorderRadius.circular(16.0)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageGlobalVar.WHAT_WILL_WE_GET.tr, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16.0)),
          const SizedBox(height: 16.0),
          itemContent(text: "${LanguageGlobalVar.LEVERAGE_START_FROM}$first"),
          itemContent(text: second),
          itemContent(text: third),
        ],
      ),
    );
  }

  static Padding itemContent({String? text}){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: CustomColor.defaultColor),
          const SizedBox(width: 10),
          Text(text ?? "Not Unknown Data", style: GoogleFonts.inter(fontSize: 12, color: CustomColor.textThemeDarkSoftColor), maxLines: 1)
        ],
      ),
    );
  }
}
