import 'package:flutter/cupertino.dart';
import 'package:rrfx/src/components/colors/default.dart';

class CustomPhoneSelector {
  static GestureDetector phoneCodeSelector({Function()? onTap, String? selectedPhone}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 70,
        height: 56,
        // padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColor.textThemeDarkSoftColor)
        ),
        child: Text("+$selectedPhone"),
      ),
    );
  }
}