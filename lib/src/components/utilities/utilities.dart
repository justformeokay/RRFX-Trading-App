import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilitiesComponents {
  // Privacy Policy Text
  static RichText privacyPolicy(BuildContext context, {TextAlign? textAlign}) {
    final textTheme = Theme.of(context).textTheme;
    final defaultColor = textTheme.bodySmall?.color ?? Colors.black54;

    return RichText(
      textAlign: textAlign ?? TextAlign.center,
      text: TextSpan(
        style: textTheme.labelSmall?.copyWith(color: defaultColor),
        children: [
          TextSpan(
            text: 'Dengan mendaftar, Anda menyetujui ',
            style: TextStyle(color: defaultColor),
          ),
          TextSpan(
            text: 'Kebijakan Privasi',
            style: TextStyle(
              color: CustomColor.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                const url = 'https://www.rrfx.com/privacy';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
          ),
          TextSpan(
            text: ' dan ',
            style: TextStyle(color: defaultColor),
          ),
          TextSpan(
            text: 'Syarat & Ketentuan',
            style: TextStyle(
              color: CustomColor.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                const url = 'https://www.rrfx.com/privacy';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
          ),
          TextSpan(
            text: ' aplikasi RRFX.',
            style: TextStyle(color: defaultColor),
          ),
        ],
      ),
    );
  }

  // KaryaDeveloperIndonesia Text Recognizer
  static GestureDetector rrfx(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultColor = textTheme.bodySmall?.color ?? Colors.black54;

    return GestureDetector(
      onTap: () async {
        const url = 'https://rrfx.com';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url),
              mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "PT. RRFX Investasi Berjangka ",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: defaultColor,
                  ),
                ),
                TextSpan(
                  text: "Terlisensi dan Teregulasi oleh",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: defaultColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/bappebti.png', width: 55),
              Image.asset('assets/images/jfx.png', width: 55),
              Image.asset('assets/images/kilangberjangka.png', width: 55),
              Image.asset('assets/images/ojk.png', width: 55),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/ich.png', width: 50),
              Image.asset('assets/images/icdx.png', width: 60),
            ],
          )
        ],
      ),
    );
  }

  static Column titlePage(BuildContext context,
      {String? title, String? subtitle}) {
    final textTheme = Theme.of(context).textTheme;
    final ThemeController themeController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo-rrfx-3.png', width: 40),
                const SizedBox(width: 10.0),
                Text(
                  title ?? "RRFX",
                  style: GoogleFonts.inter(
                    color: textTheme.titleLarge?.color,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Obx(
              () => Switch(
                activeColor: CustomColor.secondaryBackground,
                thumbIcon: WidgetStatePropertyAll(
                  Icon(
                    themeController.isDark.value
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: themeController.isDark.value ? Colors.black : Colors.white,
                  ),
                ),
                value: themeController.isDark.value,
                onChanged: (value) {
                  themeController.toggleTheme(value);
                },
              ),
            ),
          ],
        ),
        Text(
          subtitle ??
              "Mulai Pengalaman Trading Forex, Komoditi dan Indeks Saham jadi lebih tenang dengan strategi yang tepat bersama RRFX.",
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  static Row checkBoxAgreement(BuildContext context, {RxBool? checkedRead}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(
          () => Checkbox(
            value: checkedRead?.value,
            onChanged: (value) => checkedRead?.value = value ?? false,
            checkColor: Colors.white,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (checkedRead?.value == true) {
                return CustomColor.secondaryColor;
              }
              return Colors.transparent;
            }),
            side: BorderSide(
              width: 1.0,
              color: checkedRead?.value == true
                  ? CustomColor.secondaryColor
                  : Theme.of(context).dividerColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
        Flexible(
          child: UtilitiesComponents.privacyPolicy(context,
              textAlign: TextAlign.start),
        )
      ],
    );
  }
}
