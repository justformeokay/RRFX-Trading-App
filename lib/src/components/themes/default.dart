import 'package:flutter/material.dart';
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
            bodyLarge: TextStyle(color: Colors.black, fontFamily: 'system'),
          bodyMedium: TextStyle(color: Colors.black54, fontFamily: 'system'),
          bodySmall: TextStyle(color: Colors.black45, fontFamily: 'system'),
          titleLarge: TextStyle(color: Colors.black, fontFamily: 'system'),
          titleMedium: TextStyle(color: Colors.black54, fontFamily: 'system'),
          titleSmall: TextStyle(color: Colors.black45, fontFamily: 'system'),
          displayLarge: TextStyle(color: Colors.black, fontFamily: 'system'),
          displayMedium: TextStyle(color: Colors.black54, fontFamily: 'system'),
          displaySmall: TextStyle(color: Colors.black45, fontFamily: 'system'),
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
        bodyLarge: TextStyle(color: Colors.white, fontFamily: 'system'),
        bodyMedium: TextStyle(color: Colors.white70, fontFamily: 'system'),
        bodySmall: TextStyle(color: Colors.white60, fontFamily: 'system'),
        titleLarge: TextStyle(color: Colors.white, fontFamily: 'system'),
        titleMedium: TextStyle(color: Colors.white70, fontFamily: 'system'),
        titleSmall: TextStyle(color: Colors.white60, fontFamily: 'system'),
        displayLarge: TextStyle(color: Colors.white, fontFamily: 'system'),
        displayMedium: TextStyle(color: Colors.white70, fontFamily: 'system'),
        displaySmall: TextStyle(color: Colors.white60, fontFamily: 'system'),
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
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CustomColor.textThemeLightColor),
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
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
        textStyle: TextStyle(
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
        textStyle: WidgetStatePropertyAll(TextStyle(color: CustomColor.textThemeDarkSoftColor)),
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
        textStyle: WidgetStatePropertyAll(TextStyle()),
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