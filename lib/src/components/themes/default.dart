import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class CustomTheme{

  // ======== Main Default Theme ==========
  static ThemeData defaultLightTheme(){
    return ThemeData(
      appBarTheme: defaultAppbarThemeLight(),
      iconTheme: defaultIconThemeDataLight(),
      scaffoldBackgroundColor: CustomColor.backgroundLightColor,
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStatePropertyAll(Colors.white),
        shape: CircleBorder(),
        overlayColor: WidgetStatePropertyAll(CustomColor.secondaryBackground),
        fillColor: WidgetStatePropertyAll(CustomColor.secondaryColor)
      ),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.accent,
        colorScheme: ColorScheme.highContrastDark()
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CustomColor.secondaryColor,
        selectionColor: CustomColor.secondaryBackground,
        selectionHandleColor: CustomColor.secondaryColor
      ),
      colorScheme: ColorScheme.light(),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(CustomColor.secondaryColor)
      ),
      segmentedButtonTheme: defaultSegmentedButtonLight(),
      elevatedButtonTheme: defaultElevatedButtonTheme(),
      brightness: Brightness.light,
      useMaterial3: true,
        textTheme: TextTheme(
            bodyLarge: GoogleFonts.inter(color: Colors.black),
          bodyMedium: GoogleFonts.inter(color: Colors.black54),
          bodySmall: GoogleFonts.inter(color: Colors.black45),
          titleLarge: GoogleFonts.inter(color: Colors.black),
          titleMedium: GoogleFonts.inter(color: Colors.black54),
          titleSmall: GoogleFonts.inter(color: Colors.black45),
          displayLarge: GoogleFonts.inter(color: Colors.black),
          displayMedium: GoogleFonts.inter(color: Colors.black54),
          displaySmall: GoogleFonts.inter(color: Colors.black45),
        ),
      dividerTheme: defaultDividerThemeDark(),
      iconButtonTheme: defaultIconButtonThemeLight()
      // textButtonTheme: defaultTextButtonThemeData()
    );
  }

  static ThemeData defaultDarkTheme(){
    return ThemeData(
      appBarTheme: defaultAppbarThemeDark(),
      scaffoldBackgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      colorScheme: ColorScheme.dark(),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStatePropertyAll(Colors.white),
        overlayColor: WidgetStatePropertyAll(CustomColor.defaultSoftColor),
        shape: CircleBorder(),
        fillColor: WidgetStatePropertyAll(CustomColor.secondaryColor)
      ),
      buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.accent,
          colorScheme: ColorScheme.highContrastDark()
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CustomColor.secondaryColor,
        selectionColor: CustomColor.secondaryBackground,
        selectionHandleColor: CustomColor.secondaryColor
      ),
      radioTheme: RadioThemeData(
          fillColor: WidgetStatePropertyAll(CustomColor.secondaryColor)
      ),
      elevatedButtonTheme: defaultElevatedButtonTheme(),
      segmentedButtonTheme: defaultSegmentedButtonDark(),
      brightness: Brightness.dark,
      useMaterial3: true,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.inter(color: Colors.white),
        bodyMedium: GoogleFonts.inter(color: Colors.white70),
        bodySmall: GoogleFonts.inter(color: Colors.white60),
        titleLarge: GoogleFonts.inter(color: Colors.white),
        titleMedium: GoogleFonts.inter(color: Colors.white70),
        titleSmall: GoogleFonts.inter(color: Colors.white60),
        displayLarge: GoogleFonts.inter(color: Colors.white),
        displayMedium: GoogleFonts.inter(color: Colors.white70),
        displaySmall: GoogleFonts.inter(color: Colors.white60),
      ),
      dividerTheme: defaultDividerThemeDark(),
      iconButtonTheme: defaultIconButtonThemeDark()
      // textButtonTheme: defaultTextButtonThemeData()
    );
  }

  // ======== Start Appbar Theme Section ==========
  static AppBarTheme defaultAppbarThemeLight(){
    return AppBarTheme(
      actionsIconTheme: defaultIconThemeDataLight(),
      foregroundColor: CustomColor.textThemeDarkColor,
      iconTheme: IconThemeData(
        color: CustomColor.textThemeLightColor
      ),
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: CustomColor.textThemeLightColor),
    );
  }

  static AppBarTheme defaultAppbarThemeDark(){
    return AppBarTheme(
      actionsIconTheme: defaultIconThemeDataDark(),
      foregroundColor: CustomColor.textThemeDarkColor,
      iconTheme: IconThemeData(
        color: CustomColor.textThemeDarkColor
      ),
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
  // ======== End Appbar Theme Section ==========


  // ======== Start Icon Theme Section ==========
  static IconThemeData defaultIconThemeDataLight(){
    return IconThemeData(
      color: CustomColor.secondaryColor,
    );
  }

  static IconThemeData defaultIconThemeDataDark(){
    return IconThemeData(
      color: CustomColor.backgroundDarkColor,
    );
  }
  // ======== End Appbar Theme Section ==========


  // ======== Start Icon Theme Section ==========
  static IconButtonThemeData defaultIconButtonThemeLight(){
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        elevation: 0,
        foregroundColor: CustomColor.textThemeLightColor
      )
    );
  }

  static IconButtonThemeData defaultIconButtonThemeDark(){
    return IconButtonThemeData(
        style: IconButton.styleFrom(
          elevation: 0,
          foregroundColor: CustomColor.textThemeDarkColor
        )
    );
  }
  // ======== End Appbar Theme Section ==========

  // ======== Start ElevatedButtonThemeData Section ==========
  static ElevatedButtonThemeData defaultElevatedButtonTheme(){
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        elevation: 0,
        backgroundColor: CustomColor.secondaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
        ),
        iconColor: CustomColor.textThemeLightColor,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: CustomColor.backgroundLightColor
        )
      )
    );
  }
  // ======== End ElevatedButtonThemeData Section ==========

  // ======== Start ElevatedButtonThemeData Section ==========
  static DividerThemeData defaultDividerThemeLight(){
    return DividerThemeData(
      color: CustomColor.backgroundIcon
    );
  }

  static DividerThemeData defaultDividerThemeDark(){
    return DividerThemeData(
        color: CustomColor.textThemeDarkSoftColor
    );
  }
// ======== End ElevatedButtonThemeData Section ==========

  // ======== Start ElevatedButtonThemeData Section ==========
  static SegmentedButtonThemeData defaultSegmentedButtonDark(){
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStatePropertyAll(BorderSide(color: CustomColor.secondaryColor)),
        textStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: CustomColor.textThemeDarkSoftColor)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CustomColor.backgroundIconSoftDark;
          }
          return Colors.transparent;
        }),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }

  static SegmentedButtonThemeData defaultSegmentedButtonLight(){
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStatePropertyAll(BorderSide(color: CustomColor.secondaryColor)),
        textStyle: WidgetStatePropertyAll(GoogleFonts.inter()),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CustomColor.backgroundIcon;
          }
          return Colors.transparent;
        }),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }
// ======== End ElevatedButtonThemeData Section ==========
}