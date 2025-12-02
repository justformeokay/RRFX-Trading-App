import 'package:flutter/material.dart';
import 'package:rrfx/src/components/colors/default.dart';

class BackgroundColor {
  static Container defaultBackground(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CustomColor.secondaryColor.withValues(alpha: 0.5),
            CustomColor.secondaryColor.withValues(alpha: 0.3),
            CustomColor.secondaryColor.withValues(alpha: 0.2),
            // CustomColor.secondaryBackground,
          ]
        )
      ),
    );
  }
}